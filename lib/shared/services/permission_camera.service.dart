import 'package:permission_handler/permission_handler.dart';

class PermissionCameraService {
static  call() async {
    await permissionServices().then(
      (value) {
        if (value[Permission.camera]?.isGranted ?? false) {
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => SplashScreen()),
          // );
        }
      },
    );
  }

 static Future<Map<Permission, PermissionStatus>> permissionServices() async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      //add more permission to request here.
    ].request();

    switch (statuses[Permission.camera]) {
      case PermissionStatus.granted:
        break;
      case PermissionStatus.limited:
        break;
      case PermissionStatus.restricted:
        break;
      case PermissionStatus.denied:        
        break;
      case PermissionStatus.permanentlyDenied:
        openAppSettings();
        break;
      default:
        break;
    }

    /*{Permission.camera: PermissionStatus.granted, Permission.storage: PermissionStatus.granted}*/
    return statuses;
  }
}
