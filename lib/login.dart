import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'hozon.dart';
import 'paremain.dart';
import 'roll.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // ⭐ ロール選択用の状態変数（デフォルトは jijibaba）
  String selectedRole = 'jijibaba'; 

  bool isLoading = false;

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final userName = userNameController.text.trim();
    final password = passwordController.text;

    if (userName.isEmpty) {
      showSnack("ユーザーネームを入力してください");
      return;
    }

    if (password.length < 5) {
      showSnack("パスワードは5文字以上にしてください");
      return;
    }

    setState(() => isLoading = true);

    final body = {
      "username": userName,
      "password": password,
      "role": selectedRole,
    };

    try {
      final response = await ApiService.loginUser(body);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final int userId = json["user_id"];
        
        // ⭐ サーバーから返ってきた表示名（name）を受け取る（空なら userName）
        final String displayName = json["name"] ?? userName;

        // ⭐ サーバーから返ってきた role を受け取る（空なら selectedRole）
        final String role = json["role"] ?? selectedRole;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_name", userName);
        await prefs.setInt("user_id", userId);
        await prefs.setString("name", displayName); // 表示名を保存
        await prefs.setString("role", role); // role を保存

        if (!mounted) return;

        // ⭐ 返ってきた role で画面を打ち分ける
        if (role == "jijibaba") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                userName: userName,
                name: displayName,
                userId: userId,
              ),
            ),
          );
        } else if (role == "parent") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PareHomeScreen(
                userName: userName,
                name: displayName,
                userId: userId,
              ),
            ),
          );
        } else {
          showSnack("不明なロールです: $role");
        }
      } else {
        showSnack("ユーザーID または パスワードが違います");
      }
    } catch (e) {
      if (!mounted) return;
      showSnack("通信エラー: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ログイン")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: userNameController,
                decoration: const InputDecoration(
                  labelText: "ユーザーネーム",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "パスワード",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
              ),
              const SizedBox(height: 20),

              // ロール選択（SegmentedButton）
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'jijibaba',
                      label: Text('利用者'),
                      icon: Icon(Icons.person),
                    ),
                    ButtonSegment<String>(
                      value: 'parent',
                      label: Text('家族'),
                      icon: Icon(Icons.family_restroom),
                    ),
                  ],
                  selected: {selectedRole},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      selectedRole = newSelection.first;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ボタンエリア
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("ログイン"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleSelectPage(),
                        ),
                      );
                    },
                    child: const Text("新規登録"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}