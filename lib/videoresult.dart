import 'package:flutter/material.dart';
import 'hozon.dart'; 
import 'main.dart';

class VideoResultPage extends StatefulWidget {
  final String videoPath;
  final int userId;
  final String name;
  final Map diary;
  final String imagePath;
  final String userName;

  const VideoResultPage({super.key, required this.videoPath, required this.userId, required this.name, required this.diary, required this.imagePath, required this.userName});

  @override
  State<VideoResultPage> createState() => _VideoResultPageState();
}

class _VideoResultPageState extends State<VideoResultPage> {
  bool _isUploading = true; // 最初はアップロード中

  @override
  void initState() {
    super.initState();
    _startUpload(); // 画面が開いたら即座にアップロード開始
  }

  Future<void> _startUpload() async {
    try {
      final response = await ApiService.uploadDiary(
        widget.userId, 
        widget.videoPath, 
        widget.name,
        Map<String, dynamic>.from(widget.diary),
        widget.imagePath,
        widget.userName
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("日記を送りました！")),
        );
      } else {
        throw Exception("サーバーエラー: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("送信に失敗しました: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 送信中はぐるぐる、終わったらチェックマーク
            _isUploading 
              ? const CircularProgressIndicator()
              : const Icon(Icons.check_circle, color: Colors.green, size: 80),
            
            const SizedBox(height: 20),
            Text(
              _isUploading ? "日記を送信中..." : "日記を送信しました！", 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            
            const SizedBox(height: 40),
            // 送信が終わるまで「ホームへ戻る」は無効化するか、あるいは終わってから出す
            if (!_isUploading)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen( // 👈 お使いのホーム画面のクラス名
                        userId: widget.userId,
                        userName: widget.userName,
                        name: widget.name,
                      ),
                    ),
                    (route) => false, // ログイン画面含む過去の履歴を全て消去する
                  );
                },
                child: const Text("ホーム画面へ戻る"),
              )
          ],
        ),
      ),
    );
  }
}