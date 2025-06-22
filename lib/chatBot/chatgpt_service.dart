// lib/chatgpt_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGPTService {
  final String apiKey =
      '';

  // ✅ وصف التطبيق كمساعد داخلي ذكي
  static const String _systemPrompt = '''
أنت مساعد ذكي داخل تطبيق يسمى "CodeMaster".
مهمتك هي الرد على استفسارات المستخدمين المتعلقة بالتطبيق، وشرح ميزاته بشكل مبسّط وواضح.

معلومات التطبيق:
- CodeMaster هو تطبيق تعليمي يساعد المستخدمين على تعلم البرمجة من خلال واجهة سهلة وواضحة.
- يحتوي على دورات تعليمية في لغات برمجة متنوعة مثل: Python، JavaScript، Dart.
- يوجد نظام اشتراك بسيط يمنح المستخدم إمكانية الوصول الكامل إلى المحتوى.
- في الصفحة الرئيسية تظهر الدورات الجديدة، والحالة التعليمية للمستخدم (مثل: Ongoing وCompleted).
- التطبيق يشمل تبويبات رئيسية: الصفحة الرئيسية، الدورات، المفضلة، والملف الشخصي.
- يمكن للمستخدمين سؤالك عن أي ميزة في التطبيق، أو طلب توجيه للمساعدة.

إذا سألك المستخدم عن "شرح التطبيق" أو "وش يسوي التطبيق" أو أي شيء مشابه، فاشرح له هذه المعلومات بلغة مبسطة وسهلة الفهم.
''';

  Future<String> sendMessage(String message) async {
    const url = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": _systemPrompt},
          {"role": "user", "content": message},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      return '❌ حدث خطأ أثناء الاتصال: ${response.statusCode}';
    }
  }
}