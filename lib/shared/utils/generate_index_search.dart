class GenerateIndexSearch {
  static List<String> create(String value) {
    List<String> splitList = value.trim().split(" ");
    List<String> indexList = [];

    for (var i = 0; i < splitList.length; i++) {
      for (var y = 1; y < (splitList[i].length + 1); y++) {
        indexList.add(splitList[i].substring(0, y).toLowerCase());
      }
    }

    return indexList;
  }
}
