import 'package:flutter/material.dart';

class Course {
  final String name;
  final String teacher;
  final String location;
  final int weekday;      // 周几 (1-7)
  final int startTime;    // 开始节次
  final int length;       // 持续节数 (length)
  final List<int> weekIndexes; // 周次索引列表
  final Color color;

  Course({
    required this.name,
    required this.teacher,
    required this.location,
    required this.weekday,
    required this.startTime,
    required this.length,
    required this.weekIndexes,
  }) : color = _generateColor(name);

  static Color _generateColor(String name) {
    final List<Color> palette = [
      const Color(0xFF99CCFF), const Color(0xFFFFCC99),
      const Color(0xFFFF9999), const Color(0xFF99CC99),
      const Color(0xFFCC99FF), const Color(0xFFFF99CC),
    ];
    return palette[name.hashCode.abs() % palette.length].withOpacity(0.9);
  }
}