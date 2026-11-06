import 'dart:math';
import 'package:flutter/material.dart';

class Training extends StatefulWidget {
  const Training({super.key});

  @override
  State<Training> createState() => _TrainingState();
}

class _TrainingState extends State<Training> {
  final List<Map<String, String>> _data = [
    {'display': 'アリクイムース', 'answer': 'アイスクリーム'},
    {'display': 'クロタンスサー', 'answer': 'サンタクロース'},
    {'display': 'つまりたばたな', 'answer': 'たなばたまつり'},
  ];

  late Map<String, String> _current;
  List<Map<String, dynamic>> _shuffledChars = []; // インデックス付きの文字リスト
  final List<int> _usedIndices = []; // 押されたボタンのインデックスを保存
  String _input = ""; // ユーザーが選択した文字
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _nextQuestion();
  }

// --- 問題セットの処理を修正 ---
void _nextQuestion() {
  setState(() {
    _current = _data[_random.nextInt(_data.length)];
    _input = "";
    _usedIndices.clear(); // 使用済みリストをリセット

    // 答えの文字にインデックス（番号）を振ってからシャッフル
    List<String> chars = _current['answer']!.split('');
    _shuffledChars = List.generate(chars.length, (index) {
      return {'char': chars[index], 'id': index};
    });
    _shuffledChars.shuffle();
  });
}

  void _checkInput() {
    if (_input == _current['answer']) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('正解！', style: TextStyle(fontFamily: 'FudeFont', fontSize: 30, color: Colors.pink)),
          content: const Text('素晴らしい！', style: TextStyle(fontFamily: 'FudeFont', fontSize: 24)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _nextQuestion(); // 次の問題へ
              },
              child: const Text('次の問題'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('違います！もう一度並び替えてみてね')),
      );
      setState(() => _input = "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 239, 179),
      appBar: AppBar(
        title: const Text('アナグラム', style: TextStyle(fontFamily: 'FudeFont', fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 1),
            // お題の文字
            Text(
              "お題: ${_current['display']}",
              style: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // ユーザーが入力した文字を表示する枠
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _input,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
              ),
            ),
            const SizedBox(height: 40),
            // バラバラの文字ボタンたち
            Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _shuffledChars.map((item) {
              int id = item['id'];
              String char = item['char'];

              // もし使用済みリストにこのIDが含まれていたら、空の箱（消えた状態）にする
              if (_usedIndices.contains(id)) {
                return const SizedBox(width: 60, height: 60); // 消えた場所を詰めたくないならSizedBox.shrink()
              }

              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _input += char;        // 文字を追加
                    _usedIndices.add(id);   // IDを使用済みリストに追加
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(60, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: const BorderSide(width: 2),
                ),
                child: Text(char, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
            const SizedBox(height: 40),
            // アクションボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                onPressed: () => setState(() {
                  _input = "";
                  _usedIndices.clear(); // ボタンを全部復活させる
                }),
                child: const Text('やり直し', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
                ElevatedButton(
                  onPressed: () {
                    _checkInput();
                    _usedIndices.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text('回答', style: TextStyle(fontSize: 24, color: Colors.white)),
                ),
              ],
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}