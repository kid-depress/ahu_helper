// des_util.dart
// 完全复刻自 Android 项目中的 DES.java，专用于处理特殊的 16-bit 字符加密

class DesUtil {
  // 对应 Java 中的 strEnc(data, '1', '2', '3')
  static String encrypt(String data, String k1, String k2, String k3) {
    if (data.isEmpty) return "";

    List<List<int>> keyBytes1 = _getKeyBytes(k1);
    List<List<int>> keyBytes2 = _getKeyBytes(k2);
    List<List<int>> keyBytes3 = _getKeyBytes(k3);

    String encData = "";
    int leng = data.length;

    // 逻辑：如果长度<4，补齐并加密一次；否则每4个字符一组进行加密
    if (leng < 4) {
      List<int> bt = _strToBt(data);
      List<int> encByte = bt;
      
      // 三层加密 (3DES 变种)
      for (var k in keyBytes1) encByte = _enc(encByte, k);
      for (var k in keyBytes2) encByte = _enc(encByte, k);
      for (var k in keyBytes3) encByte = _enc(encByte, k);
      
      encData = _bt64ToHex(encByte);
    } else {
      int iterator = leng ~/ 4;
      int remainder = leng % 4;
      
      for (int i = 0; i < iterator; i++) {
        String tempData = data.substring(i * 4, i * 4 + 4);
        List<int> tempByte = _strToBt(tempData);
        List<int> encByte = tempByte;

        for (var k in keyBytes1) encByte = _enc(encByte, k);
        for (var k in keyBytes2) encByte = _enc(encByte, k);
        for (var k in keyBytes3) encByte = _enc(encByte, k);

        encData += _bt64ToHex(encByte);
      }
      
      if (remainder > 0) {
        String remainderData = data.substring(iterator * 4);
        List<int> tempByte = _strToBt(remainderData);
        List<int> encByte = tempByte;

        for (var k in keyBytes1) encByte = _enc(encByte, k);
        for (var k in keyBytes2) encByte = _enc(encByte, k);
        for (var k in keyBytes3) encByte = _enc(encByte, k);

        encData += _bt64ToHex(encByte);
      }
    }
    return encData;
  }

  // --- 以下为私有辅助算法，照搬 Java 逻辑 ---

  static List<int> _strToBt(String str) {
    int leng = str.length;
    List<int> bt = List.filled(64, 0);
    
    // 这里的核心差异：Java char 是 16位，它把每个 char 拆成 16 bits
    if (leng < 4) {
      for (int i = 0; i < leng; i++) {
        int k = str.codeUnitAt(i);
        for (int j = 0; j < 16; j++) {
          int pow = 1;
          for (int m = 15; m > j; m--) pow *= 2;
          bt[16 * i + j] = (k ~/ pow) % 2;
        }
      }
    } else {
      for (int i = 0; i < 4; i++) {
        int k = str.codeUnitAt(i);
        for (int j = 0; j < 16; j++) {
          int pow = 1;
          for (int m = 15; m > j; m--) pow *= 2;
          bt[16 * i + j] = (k ~/ pow) % 2;
        }
      }
    }
    return bt;
  }

  static String _bt64ToHex(List<int> byteData) {
    String hex = "";
    for (int i = 0; i < 16; i++) {
      String bt = "";
      for (int j = 0; j < 4; j++) {
        bt += byteData[i * 4 + j].toString();
      }
      hex += _bt4ToHex(bt);
    }
    return hex;
  }

  static String _bt4ToHex(String binary) {
    const map = {
      "0000": "0", "0001": "1", "0010": "2", "0011": "3",
      "0100": "4", "0101": "5", "0110": "6", "0111": "7",
      "1000": "8", "1001": "9", "1010": "A", "1011": "B",
      "1100": "C", "1101": "D", "1110": "E", "1111": "F"
    };
    return map[binary] ?? "0";
  }

  static List<List<int>> _getKeyBytes(String key) {
    List<List<int>> keyBytes = [];
    int leng = key.length;
    int iterator = leng ~/ 4;
    int remainder = leng % 4;
    for (int i = 0; i < iterator; i++) {
      keyBytes.add(_strToBt(key.substring(i * 4, i * 4 + 4)));
    }
    if (remainder > 0) {
      keyBytes.add(_strToBt(key.substring(iterator * 4)));
    }
    return keyBytes;
  }

