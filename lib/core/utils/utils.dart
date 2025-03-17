class Utils {
  static int hexToInt(String hexString) {
    List<String> splitted = [];
    for (int i = 0; i < hexString.length; i = i + 2) {
      splitted.add(hexString.substring(i, i + 2));
    }
    String ascii = List.generate(
        splitted.length, (i) => (int.parse(splitted[i], radix: 16))).join();

    return int.parse(ascii);
  }

  static String hexToAscii(String hexString) {
    List<String> splitted = [];
    for (int i = 0; i < hexString.length; i = i + 2) {
      splitted.add(hexString.substring(i, i + 2));
    }
    String ascii = List.generate(splitted.length,
        (i) => String.fromCharCode(int.parse(splitted[i], radix: 16))).join();
    return ascii;
  }

  static String toHexString(String str) {
    final ascii = str.codeUnits;
    var code = <String>[];
    for (var asc in ascii) {
      code.add(asc.toRadixString(16));
    }
    return code.join();
  }
}
