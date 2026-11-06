import 'package:flutter/material.dart';
import 'hozon.dart';
import 'chat.dart'; // 先ほど作成したチャット画面

class FamilyListPage extends StatelessWidget {
  final int userId;      // ログイン中の利用者ID (jijibaba_id)
  final String name; // ログイン中の利用者名
  final String userName; // ログイン中の利用者ユーザー名

  const FamilyListPage({
    super.key,
    required this.userId,
    required this.name,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 239, 179),
      appBar: AppBar(
        title: const Text(
          'ご家族とのおはなし',
          style: TextStyle(
            fontFamily: 'FudeFont',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange[600],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.getLinkedParents(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("読み込みエラー: ${snapshot.error}"));
          }

          final parents = snapshot.data ?? [];

          if (parents.isEmpty) {
            return const Center(
              child: Text(
                "まだ連携されているご家族がいません",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: parents.length,
            itemBuilder: (context, index) {
              final parent = parents[index];
              final parentId = parent['id'] as int;
              final parentName = parent['name']?.toString() ?? 'ご家族';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    parentName,
                    style: const TextStyle(
                      fontFamily: 'FudeFont',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.chat_bubble_outline, color: Colors.orange, size: 30),
                  onTap: () {
                    // タップしたご家族とのチャット画面へ移動
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          currentUserId: userId,
                          targetUserId: parentId,
                          targetName: parentName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}