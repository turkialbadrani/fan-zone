
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/points_service.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiAssistantScreen extends StatefulWidget {
  @override
  _AiAssistantScreenState createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final opinionController = TextEditingController();
  final characterController = TextEditingController();
  final formationController = TextEditingController();
  final matchStatsController = TextEditingController();
  final freeChatController = TextEditingController();

  String selectedPersona = 'مشجع متعصب';
  String response = '';

  Future<void> sendToGPT(String prompt, {int points = 0}) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer \$apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-4o',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'temperature': 0.8
    });

    final res = await http.post(url, headers: headers, body: body);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      PointsService().addPoints(points);
        setState(() {
        response = data['choices'][0]['message']['content'];
      });
    } else {
      setState(() {
        response = 'حدث خطأ في الاتصال بـ GPT';
      });
    }
  }

  Widget buildSection(String title, TextEditingController controller, VoidCallback onPressed, {Widget? extra}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        if (extra != null) extra,
        TextField(controller: controller, maxLines: null),
        SizedBox(height: 8),
        ElevatedButton(onPressed: onPressed, child: Text("إرسال")),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مساعد الذكاء الصناعي')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildSection(
              '1. تحليل رأي الجمهور',
              opinionController,
              () => sendToGPT("حلل رأي هذا المشجع كمحلل خبير: \${opinionController.text}", points: 5),
            ),
            buildSection(
              '2. رد باسم لاعب أو مشجع',
              characterController,
              () => sendToGPT("رد كـ \$selectedPersona على هذا النص: \${characterController.text}", points: 3),
              extra: DropdownButton<String>(
                value: selectedPersona,
                items: ['مشجع متعصب', 'كريستيانو', 'مدرب', 'معلق رياضي']
                    .map((e) => DropdownMenuItem(child: Text(e), value: e))
                    .toList(),
                onChanged: (value) => setState(() => selectedPersona = value!),
              ),
            ),
            buildSection(
              '3. اقتراح تشكيلة مثالية',
              formationController,
              () => sendToGPT("اقترح تشكيلة مثالية من 11 لاعب بناءً على هؤلاء: \${formationController.text}", points: 4),
            ),
            buildSection(
              '4. تحليل مباراة أو إحصائيات',
              matchStatsController,
              () => sendToGPT("حلل هذه الإحصائيات كمحلل رياضي: \${matchStatsController.text}", points: 5),
            ),
            buildSection(
              '5. دردشة رياضية حرة',
              freeChatController,
              () => sendToGPT("تحدث كمشجع أو محلل عن: \${freeChatController.text}", points: 2),
            ),
            SizedBox(height: 20),
            Text('📢 الرد:', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10)
              ),
              child: Text(response),
            ),
          ],
        ),
      ),
    );
  }
}
