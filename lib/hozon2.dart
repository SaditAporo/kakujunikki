import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class HozonPage extends StatelessWidget {
  static const baseUrl = "http://163.43.128.95:5000";
  final Uint8List imageBytes;
  final int userId; 

  const HozonPage({super.key, required this.imageBytes, required this.userId});

  Future<void> uploadImage(BuildContext context, Uint8List bytes) async {
    final uri = Uri.parse('$baseUrl/upload_meal_image');

    try {
      final lineRes = await http.get(Uri.parse('$baseUrl/get_line_id/$userId'));
      String? lineId;
      if (lineRes.statusCode == 200) {
        final data = jsonDecode(lineRes.body);
        lineId = data['line_user_id'];
      }

      final request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId.toString()
        ..fields['line_id'] = lineId ?? "" 
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'meal_${userId}_${DateTime.now().millisecondsSinceEpoch}.png',
            contentType: MediaType('image', 'png'),
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('サーバーに保存し、LINEへ通知しました！')));
        await Future.delayed(const Duration(seconds: 1));
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        throw Exception('Status: ${response.statusCode}');
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('アップロード失敗: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('食事記録の確認'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('この内容でLINEに送りますか？', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Image.memory(imageBytes),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {Navigator.popUntil(context, (route) => route.isFirst);
},
                  child: const Text('やり直す'),
                ),
                ElevatedButton(
                  onPressed: () => uploadImage(context, imageBytes),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('送信して保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}