import 'package:flutter/material.dart';

class Rule extends StatelessWidget {
  const Rule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 239, 179),
      appBar: AppBar(title: const Text('ルール', style: TextStyle(fontFamily: 'FudeFont', fontSize: 30, fontWeight: FontWeight.bold),),backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            RuleSection(
              title: 'アナグラムクイズ',
              description: '文字を並び替えて、正しい単語を作るクイズ。一回ずつ文字のパネルをタップし、正しい言葉を完成させよ。',
            ),
            SizedBox(height: 34),
            RuleSection(
              title: '計算トレーニング',
              description: '足し算、引き算、掛け算、割り算の問題を10問出題。パネルを使って正しく答えよ。',
            ),
          ],
        ),
      ),
    );
  }
}

class RuleSection extends StatelessWidget {
  final String title;
  final String description;

  const RuleSection({
    super.key,
    required this.title,
    required this.description,
  });

  @override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Container(
      // --- ここから枠線の設定 ---
      padding: const EdgeInsets.all(16), // 枠の内側の余白
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5), // 背景を少し明るく（任意）
        border: Border.all(
          color: Colors.black, // 線の色
          width: 2,            // 線の太さ
        ),
        borderRadius: BorderRadius.circular(8), // 角を少し丸く（完全に四角なら0）
      ),
      // --- ここまで ---
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 内容に合わせた高さにする
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'FudeFont',
              fontSize: 29,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    ),
  );
}
}