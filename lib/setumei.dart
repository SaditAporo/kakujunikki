import 'package:flutter/material.dart';
import 'mmovie.dart';

class VideoGuidePage extends StatelessWidget {
  final int userId;
  final String name;
  final String userName;
  final Map diary;
  final String imagePath;

  const VideoGuidePage({super.key, required this.userId, required this.name, required this.userName, required this.diary, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 239, 179),
      appBar: AppBar(title: const Text("動画の準備", style: TextStyle(fontFamily: 'FudeFont', fontSize: 28, fontWeight: FontWeight.bold)), backgroundColor: Colors.orange[600]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "ボタンを押して、カウントダウンが始まったら\n家族に一言メッセージをお願いします",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // 自動撮影画面へ移動
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AutoVideoRecorderPage(
                    userId: userId, userName: userName, name: name, diary: diary, imagePath: imagePath
                  )),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 199, 18, 30),foregroundColor: Colors.black,padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),),
              child: const Text("撮影をはじめる", style: TextStyle(fontFamily: 'FudeFont', fontSize: 23,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
}