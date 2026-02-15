import 'package:flutter/material.dart';
import 'api/net_client.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NetClient().init(); // 初始化 Cookie 存储
  runApp(const MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false));
}