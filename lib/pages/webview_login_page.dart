import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../api/net_client.dart'; //

class LoginWebView extends StatefulWidget {
  const LoginWebView({super.key});

  @override
  State<LoginWebView> createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {
  final GlobalKey webViewKey = GlobalKey();
  final String loginUrl = "https://jw.ahu.edu.cn/student/sso/login";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("教务系统登录")),
      body: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: WebUri(loginUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,       // 开启 JS
          domStorageEnabled: true,       // 开启 DOM 存储
          useWideViewPort: true,
          // 允许混合内容 (HTTP/HTTPS)
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        ),
        // 关键：忽略 SSL 证书错误，防止因证书过期导致的空白页
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
        },
        onLoadStop: (controller, url) async {
          String urlStr = url.toString();
          debugPrint("加载完成: $urlStr");

          // 登录成功逻辑判断
          if ((urlStr.contains("index") || urlStr.contains("home")) && !urlStr.contains("login")) {
            List<Cookie> cookies = await CookieManager.instance().getCookies(url: url!);
            
            if (cookies.isNotEmpty) {
              List<io.Cookie> ioCookies = cookies.map((c) {
                return io.Cookie(c.name, c.value.toString())
                  ..domain = c.domain
                  ..path = c.path ?? "/";
              }).toList();

              await NetClient().setCookies("https://jw.ahu.edu.cn", ioCookies);

              if (mounted) Navigator.pop(context, true);
            }
          }
        },
      ),
    );
  }
}