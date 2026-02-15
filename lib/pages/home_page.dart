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
  List<Course> _courses = [];
  int currentWeek = 1; 
  final double sectionHeight = 64.0; // 参考 CourseCardSpec.kt

  @override
  void initState() {
    super.initState();
    _calculateCurrentWeek(); // 初始化时计算周次
  }

  // 根据 kebiao.html 提供的开学日期 2026-03-02 动态计算周次
  void _calculateCurrentWeek() {
    DateTime startDate = DateTime(2026, 3, 2);
    DateTime now = DateTime.now();
    if (now.isBefore(startDate)) {
      currentWeek = 1;
    } else {
      int days = now.difference(startDate).inDays;
      setState(() => currentWeek = (days / 7).floor() + 1);
    }
  }

  void _refreshData() async {
    // 接口地址参考 kebiao.html 和 JwxtApi.kt
    const semesterId = "112"; 
    final url = "/student/for-std/course-table/get-data?semesterId=$semesterId&bizTypeId=2";
    
    String jsonRaw = await NetClient().get(url);
    setState(() => _courses = ScheduleParser.parseSchedule(jsonRaw));
  }

  @override
  Widget build(BuildContext context) {
    double columnWidth = (MediaQuery.of(context).size.width - 40) / 7;

    return Scaffold(
      appBar: AppBar(
        title: Text("第 $currentWeek 周"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => setState(() => currentWeek > 1 ? currentWeek-- : null),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => currentWeek++),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          IconButton(
            icon: const Icon(Icons.login, color: Colors.orange), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginWebView()))
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeColumn(),
            Expanded(
              child: SizedBox(
                height: sectionHeight * 12,
                child: Stack(
                  children: [
                    _buildGridLines(),
                    ..._courses.map((c) => _buildCourseCard(c, columnWidth)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course, double width) {
    // 仿照 CourseCard.kt 判断本周是否有课
    bool isCurrentWeek = course.weekIndexes.contains(currentWeek);

    return Positioned(
      top: (course.startTime - 1) * sectionHeight,
      left: (course.weekday - 1) * width,
      width: width,
      height: course.length * sectionHeight,
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isCurrentWeek ? course.color : Colors.grey.withOpacity(0.2), // 非本周变灰
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.name, 
              style: TextStyle(fontSize: 10, color: isCurrentWeek ? Colors.white : Colors.black38, fontWeight: FontWeight.bold), 
              maxLines: 3, overflow: TextOverflow.ellipsis),
            const Spacer(),
            if (isCurrentWeek)
              Text(course.location, style: const TextStyle(fontSize: 9, color: Colors.white70), maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn() => SizedBox(width: 40, child: Column(children: List.generate(12, (i) => SizedBox(height: sectionHeight, child: Center(child: Text("${i + 1}", style: const TextStyle(color: Colors.grey, fontSize: 12)))))));
  Widget _buildGridLines() => Stack(children: List.generate(12, (i) => Positioned(top: i * sectionHeight, left: 0, right: 0, child: Container(height: sectionHeight, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100)))))));
}