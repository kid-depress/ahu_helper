import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import '../models/course.dart';

class ScheduleParser {
  /// 将 HTML 字符串转换为课程列表
  static List<Course> parseSchedule(String htmlString) {
    List<Course> courses = [];
    
    // 1. 将字符串解析为 DOM 文档对象
    var document = parse(htmlString);
    
    // 2. 找到存放课表的表格 (根据 AHU 系统常见的 class 查找)
    // 注意：如果学校网页结构变了，这里的选择器 'table.gridtable tr' 需要微调
    var rows = document.querySelectorAll('table.gridtable tr');
    
    // 如果没找到，尝试另一种常见的选择器
    if (rows.isEmpty) {
      rows = document.querySelectorAll('tr'); 
    }

    for (var row in rows) {
      var cells = row.querySelectorAll('td');
      
      // 过滤掉表头或者空行（通常课表一行至少有 4 个单元格）
      if (cells.length >= 4) {
        String name = cells[0].text.trim();
        // 排除掉像“课程名称”这样的标题行
        if (name == "课程名称" || name.isEmpty) continue;

        courses.add(Course(
          name: name,
          teacher: cells[1].text.trim(),
          time: cells[2].text.trim(),
          location: cells[3].text.trim(),
        ));
      }
    }
    
    return courses;
  }
}