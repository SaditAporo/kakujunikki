import 'package:flutter/material.dart';
import 'hozon.dart';
import 'chat.dart';

class JijibabaListPage extends StatelessWidget {
  final int parentId; // ログイン中の保護者ID
  final String name; // ログイン中の保護者名
  final String userName; // ログイン中の保護者ユーザー名

  const JijibabaListPage({
    super.key,
    required this.parentId,
    required this.name,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャットする人'),
        backgroundColor: Colors.orange[600],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.getLinkedJijibabas(parentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("エラー: ${snapshot.error}"));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(
              child: Text(
                "連携されている利用者がいません\nQRコードやID連携を行ってください",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final jijibabaId = item['id'] as int;
              final name = item['name']?.toString() ?? '利用者';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("ID: $jijibabaId"),
                  trailing: const Icon(Icons.chat),
                  onTap: () {
                    // 選択した利用者のチャット画面へ遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          currentUserId: parentId,     // 自分のID (parent)
                          targetUserId: jijibabaId,   // 相手のID (jijibaba)
                          targetName: name,
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