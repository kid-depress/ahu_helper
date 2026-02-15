import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/net_client.dart';
import 'webview_login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _info = "未登录";

  void _fetchSchedule() async {
    setState(() => _info = "正在获取数据...");
    String html = await NetClient().get("/student/for-std/course-table");
    
    if (html.contains("课程表") || html.contains("semester")) {
      setState(() => _info = "✅ 登录有效！获取到 HTML 长度: ${html.length}");
    } else {
      setState(() => _info = "❌ 登录失效或未登录");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("安大助手")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_info),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final success = await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const LoginWebView())
                );
                if (success == true) {
                  Fluttertoast.showToast(msg: "登录成功！");
                  _fetchSchedule();
                }
              },
              child: const Text("网页登录"),
            ),
            ElevatedButton(onPressed: _fetchSchedule, child: const Text("刷新数据")),
          ],
        ),
      ),
    );
  }
}