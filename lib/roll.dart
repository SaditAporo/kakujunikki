import 'package:flutter/material.dart';
import 'signin.dart';

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage> {
  String selectedRole = 'jijibaba';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("アカウント種別の選択")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "利用目的を選んでください",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // ⭐ RadioGroup で囲んで状態とイベントをまとめて管理
            RadioGroup<String>(
              groupValue: selectedRole,
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedRole = val);
                }
              },
              child: Column(
                children: [
                  Card(
                    elevation: selectedRole == 'jijibaba' ? 4 : 1,
                    child: ListTile(
                      leading: const Icon(Icons.edit_note, size: 36),
                      title: const Text("日記を利用する方"),
                      subtitle: const Text("ご本人が日記を書いたり写真・動画を閲覧します"),
                      trailing: const Radio<String>(
                        value: 'jijibaba',
                      ),
                      onTap: () => setState(() => selectedRole = 'jijibaba'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: selectedRole == 'parent' ? 4 : 1,
                    child: ListTile(
                      leading: const Icon(Icons.family_restroom, size: 36),
                      title: const Text("ご家族（保護者）の方"),
                      subtitle: const Text("日記の閲覧や見守りを行うご家族用アカウントです"),
                      trailing: const Radio<String>(
                        value: 'parent',
                      ),
                      onTap: () => setState(() => selectedRole = 'parent'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SigninPage(role: selectedRole),
                    ),
                  );
                },
                child: const Text("次へ", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}