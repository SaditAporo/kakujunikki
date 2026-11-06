import 'package:flutter/material.dart';
import 'hozon.dart';

class KakonikkiPage extends StatelessWidget {
  final int diaryId;
  final int userId;
  final String userName;
  final String title;

  const KakonikkiPage({
    super.key,
    required this.diaryId,
    required this.userId,
    required this.userName,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 239, 179),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'FudeFont',
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange[600],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: ApiService.getDiary(diaryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("読み込みに失敗しました: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("日記が見つかりません"));
          }

          final diary = snapshot.data!;

          // --- 日付の変換処理をここで行う ---
          DateTime? dt = diary['date'] != null ? DateTime.tryParse(diary['date'].toString()) : null;
          String dateStr = dt != null
              ? "${dt.year}年${dt.month}月${dt.day}日 \n          ${dt.hour.toString().padLeft(2, '0')}時${dt.minute.toString().padLeft(2, '0')}分"
              : "";

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    diary['title']?.toString() ?? '',
                    style: const TextStyle( fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "日付: $dateStr",
                    style: const TextStyle( fontSize: 20),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "天気: ${diary['weather']?.toString() ?? ''}  /  気分: ${diary['mood']?.toString() ?? ''}",
                    style: const TextStyle( fontSize: 20),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "血圧(上/下/脈): \n ${diary['blood_pressure']?.toString() ?? ''}",
                    style: const TextStyle( fontSize: 20),
                  ),
                   SizedBox(height: 15),
                  Text(
                    "体温: ${diary['temperature']?.toString() ?? ''}℃",
                    style: const TextStyle( fontSize: 20),
                  ),
                  const Divider(height: 40, thickness: 1, color: Colors.orange),
                  Text(
                    diary['event']?.toString() ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle( fontSize: 24, height: 1.6),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}