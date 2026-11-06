import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'login.dart';
import 'paremain.dart'; // ⭐ PareHomeScreen 用にインポートを追加

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString("user_name");
    final name = prefs.getString("name");
    final userId = prefs.getInt("user_id");
    final role = prefs.getString("role");

    // スプラッシュ表示用の微小なウェイト
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // 💡 【テスト用】true にすると、未ログインでも強制的に通過させます
    // （確認が終わったら false に戻してください）
    bool bypassLogin = true; 

    // ログイン情報がある、またはバイパスが有効な場合
    if ((userName != null && userId != null) || bypassLogin) {
      // ⚠️ 未ログイン時（null時）にアプリが落ちないよう、ダミー値を設定
      final effectiveUserName = userName ?? "test_user";
      final displayName = name ?? effectiveUserName;
      final effectiveUserId = userId ?? 999;

      // ⭐ role に応じて遷移先を打ち分け
      if (role == "parent") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PareHomeScreen(
              userName: effectiveUserName,
              name: displayName,
              userId: effectiveUserId,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              userName: effectiveUserName,
              name: displayName,
              userId: effectiveUserId,
            ),
          ),
        );
      }
    } else {
      // 未ログイン状態 → ログイン画面へ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}