import 'package:flutter/material.dart';
import '../api/net_client.dart';
import '../models/course.dart';
import '../utils/schedule_parser.dart';
import 'webview_login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Course> _courseList = []; // 存放解析后的课程
  bool _isLoading = false;

  void _fetchSchedule() async {
    setState(() => _isLoading = true);
    
    // 1. 抓取 HTML
    String html = await NetClient().get("/student/for-std/course-table");
    
    // 2. 调用解析器
    List<Course> parsedCourses = ScheduleParser.parseSchedule(html);
    
    setState(() {
      _courseList = parsedCourses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("我的课表")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) // 加载中动画
        : _courseList.isEmpty
          ? const Center(child: Text("暂无课程数据，请先登录或刷新"))
          : ListView.builder(
              itemCount: _courseList.length,
              itemBuilder: (context, index) {
                final course = _courseList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.book, color: Colors.blue),
                    title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${course.teacher} @ ${course.location}"),
                    trailing: Text(course.time),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchSchedule,
        child: const Icon(Icons.refresh),
      ),
      bottomNavigationBar: BottomAppBar(
        child: TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginWebView())),
          child: const Text("去登录"),
        ),
      ),
    );
  }
}