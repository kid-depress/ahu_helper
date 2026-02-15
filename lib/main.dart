import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'api/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '安大助手 Flutter版',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();
  bool _isLoading = false;

  void _doLogin() async {
    if (_userCtrl.text.isEmpty || _pwdCtrl.text.isEmpty) {
      Fluttertoast.showToast(msg: "请输入学号和密码");
      return;
    }

    setState(() => _isLoading = true);
    
    // 调用我们写的登录服务
    bool success = await AuthService().login(_userCtrl.text, _pwdCtrl.text);

    setState(() => _isLoading = false);

    if (success) {
      Fluttertoast.showToast(msg: "登录成功！(模拟)");
      // TODO: 跳转到课表页面
    } else {
      Fluttertoast.showToast(msg: "登录失败，请检查账号密码");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("教务系统登录")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.blue),
            const SizedBox(height: 30),
            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(
                labelText: "学号",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pwdCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "密码",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _doLogin,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("登 录", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}