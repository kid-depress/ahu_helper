import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart'; //

class NetClient {
  static final NetClient _instance = NetClient._internal();
  late Dio dio;
  late PersistCookieJar cookieJar; // 持久化 Cookie

  factory NetClient() => _instance;

  NetClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: "https://jw.ahu.edu.cn",
      connectTimeout: const Duration(seconds: 10),
      headers: {
        // 模拟电脑浏览器，防止被服务器识别为移动端导致空白或跳转
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      },
    ));
  }

  // 初始化方法，必须在 main.dart 中调用
  Future<void> init() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final String path = "${appDocDir.path}/.cookies/";
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    cookieJar = PersistCookieJar(storage: FileStorage(path));
    dio.interceptors.add(CookieManager(cookieJar));
  }

  // 注入 WebView 抓到的 Cookie
  Future<void> setCookies(String url, List<Cookie> cookies) async {
    await cookieJar.saveFromResponse(Uri.parse(url), cookies);
  }

  Future<String> get(String path) async {
    try {
      var response = await dio.get(path);
      return response.data.toString();
    } catch (e) {
      return "请求失败: $e";
    }
  }
}