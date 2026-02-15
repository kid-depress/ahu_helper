import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'api/net_client.dart';
import 'pages/webview_login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NetClient().init(); // 初始化网络层
  runApp(const MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = "尚未登录";

  void _checkStatus() async {
    // 尝试访问首页，看是否会被踢回登录页
    String html = await NetClient().get("/student/home");
    if (html.contains("刘哲仙") || html.contains("student")) {
      setState(() => _status = "✅ 已登录：检测到学生身份");
    } else {
      setState(() => _status = "❌ 登录失效或未登录");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("安大助手 - 登录测试")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final success = await Navigator.push(
                  context, MaterialPageRoute(builder: (c) => const LoginWebView())
                );
                if (success == true) {
                  Fluttertoast.showToast(msg: "登录成功！");
                  _checkStatus();
                }
              },
              child: const Text("立即登录 (WebView)"),
            ),
            TextButton(onPressed: _checkStatus, child: const Text("刷新状态")),
          ],
        ),
      ),
    );
  }
}