import 'dart:convert';
import '../models/course.dart';

class ScheduleParser {
  static List<Course> parseSchedule(String responseBody) {
    try {
      final Map<String, dynamic> data = json.decode(responseBody);
      List<Course> courses = [];

      // 数据路径参考 CourseTable.kt 中的 StudentTableVm 结构
      var vms = data['studentTableVms'];
      if (vms == null || vms.isEmpty) return [];

      var activities = vms[0]['activities'] ?? [];

      for (var act in activities) {
        courses.add(Course(
          name: act['courseName'] ?? "未知课程",
          teacher: (act['teachers'] as List?)?.join('/') ?? "未知教师",
          // 拼接校区、大楼和教室
          location: "${act['campus'] ?? ''}${act['building'] ?? ''}${act['room'] ?? ''}",
          weekday: act['weekday'] ?? 1,
          startTime: act['startUnit'] ?? 1,
          length: (act['endUnit'] ?? 1) - (act['startUnit'] ?? 1) + 1,
          weekIndexes: List<int>.from(act['weeks'] ?? []),
        ));
      }
      return courses;
    } catch (e) {
      print("解析失败: $e");
      return [];
    }
  }
}