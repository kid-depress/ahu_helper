import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'api/net_client.dart';
import 'pages/webview_login_page.dart';

void main() {
  runApp(const MaterialApp(home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _info = "请先登录教务系统";

  // 测试抓取课表页面
  void _fetchSchedule() async {
    setState(() => _info = "正在抓取课表数据...");
    // 这里的路径参考 JwxtApi.kt 中的课表地址
    String html = await NetClient().get("/student/for-std/course-table");
    
    if (html.contains("课程表") || html.contains("semester")) {
      setState(() => _info = "✅ 抓取成功！获取到 HTML 长度: ${html.length}\n接下来可以用 html 库解析表格了。");
    } else {
      setState(() => _info = "❌ 抓取失败或权限不足，请重新登录。");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("安大助手 Flutter")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(_info, textAlign: TextAlign.center),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginWebView()),
                );
                if (success == true) {
                  Fluttertoast.showToast(msg: "登录成功！");
                  _fetchSchedule();
                }
              },
              child: const Text("去登录 (网页模式)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchSchedule,
              child: const Text("直接刷新数据"),
            ),
          ],
        ),
      ),
    );
  }
}