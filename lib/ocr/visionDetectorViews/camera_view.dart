import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '/main.dart';
import '/shared/services/permission_camera.service.dart';

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key,
      required this.title,
      required this.customPaint,
      required this.onImage,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  PermissionStatus permissionStatus = PermissionStatus.denied;
  ScreenMode _mode = ScreenMode.gallery;
  CameraController? _controller;
  File? _image;
  XFile? _pickedFile;
  ImagePicker? _imagePicker;
  int _cameraIndex = 0;
  double zoomLevel = 0.0;
  double minZoomLevel = 0.0;
  double maxZoomLevel = 0.0;

  @override
  void initState() {
    Permission.camera.status.then((value) => permissionStatus = value);

    _imagePicker = ImagePicker();
    for (var i = 0; i < cameras.length; i++) {
      if (cameras[i].lensDirection == widget.initialDirection) {
        _cameraIndex = i;
      }
    }

    // _startLiveFeed();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: _switchScreenMode,
              child: Icon(defineIcon()),
            ),
          ),
        ],
      ),
      body: defineBody(),
      // floatingActionButton: _floatingActionButton(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  // Widget? _floatingActionButton() {
  //   if (_mode == ScreenMode.gallery) {
  //     return null;
  //   }
  //   if (cameras.length == 1) {
  //     return null;
  //   }
  //   return SizedBox(
  //       height: 60,
  //       width: 60,
  //       child: FloatingActionButton(
  //           child: const Icon(Icons.add_a_photo, size: 30),
  //           backgroundColor: Colors.amber,
  //           onPressed: () {
  //             if (_controller!.value.isStreamingImages) {
  //               _controller!.stopImageStream();
  //             }
  //             _getImage(ImageSource.camera);
  //           } //_switchLiveCamera,
  //           ));
  // }

  IconData defineIcon() {
    return (_mode == ScreenMode.liveFeed)
        ? Icons.photo_library_outlined
        : Icons.camera_alt_outlined;
  }

  Widget defineBody() {
    return (_mode == ScreenMode.liveFeed) ? _liveFeedBody() : _galleryBody();
  }

  Widget defineSlider() {
    return Slider(
      value: zoomLevel,
      min: minZoomLevel,
      max: maxZoomLevel,
      onChanged: (newSliderValue) {
        setState(() {
          zoomLevel = newSliderValue;
          _controller!.setZoomLevel(zoomLevel);
        });
      },
      divisions:
          ((maxZoomLevel - 1).toInt() < 1) ? null : (maxZoomLevel - 1).toInt(),
    );
  }

  Widget _liveFeedBody() {
    if (permissionStatus.isGranted) {
      return Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (_controller != null) CameraPreview(_controller!),
            if (widget.customPaint != null) widget.customPaint!,
            Positioned(bottom: 100, left: 50, right: 50, child: defineSlider())
          ],
        ),
      );
    } else {
      return Container(
          margin: const EdgeInsets.all(9.0),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text('Permitir acesso à câmera'),
              onPressed: () =>
                  PermissionCameraService.permissionServices().then((value) {
                if (value[Permission.camera] == PermissionStatus.granted) {
                  Navigator.of(context).pushNamed('/ocr');
                }
              }),
            ),
          ));
    }
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      (_image != null)
          ? SizedBox(
              height: 400,
              width: 400,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(_image!),
                  if (widget.customPaint != null) widget.customPaint!,
                ],
              ),
            )
          : const Icon(
              Icons.image_sharp,
              size: 400,
              color: Colors.grey,
            ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: const Text('Carregar da galeria'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            //primary: Colors.pink,
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: const Text('Tirar uma foto'),
          onPressed: () =>
              PermissionCameraService.permissionServices().then((value) {
            if (value[Permission.camera] == PermissionStatus.granted) {
              _getImage(ImageSource.camera);
            }
          }),
        ),
      ),
      (_pickedFile != null)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text('Reprocessar imagem'),
                onPressed: () => _processPickedFile(_pickedFile!),
              ),
            )
          : Container(),
    ]);
  }

  void _getImage(ImageSource source) {
    _imagePicker?.pickImage(source: source).then((value) {
      setState(() {
        _pickedFile = value;
      });

      if (value == null) {
        throw 'Imagem não disponível.';
      } else {
        _processPickedFile(value);
      }
    }).catchError((error) {
      String errorMessage = error.toString();
      if (error is PlatformException &&
          error.message != null &&
          error.message!.isNotEmpty) {
        errorMessage = error.message!;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.deepOrange, content: Text(errorMessage)));
    }).whenComplete(() => setState(() {}));
  }

  void _switchScreenMode() async {
    if (_mode == ScreenMode.liveFeed) {
      _mode = ScreenMode.gallery;
      await _stopLiveFeed();
    } else {
      _mode = ScreenMode.liveFeed;
      PermissionCameraService.permissionServices().then((value) {
        if (value[Permission.camera] == PermissionStatus.granted) {
          _startLiveFeed();
        }
      });
    }
    setState(() {});
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      await _controller?.dispose();
    }
    _controller = null;
    _image = null;
    _pickedFile = null;
  }

  // Future _switchLiveCamera() async {
  //   if (_cameraIndex == 0) {
  //     _cameraIndex = 1;
  //   } else {
  //     _cameraIndex = 0;
  //   }
  //   await _stopLiveFeed();
  //   await _startLiveFeed();
  // }

  void _processPickedFile(XFile pickedFile) {
    setState(() {
      _image = File(pickedFile.path);
    });
    final inputImage = InputImage.fromFilePath(pickedFile.path);
    widget.onImage(inputImage);
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }
}
