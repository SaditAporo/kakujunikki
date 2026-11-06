import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = "https://kurume-kosen01.sakura.ne.jp/kakujunik"; // FlaskサーバーのURL

  static Future<http.Response> registerUser(Map user) {
    return http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user),
    );
  }

  // 連携用 API（ご家族と日記利用者の紐付け）
  static Future<http.Response> linkUser(Map<String, dynamic> body) {
    return http.post(
      Uri.parse("$baseUrl/link_user"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> lineId(Map body) {

    return http.post(
        Uri.parse("$baseUrl/set_line_user"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
  }


  static Future<http.Response> loginUser(Map body) {

    return http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
  }

  static Future<String?> getLineId(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_line_id/$userId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["line_user_id"]; 
    }

    return null;
  }

  static Future<List<Map<String, dynamic>>> getDiaryTitles(
  int userId,
  String date,
) async {
  final response = await http.get(
    Uri.parse("$baseUrl/diary/by_date/$userId/$date"),
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  return [];
}

static Future<Map<String, dynamic>?> getDiary(int diaryId) async {
  final response = await http.get(
    Uri.parse("$baseUrl/diary/$diaryId"),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data as Map<String, dynamic>;
  }

  return null; // 見つからなかった場合
}

  // 1. チャット履歴の取得
static Future<List<dynamic>> getChat(int user1Id, int user2Id) async {
    final response = await http.get(Uri.parse('$baseUrl/get_chat/$user1Id/$user2Id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // 2. メッセージの送信
static Future<bool> sendMessage(int senderId, int receiverId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send_message'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
      }),
    );
    return response.statusCode == 200;
  }

  // 3. リアクション（スタンプ）の追加
static Future<bool> addReaction(int messageId, String reaction) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_reaction'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message_id': messageId,
        'reaction': reaction,
      }),
    );
    return response.statusCode == 200;
  }

// 連携されている家族（parent）の一覧を取得
  static Future<List<Map<String, dynamic>>> getLinkedParents(int jijibabaId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_linked_parents/$jijibabaId"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }

    return [];
  }

  // 家族（parent）から見た連携利用者（jijibaba）の一覧を取得
  static Future<List<Map<String, dynamic>>> getLinkedJijibabas(int parentId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_linked_jijibabas/$parentId"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }

    return [];
  }

static Future<http.StreamedResponse> uploadDiary(
  int userId, 
  String? videoPath,  // 動画がない場合も考慮して nullable に
  String name,
  Map<String, dynamic> diary, // フラットな Map も扱えるように調整
  String? imagePath,  // 画像がない場合も考慮して nullable に
  String userName,
) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse("$baseUrl/upload_all"),
  );
  
  // 1. 基本情報
  request.fields['user_id'] = userId.toString();
  request.fields['user_name'] = userName;
  request.fields['name'] = name;

  // 2. 日記の各種データ (diary['diary'] があればそれを使用、なければ diary 自体を使用)
  final Map<String, dynamic> diaryContent = 
      (diary.containsKey('diary') && diary['diary'] is Map<String, dynamic>)
          ? diary['diary'] as Map<String, dynamic>
          : diary;

  diaryContent.forEach((key, value) {
    if (value != null) {
      request.fields[key] = value.toString();
    }
  });

  // 3. 画像ファイル（パスが存在し、空でない場合のみ追加）
  if (imagePath != null && imagePath.isNotEmpty) {
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
  }

  // 4. 動画ファイル（パスが存在し、空でない場合のみ追加）
  if (videoPath != null && videoPath.isNotEmpty) {
    request.files.add(await http.MultipartFile.fromPath('video', videoPath));
  }

  return await request.send();
}

}

