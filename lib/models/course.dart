class Course {
  final String name;     // 课程名
  final String teacher;  // 教师
  final String location; // 地点
  final String time;     // 上课时间（例如：周一第1-2节）

  Course({
    required this.name,
    required this.teacher,
    required this.location,
    required this.time,
  });
}