import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // 📌 変更: qr_code_scanner をインポート
import 'dart:convert';
import 'hozon.dart'; 

class ScanLinkPage extends StatefulWidget {
  final int userId;
  final String userName;
  final String name;

  const ScanLinkPage({super.key, required this.userId, required this.userName, required this.name});

  @override
  State<ScanLinkPage> createState() => _ScanLinkPageState();
}

class _ScanLinkPageState extends State<ScanLinkPage> {
  // 📌 変更: QRViewController と、カメラビュー用の GlobalKey を用意
  QRViewController? scannerController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  
  bool isProcessing = false; // 二重読み取り・連続送信防止フラグ

  @override
  void reassemble() {
    super.reassemble();
    // Androidでのホットリロード時にカメラが止まってしまう対策
    if (scannerController != null) {
      scannerController!.pauseCamera();
    }
    scannerController?.resumeCamera();
  }

  @override
  void dispose() {
    scannerController?.dispose();
    super.dispose();
  }

  // 📌 変更: QRView が生成されたときの初期化処理
  void _onQRViewCreated(QRViewController controller) {
    scannerController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isProcessing) return;
      
      final String? scannedUserName = scanData.code;
      if (scannedUserName == null || scannedUserName.trim().isEmpty) {
        return;
      }

      // 読み取り成功時の処理を実行
      _handleScannedData(scannedUserName);
    });
  }

  // QRコード読み取り時のダイアログ・処理
  Future<void> _handleScannedData(String scannedUserName) async {
    setState(() => isProcessing = true);
    scannerController?.pauseCamera(); // カメラを一時停止

    // 連携確認ダイアログを表示
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("連携の確認"),
        content: Text("「$scannedUserName」さんと連携しますか？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("キャンセル"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("連携する"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _sendLinkRequest(scannedUserName);
    } else {
      // キャンセルされた場合は読み取り再開
      setState(() => isProcessing = false);
      scannerController?.resumeCamera();
    }
  }

  // Flask サーバーの ApiService.linkUser を呼び出す
  Future<void> _sendLinkRequest(String targetUserName) async {
    final body = {
      "parent_id": widget.userId,
      "jijibaba_username": targetUserName,
    };

    try {
      final response = await ApiService.linkUser(body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("連携が成功しました！")),
        );
        Navigator.pop(context, true);
      } else {
        Map<String, dynamic> json = {};
        try {
          json = jsonDecode(response.body);
        } catch (_) {}

        final errorMsg = json["message"] ?? json["error"] ?? "連携に失敗しました (${response.statusCode})";
        _showErrorDialog(errorMsg);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog("通信エラーが発生しました: $e");
    }
  }

  // エラー時ダイアログ＆再試行案内
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("エラー"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => isProcessing = false);
              scannerController?.resumeCamera(); // スキャンを再開
            },
            child: const Text("やり直す"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("連携QRコードのスキャン"),
        actions: [
          // 📌 変更: フラッシュ（ライト）の切り替え
          IconButton(
            icon: FutureBuilder<bool?>(
              future: scannerController?.getFlashStatus(),
              builder: (context, snapshot) {
                final isTorchOn = snapshot.data ?? false;
                return Icon(
                  isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: isTorchOn ? Colors.yellow : Colors.white,
                );
              },
            ),
            onPressed: () async {
              await scannerController?.toggleFlash();
              setState(() {}); // アイコンの色・状態を更新するために再描画
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // 📌 変更: QRView を使用するように変更
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.greenAccent,
              borderRadius: 16,
              borderLength: 30,
              borderWidth: 10,
              cutOutWidth: 250,
              cutOutHeight: 250,
            ),
          ),

          // 下部の案内テキスト
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "枠内に日記利用者のQRコードを合わせてください",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),

          // 通信中インジケーター
          if (isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}