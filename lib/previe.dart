import 'dart:io';
import 'package:flutter/foundation.dart'; // 📌 1. kIsWeb を使うためにインポートを追加
import 'package:flutter/material.dart';
import 'setumei.dart';

class ImageConfirmPage extends StatelessWidget {
  final String imagePath;
  final int userId;
  final String name;
  final String userName;
  final Map diary;

  const ImageConfirmPage({
    super.key, 
    required this.imagePath, 
    required this.userId,
    required this.userName,
    required this.name,
    required this.diary,
  });

  Future<void> _uploadAndSendLine(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoGuidePage(
          userName: userName, 
          userId: userId, 
          name: name, 
          diary: diary,
          imagePath: imagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "写真の確認", 
          style: TextStyle(fontFamily: 'FudeFont', fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.black87, // 写真が見やすいように背景を暗く
        child: Column(
          children: [
            // 撮影した写真を大きく表示
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: kIsWeb
                    ? Image.network(
                        imagePath, // 📌 2. Webの場合はブラウザで表示可能なURL(Blob URL)になっているため Image.network を使用
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        File(imagePath), // スマホ(iOS/Android)の場合は従来の File を使用
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            
            // 操作ボタンエリア
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 239, 179),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "この写真を日記と一緒に送りますか？",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // 撮り直しボタン
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text("撮り直す"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 送信ボタン
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _uploadAndSendLine(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text("送信する", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}