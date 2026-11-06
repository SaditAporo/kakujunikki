import 'package:flutter/material.dart';
import 'benrikansu.dart';
import 'diary.dart';
import 'history.dart';
import 'gohan.dart';
import 'set.dart';
import 'splash.dart';
import 'oomikuzi.dart';
import 'noutore.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

void main() {
  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '鶴寿日記',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

// HomeScreen を StatefulWidget に書き換えます
class HomeScreen extends StatefulWidget {
  final String userName;
  final String name;
  final int userId;
  const HomeScreen({super.key, required this.userName, required this.name, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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
              final double x = 1.5 - (_birdController.value * 3.0);
              // math.sin を使って上下に少しだけ揺らします（ふわふわ感）
              final double y = -0.8 + (math.sin(_birdController.value * math.pi * 4) * 0.05);

              return Align(
                alignment: Alignment(x, y),
                child: Lottie.asset(
                  'assets/kaku.json',
                  width: 150,
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
                    // widget. をつけてアクセスするように修正しています
                    MenuButton(label: '📕 日記を書く', color: Colors.blueAccent, page: DiaryPage(userName: widget.userName, name: widget.name, userId: widget.userId)),
                    SizedBox(height: size.height * 0.04),
                    MenuButton(label: '📅 過去の日記を見る', color: Colors.green, page: HistoryPage(userName: widget.userName, name: widget.name, userId: widget.userId)),
                    SizedBox(height: size.height * 0.04),
                    MenuButton(label: '🍚 ご飯の記録', color: Colors.yellow, page: Gohan(userName: widget.userName, name: widget.name, userId: widget.userId)),
                    SizedBox(height: size.height * 0.04),
                    MenuButton(label: '🥠 おみくじを引く', color: Colors.pinkAccent, page: OmikujiPage()),
                    SizedBox(height: size.height * 0.04),
                    MenuButton(label: '🧠 脳トレ', color: const Color.fromARGB(255, 171, 36, 181), page: Noutore()),
                    SizedBox(height: size.height * 0.04),
                    MenuButton(label: '⚙️ その他の機能', color: const Color.fromARGB(255, 255, 157, 0), page: SettingsPage(userName: widget.userName, name: widget.name, userId: widget.userId)),
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