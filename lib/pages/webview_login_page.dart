import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../api/net_client.dart';

class LoginWebView extends StatefulWidget {
  const LoginWebView({super.key});

  @override
  State<LoginWebView> createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  CookieManager cookieManager = CookieManager.instance();

  // 学校教务系统的登录入口
  final String loginUrl = "https://jw.ahu.edu.cn/student/sso/login";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("教务系统登录")),
      body: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: WebUri(loginUrl)),
        onWebViewCreated: (controller) => webViewController = controller,
        onLoadStop: (controller, url) async {
          String urlStr = url.toString();
          debugPrint("页面加载完成: $urlStr");

          // 判断登录成功的逻辑：
          // 1. URL 包含 'index' 或 'home' (进入系统主页)
          // 2. 且不再包含 'login' 关键字
          if ((urlStr.contains("index") || urlStr.contains("home")) && !urlStr.contains("login")) {
            debugPrint("检测到登录成功，准备抓取 Cookie...");
            
            // 获取该域名下的所有 Cookie
            List<Cookie> cookies = await cookieManager.getCookies(url: url!);
            
            if (cookies.isNotEmpty) {
              // 转换格式并塞给 NetClient
              List<io.Cookie> ioCookies = cookies.map((c) {
                return io.Cookie(c.name, c.value.toString())
                  ..domain = c.domain
                  ..path = c.path ?? "/";
              }).toList();

              await NetClient().setCookies("https://jw.ahu.edu.cn", ioCookies);

              if (mounted) {
                Navigator.pop(context, true); // 携带成功标记返回
              }
            }
          }
        },
      ),
    );
  }
}