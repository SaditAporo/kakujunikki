import 'package:flutter/material.dart';
import 'hozon.dart';
import 'kakonikki.dart';

class DiaryTitleListPage extends StatelessWidget {
  final String date;
  final int userId;
  final String userName;

  const DiaryTitleListPage({
    super.key,
    required this.date,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 239, 179),
      appBar: AppBar(
  title: Text(
    // 2024-01-26 を分割して組み替える
    '${date.split("-")[0]}年${date.split("-")[1]}月${date.split("-")[2]}日',
    style: const TextStyle(
      fontFamily: 'FudeFont',
      fontSize: 25,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: Colors.orange[600],
),
      body: FutureBuilder(
        future: ApiService.getDiaryTitles(userId, date),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text("この日の日記はありません"));
          }

          // タイトルが空のものを除外
          final List diaries = (data as List)
              .where((d) => d['title'] != null && d['title'].toString().trim().isNotEmpty)
              .toList();

          if (diaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.book_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'この日の日記はありません',
                    style: TextStyle(fontFamily: 'FudeFont',fontSize: 24, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
  itemCount: diaries.length,
  itemBuilder: (_, i) {
    return Card( // カードにすると区切りが分かりやすくておすすめです
          elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        // titleの中身をCenterで囲むと、文字が真ん中にきます
        title: Center(
          child: Text(
            diaries[i]['title'],
            style: const TextStyle(
              fontFamily: 'FudeFont', 
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KakonikkiPage(
                diaryId: diaries[i]['id'],
                userId: userId,
                userName: userName,
                title: diaries[i]['title'],
              ),
            ),
          );
        },
      ),
    );
  },
);
        },
      ),
    );
  }
}