  static List<int> _enc(List<int> dataByte, List<int> keyByte) {
    List<List<int>> keys = _generateKeys(keyByte);
    List<int> ipByte = _initPermute(dataByte);
    List<int> ipLeft = List.filled(32, 0);
    List<int> ipRight = List.filled(32, 0);
    List<int> tempLeft = List.filled(32, 0);

    for (int k = 0; k < 32; k++) {
      ipLeft[k] = ipByte[k];
      ipRight[k] = ipByte[32 + k];
    }

    for (int i = 0; i < 16; i++) {
      for (int j = 0; j < 32; j++) {
        tempLeft[j] = ipLeft[j];
        ipLeft[j] = ipRight[j];
      }
      List<int> key = keys[i];
      // 核心运算：XOR + P置换 + S盒 + 扩展置换
      List<int> tempRight = _xor(
          _pPermute(_sBoxPermute(_xor(_expandPermute(ipRight), key))), tempLeft);
      for (int n = 0; n < 32; n++) {
        ipRight[n] = tempRight[n];
      }
    }

    List<int> finalData = List.filled(64, 0);
    for (int i = 0; i < 32; i++) {
      finalData[i] = ipRight[i];
      finalData[32 + i] = ipLeft[i];
    }
    return _finallyPermute(finalData);
  }

  static List<int> _initPermute(List<int> originalData) {
    List<int> ipByte = List.filled(64, 0);
    for (int i = 0, m = 1, n = 0; i < 4; i++, m += 2, n += 2) {
      for (int j = 7, k = 0; j >= 0; j--, k++) {
        ipByte[i * 8 + k] = originalData[j * 8 + m];
        ipByte[i * 8 + k + 32] = originalData[j * 8 + n];
      }
    }
    return ipByte;
  }

  static List<int> _expandPermute(List<int> rightData) {
    List<int> epByte = List.filled(48, 0);
    for (int i = 0; i < 8; i++) {
      if (i == 0) epByte[i * 6 + 0] = rightData[31];
      else epByte[i * 6 + 0] = rightData[i * 4 - 1];
      
      epByte[i * 6 + 1] = rightData[i * 4 + 0];
      epByte[i * 6 + 2] = rightData[i * 4 + 1];
      epByte[i * 6 + 3] = rightData[i * 4 + 2];
      epByte[i * 6 + 4] = rightData[i * 4 + 3];
      
      if (i == 7) epByte[i * 6 + 5] = rightData[0];
      else epByte[i * 6 + 5] = rightData[i * 4 + 4];
    }
    return epByte;
  }

  static List<int> _xor(List<int> byteOne, List<int> byteTwo) {
    List<int> xorByte = List.filled(byteOne.length, 0);
    for (int i = 0; i < byteOne.length; i++) {
      xorByte[i] = byteOne[i] ^ byteTwo[i];
    }
    return xorByte;
  }

