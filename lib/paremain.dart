import 'package:flutter/material.dart';
import 'benrikansu.dart';
import 'pareset.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import 'parechatitiran.dart';

class PareHomeScreen extends StatefulWidget {
  final String userName;
  final String name; 
  final int userId;
  const PareHomeScreen({super.key, required this.userName, required this.name, required this.userId});

  @override
  State<PareHomeScreen> createState() => _PareHomeScreenState();
}

class _PareHomeScreenState extends State<PareHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _birdController;

  @override
  void initState() {
    super.initState();
    // 15秒かけて横断する設定。repeat() で無限に繰り返します。
    _birdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _birdController.dispose(); // 画面を閉じるときにメモリを解放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 239, 179),
      body: Stack(
        children: [
          // --- 1. 背景層：鳥が右から左へ無限ループ ---
          AnimatedBuilder(
            animation: _birdController,
            builder: (context, child) {
              // 右(1.5)から左(-1.5)へ移動。3.0は移動する距離の合計です。
              final double x = 4.7 - (_birdController.value * 10);
              // math.sin を使って上下に少しだけ揺らします（ふわふわ感）
              final double y = -0.9 + (math.sin(_birdController.value * math.pi * 4) * 0.02);

              return Align(
                alignment: Alignment(x, y),
                child: Lottie.asset(
                  'assets/kaku.json',
                  width: 300,
                ),
              );
            },
          ),

          // --- 2. 前面層：既存のメニューUI ---
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.05,
                  horizontal: size.width * 0.1,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '鶴寿日記',
                      style: TextStyle(
                        fontFamily: 'FudeFont',
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    MenuButton(label: '💬 チャット', color: const Color.fromARGB(255, 115, 0, 255), page: JijibabaListPage(userName: widget.userName, parentId: widget.userId, name: widget.name)),
                    SizedBox(height: size.height * 0.05),
                    // widget. をつけてアクセスするように修正しています
                    MenuButton(label: '⚙️ その他の機能', color: const Color.fromARGB(255, 255, 157, 0), page: PareSettingsPage(userName: widget.userName, name: widget.name, userId: widget.userId)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}