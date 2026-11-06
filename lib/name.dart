import 'package:flutter/material.dart';
import 'package:kakujunikki/hozon.dart';
import 'main.dart';
import 'dart:convert';
import 'paremain.dart';

class NamePage extends StatefulWidget {
  final String userName; // ユーザーID (英数字)
  final String password; // パスワード
  final String role;     // ロール (jijibaba / parent)

  const NamePage({
    super.key,
    required this.userName,
    required this.password,
    required this.role,
  });

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  // ⭐ 名前（表示名・日本語）入力用のコントローラー
  final TextEditingController nameController = TextEditingController();

  bool isLoading = false;

  Future<void> registerUser() async {
    final displayName = nameController.text.trim();

    // 日本語名の入力チェック
    if (displayName.isEmpty) {
      showMessage("お名前を入力してください");
      return;
    }

    setState(() => isLoading = true);

    // ⭐ 前画面から渡されたデータと、入力されたお名前をまとめて送信
    final body = {
      "username": widget.userName,
      "password": widget.password,
      "role": widget.role,
      "name": displayName, // ⭐ 日本語の表示名を追加
    };

    try {
      final response = await ApiService.registerUser(body);

      if (!mounted) return;

      if (response.body.isEmpty) {
        showMessage("サーバーからのレスポンスが空です (${response.statusCode})");
        return;
      }

      Map<String, dynamic> json;
      try {
        json = jsonDecode(response.body);
      } catch (e) {
        showMessage("サーバーエラー: 不正なデータが返りました (${response.statusCode})");
        return;
      }

      if (response.statusCode == 200 && json["status"] == "ok") {
        showMessage("登録しました！");

        final int userId = (json["user_id"] is int)
            ? json["user_id"]
            : int.parse(json["user_id"].toString());

        final String role = json["role"] ?? widget.role;

        // メイン画面へ遷移する際、表示名 (displayName) を渡す
        if (role == "jijibaba") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: widget.userName, // ユーザーIDを表示
                name: displayName, // お名前を表示
                userId: userId,
              ),
            ),
          );
        } else if (role == "parent") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PareHomeScreen(
                userName: widget.userName, // ユーザーIDを表示
                name: displayName, // お名前を表示
                userId: userId,
              ),
            ),
          );
        } else {
          showMessage("不明なロールです: $role");
        }
      } else if (response.statusCode == 409) {
        showMessage("このユーザーIDは既に使われています");
      } else {
        showMessage("登録失敗: ${json['message'] ?? json['error'] ?? '不明なエラー'}");
      }
    } catch (e) {
      if (!mounted) return;
      showMessage("通信エラー: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("お名前の登録")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 選択された種別の確認タグ
              Chip(
                avatar: Icon(
                  widget.role == 'jijibaba'
                      ? Icons.edit_note
                      : Icons.family_restroom,
                ),
                label: Text(
                  widget.role == 'jijibaba' ? "種別: 日記利用者" : "種別: ご家族",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // 前画面で設定した ID の表示確認
              Text(
                "ユーザーID: ${widget.userName}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // --- お名前（日本語対応）入力フォーム ---
              const Text(
                "アプリ内で表示するお名前を教えてください",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "お名前（例：山田 太郎 / おじいちゃん）",
                  border: OutlineInputBorder(),
                  hintText: "日本語やひらがなも入力できます",
                ),
                // 日本語入力用に文字制限（inputFormatters）を外しています
              ),
              const SizedBox(height: 28),

              // --- 登録・送信ボタン ---
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
                      : const Text("登録を完了する", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}