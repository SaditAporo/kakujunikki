import 'package:flutter/material.dart';
import 'itiran.dart';

class HistoryPage extends StatefulWidget {
  final String userName;
  final String name;
  final int userId;
  const HistoryPage({super.key , required this.userName, required this.name, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 239, 179),
      appBar: AppBar(title: const Text('過去の日記を見る',
      style: TextStyle(
      fontFamily: 'FudeFont', // 筆文字に設定
      fontSize: 26,           // 少し大きめにすると見栄えが良いです
      fontWeight: FontWeight.bold,
    ),), backgroundColor: Colors.orange[600]),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(fixedSize: const Size(250, 80), // 横幅250、高さ80
            backgroundColor: Colors.orange[700], // ボタンの色
            foregroundColor: Colors.black, // 文字の色
            elevation: 10, // 影を強くして立体感を出す
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),),
              textStyle: const TextStyle(
              fontFamily: 'FudeFont',
              fontSize: 24, // 文字も大きく！
              fontWeight: FontWeight.bold,
            ),),
            child: const Text('日付を選択'),
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );

            if (selectedDate == null) return;

            final dateStr =
                "${selectedDate.year}-${selectedDate.month.toString().padLeft(2,'0')}-${selectedDate.day.toString().padLeft(2,'0')}";

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DiaryTitleListPage(date: dateStr, userId: widget.userId,userName: widget.userName),
              ),
            );
          },
        ),
      ),
    );
  }
}