import 'package:html/parser.dart' show parse;
import 'net_client.dart';
import '../utils/des_util.dart'; // 引入刚才的文件

class AuthService {
  final NetClient _client = NetClient();

  Future<bool> login(String username, String password) async {
    try {
      // 1. 访问登录页，获取 lt 和 execution
      String html = await _client.get("/student/sso/login"); // ⚠️ 确认地址
      var document = parse(html);
      
      String? lt = document.querySelector("input[name='lt']")?.attributes['value'];
      String? execution = document.querySelector("input[name='execution']")?.attributes['value'];
      String? eventId = document.querySelector("input[name='_eventId']")?.attributes['value'] ?? "submit";

      if (lt == null || execution == null) {
        print("❌ 无法获取 lt 或 execution");
        return false;
      }

      print("✅ 获取到参数: lt=$lt");

      // 2. 🔐 执行核心加密 (完全照搬 JS 的逻辑)
      // JS代码: strEnc(u+p+lt , '1' , '2' , '3')
      String rsa = DesUtil.encrypt(username + password + lt, '1', '2', '3');

      // 3. 构造表单数据 (参数名必须和 login.js 里的 device 请求一致)
      var formData = {
        "rsa": rsa,             // 密文
        "ul": username.length,  // 学号长度
        "pl": password.length,  // 密码长度
        "lt": lt,
        "execution": execution,
        "_eventId": eventId,
      };

      // 4. 发送请求
      String response = await _client.post("/student/sso/login", data: formData);

      // 5. 验证结果
      if (response.contains("密码错误") || response.contains("验证码")) {
        print("❌ 登录失败：密码错误或需要验证码");
        return false;
      }

      print("🎉 登录成功！");
      return true;

    } catch (e) {
      print("💥 异常: $e");
      return false;
    }
  }
}