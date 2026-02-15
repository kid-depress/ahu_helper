import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class NetClient {
  // 单例模式：确保整个 App 只有一个网络请求器（就像只有一个浏览器）
  static final NetClient _instance = NetClient._internal();
  late Dio dio;
  late CookieJar cookieJar;

  factory NetClient() => _instance;

  NetClient._internal() {
    // 1. 初始化 Dio
    dio = Dio(BaseOptions(
      // ⚠️ 如果是安大教务系统，通常基础地址是这个，如果不对请根据实际情况修改
      baseUrl: "https://jw.ahu.edu.cn", 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        // 伪装成浏览器，防止被拦截
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
      },
      responseType: ResponseType.plain, // 默认接收纯文本（HTML）
    ));

    // 2. 挂载 Cookie 管理器 (最关键的一步！)
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
  }

  // 提供一个简单的 get 方法
  Future<String> get(String path, {Map<String, dynamic>? params}) async {
    try {
      var response = await dio.get(path, queryParameters: params);
      return response.data.toString();
    } catch (e) {
      print("GET请求出错: $e");
      rethrow;
    }
  }

  // 提供一个简单的 post 方法
  Future<String> post(String path, {dynamic data}) async {
    try {
      var response = await dio.post(path, data: data, options: Options(contentType: Headers.formUrlEncodedContentType));
      return response.data.toString();
    } catch (e) {
      print("POST请求出错: $e");
      rethrow;
    }
  }
}