  static List<int> _sBoxPermute(List<int> expandByte) {
    List<int> sBoxByte = List.filled(32, 0);
    
    // S盒定义 (照搬)
    const s1 = [
      [14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7],
      [0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8],
      [4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0],
      [15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13]
    ];
    const s2 = [
      [15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10],
      [3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5],
      [0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15],
      [13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9]
    ];
    const s3 = [
      [10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8],
      [13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1],
      [13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7],
      [1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12]
    ];
    const s4 = [
      [7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15],
      [13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9],
      [10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4],
      [3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14]
    ];
    const s5 = [
      [2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9],
      [14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6],
      [4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14],
      [11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3]
    ];
    const s6 = [
      [12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11],
      [10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8],
      [9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6],
      [4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13]
    ];
    const s7 = [
      [4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1],
      [13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6],
      [1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2],
      [6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12]
    ];
    const s8 = [
      [13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7],
      [1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2],
      [7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8],
      [2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11]
    ];

    for (int m = 0; m < 8; m++) {
      int i = expandByte[m * 6 + 0] * 2 + expandByte[m * 6 + 5];
      int j = expandByte[m * 6 + 1] * 8 + expandByte[m * 6 + 2] * 4 +
          expandByte[m * 6 + 3] * 2 + expandByte[m * 6 + 4];
      
      String binary = "";
      List<List<int>> currentS = [s1, s2, s3, s4, s5, s6, s7, s8][m];
      int val = currentS[i][j];
      
      // 简易 int 转 4bit binary
      switch (val) {
        case 0: binary = "0000"; break; case 1: binary = "0001"; break;
        case 2: binary = "0010"; break; case 3: binary = "0011"; break;
        case 4: binary = "0100"; break; case 5: binary = "0101"; break;
        case 6: binary = "0110"; break; case 7: binary = "0111"; break;
        case 8: binary = "1000"; break; case 9: binary = "1001"; break;
        case 10: binary = "1010"; break; case 11: binary = "1011"; break;
        case 12: binary = "1100"; break; case 13: binary = "1101"; break;
        case 14: binary = "1110"; break; case 15: binary = "1111"; break;
      }
      
      sBoxByte[m * 4 + 0] = int.parse(binary[0]);
      sBoxByte[m * 4 + 1] = int.parse(binary[1]);
      sBoxByte[m * 4 + 2] = int.parse(binary[2]);
      sBoxByte[m * 4 + 3] = int.parse(binary[3]);
    }
    return sBoxByte;
  }

  static List<int> _pPermute(List<int> sBoxByte) {
    List<int> pBoxPermute = List.filled(32, 0);
    const map = [15, 6, 19, 20, 28, 11, 27, 16, 0, 14, 22, 25, 4, 17, 30, 9, 1, 7, 23, 13, 31, 26, 2, 8, 18, 12, 29, 5, 21, 10, 3, 24];
    for(int i=0; i<32; i++) {
      pBoxPermute[i] = sBoxByte[map[i]];
    }
    return pBoxPermute;
  }

  static List<int> _finallyPermute(List<int> endByte) {
    List<int> fpByte = List.filled(64, 0);
    const map = [39, 7, 47, 15, 55, 23, 63, 31, 38, 6, 46, 14, 54, 22, 62, 30, 37, 5, 45, 13, 53, 21, 61, 29, 36, 4, 44, 12, 52, 20, 60, 28, 35, 3, 43, 11, 51, 19, 59, 27, 34, 2, 42, 10, 50, 18, 58, 26, 33, 1, 41, 9, 49, 17, 57, 25, 32, 0, 40, 8, 48, 16, 56, 24];
    for(int i=0; i<64; i++) {
      fpByte[i] = endByte[map[i]];
    }
    return fpByte;
  }

  static List<List<int>> _generateKeys(List<int> keyByte) {
    List<int> key = List.filled(56, 0);
    List<List<int>> keys = List.generate(16, (_) => List.filled(48, 0));
    const loop = [1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1];

    for (int i = 0; i < 7; i++) {
      for (int j = 0, k = 7; j < 8; j++, k--) {
        key[i * 8 + j] = keyByte[8 * k + i];
      }
    }

    for (int i = 0; i < 16; i++) {
      int tempLeft = 0;
      int tempRight = 0;
      for (int j = 0; j < loop[i]; j++) {
        tempLeft = key[0];
        tempRight = key[28];
        for (int k = 0; k < 27; k++) {
          key[k] = key[k + 1];
          key[28 + k] = key[29 + k];
        }
        key[27] = tempLeft;
        key[55] = tempRight;
      }
      List<int> tempKey = List.filled(48, 0);
      const map = [13, 16, 10, 23, 0, 4, 2, 27, 14, 5, 20, 9, 22, 18, 11, 3, 25, 7, 15, 6, 26, 19, 12, 1, 40, 51, 30, 36, 46, 54, 29, 39, 50, 44, 32, 47, 43, 48, 38, 55, 33, 52, 45, 41, 49, 35, 28, 31];
      for(int m=0; m<48; m++) {
        tempKey[m] = key[map[m]];
      }
      for (int m = 0; m < 48; m++) {
        keys[i][m] = tempKey[m];
      }
    }
    return keys;
  }
}