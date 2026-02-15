import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class NetClient {
  static final NetClient _instance = NetClient._internal();
  late Dio dio;
  late CookieJar cookieJar;

  factory NetClient() => _instance;

  NetClient._internal() {
    cookieJar = CookieJar();
    dio = Dio(BaseOptions(
      baseUrl: "https://jw.ahu.edu.cn",
      connectTimeout: const Duration(seconds: 10),
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      },
    ));
    dio.interceptors.add(CookieManager(cookieJar));
  }

  // 注入从 WebView 获取的 Cookie
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