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
  final String loginUrl = "https://jw.ahu.edu.cn/student/sso/login";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("教务系统登录")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(loginUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
        ),
        // 处理证书问题，防止页面空白
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
        },
        onLoadStop: (controller, url) async {
          String urlStr = url.toString();
          // 判断登录成功：进入 index 或 home 且不在登录页
          if ((urlStr.contains("index") || urlStr.contains("home")) && !urlStr.contains("login")) {
            List<Cookie> cookies = await CookieManager.instance().getCookies(url: url!);
            
            if (cookies.isNotEmpty) {
              List<io.Cookie> ioCookies = cookies.map((c) {
                return io.Cookie(c.name, c.value.toString())
                  ..domain = c.domain
                  ..path = c.path ?? "/";
              }).toList();

              // 同步 Cookie 给全局网络客户端
              await NetClient().setCookies("https://jw.ahu.edu.cn", ioCookies);

              if (mounted) Navigator.pop(context, true);
            }
          }
        },
      ),
    );
  }
}