import 'package:flutter/material.dart';
import 'package:kakujunikki/keisan.dart';
import 'package:kakujunikki/training.dart';
import 'benrikansu.dart';
import 'rule.dart';

class Noutore extends StatelessWidget {
  const Noutore({super.key});

  @override
  Widget build(BuildContext context) {
    // 画面サイズを取得
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 239, 179),
      body: SingleChildScrollView( // スクロール設定
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.14,
              horizontal: size.width * 0.1,
            ),
            child: Column(
              // mainAxisSize: MainAxisSize.min, // これを入れると中身にフィットします
              children: [
                const Text(
                  '脳トレ',
                  style: TextStyle(
                    fontFamily: 'FudeFont',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                // ↓ Flexibleを削除して普通のColumnにしました
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Rule()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        elevation: 5,
                      ),
                      child: const Text(
                        '遊び方',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'FudeFont',
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.06),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Training()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        elevation: 5,
                      ),
                      child: const Text(
                        'アナグラムクイズ',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'FudeFont',
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.06),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Keisan()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        elevation: 5,
                      ),
                      child: const Text(
                        '計算トレーニング',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'FudeFont',
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.09),
                    const HomeBackButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}