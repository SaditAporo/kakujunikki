import 'package:flutter/material.dart';
import 'login.dart';
import 'benrikansu.dart';

class UserChoicePage extends StatelessWidget {
  const UserChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー選択'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        // ✅ ログインボタンのお着替え
        CardButton(
        item: 'ログイン', // child ではなく item
        color: Colors.blue, // 好きな色を指定してね
        onTap: () { // onPressed ではなく onTap
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            );
        },
        ),
        const SizedBox(height: 20),

        // ✅ 新規登録ボタンのお着替え
        CardButton(
        item: '新規登録',
        color: Colors.green, // 好きな色を指定してね
        onTap: () {
            // 遷移先のページができたらここに書くか、
            // もしくは page: const SignUpPage() って直接指定しても動くよ！
        },
        ),
          ],
        ),
      ),
    );
  }
}