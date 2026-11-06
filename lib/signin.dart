import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'name.dart';

class SigninPage extends StatefulWidget {
  // ⭐ 遷移元から role を受け取る
  final String role;
  
  const SigninPage({super.key, required this.role});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> registerUser() async {
    final userName = userNameController.text.trim();
    final password = passwordController.text;

    // --- 1. 入力チェック ---
    if (userName.isEmpty) {
      showMessage("ユーザーネームを入力してください");
      return;
    }

    if (password.length < 5) {
      showMessage("パスワードは5文字以上にしてください");
      return;
    }

    final String role = widget.role;

    // --- 2. NamePage への画面遷移（userName, password, role を渡す） ---
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NamePage(
          userName: userName,
          password: password, // ⭐ パスワードを追加
          role: role,         // ⭐ role を渡す
        ),
      ),
    );
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("新規アカウント登録")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 選択された種別の確認タグ
              Chip(
                avatar: Icon(
                  widget.role == 'jijibaba' ? Icons.edit_note : Icons.family_restroom,
                ),
                label: Text(
                  widget.role == 'jijibaba' ? "種別: 日記利用者" : "種別: ご家族",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // --- ユーザーID ---
              TextField(
                controller: userNameController,
                decoration: const InputDecoration(
                  labelText: "ユーザーID（英数字のみ(例：ojichan123)）",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
              ),
              const SizedBox(height: 20),

              // --- パスワード ---
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: "パスワード（5文字以上）",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                obscureText: true,
              ),
              const SizedBox(height: 28),

              // --- 登録ボタン ---
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("アカウントを登録する", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}