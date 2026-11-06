import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'benrikansu.dart';
import 'lineget.dart';
import 'splash.dart';

class SettingsPage extends StatelessWidget {
  final String userName;
  final String name;
  final int userId;
  const SettingsPage({super.key, required this.userName, required this.name, required this.userId});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      '連携QRコード表示',
      'ログアウト',
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 239, 179),
      appBar: AppBar(title: const Text('その他の機能', style: TextStyle(fontFamily: 'FudeFont', fontSize: 28, fontWeight: FontWeight.bold)), backgroundColor: Colors.orange[600]),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2,
        padding: const EdgeInsets.all(16),
        children: [
          // 連携QRコード表示
          CardButton(
            item: items[0],
            page: QrPage(userName: userName,name: name, userId: userId),
            color: Colors.blue,
          ),

          // ログアウト
          CardButton(
            item: '🚪 ログアウト',
            color: Colors.redAccent,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}