import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'hozon.dart'; 

class ScanLinkPage extends StatefulWidget {
  final int userId; // 保護者（家族）側の user_id
  final String userName;
  final String name;

  const ScanLinkPage({super.key, required this.userId, required this.userName, required this.name});

  @override
  State<ScanLinkPage> createState() => _ScanLinkPageState();
}

class _ScanLinkPageState extends State<ScanLinkPage> {
  // スキャナーの動作を制御するコントローラー
  final MobileScannerController scannerController = MobileScannerController();
  
  bool isProcessing = false; // 二重読み取り・連続送信防止フラグ

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  // QRコード検出時の処理
  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return; // 処理中ならスキップ

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    // 最初に読み取れたQRコードの値を取得
    final String? scannedUserName = barcodes.first.rawValue;

    if (scannedUserName == null || scannedUserName.trim().isEmpty) {
      return;
    }

    setState(() => isProcessing = true);
    scannerController.stop(); // 読み取り成功したらカメラをストップ

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
      scannerController.start();
    }
  }

 // Flask サーバーの ApiService.linkUser を呼び出す
  Future<void> _sendLinkRequest(String targetUserName) async {
    final body = {
      "parent_id": widget.userId,
      "jijibaba_username": targetUserName,
    };

    try {
      // ApiService を使用してリクエスト送信
      final response = await ApiService.linkUser(body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("連携が成功しました！")),
        );
        Navigator.pop(context, true); // 成功フラグを持って戻る
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
              scannerController.start(); // スキャンを再開
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
          // カメラのライト（フラッシュ）ON/OFF ボタン
         // ⭕ 修正後のコード
            IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
                valueListenable: scannerController,
                builder: (context, state, child) {
                // state.torchState で現在のライト状態（off / on / auto 等）を取得
                final isTorchOn = state.torchState == TorchState.on;
                return Icon(
                    isTorchOn ? Icons.flash_on : Icons.flash_off,
                    color: isTorchOn ? Colors.yellow : Colors.white,
                );
                },
            ),
            onPressed: () => scannerController.toggleTorch(),
            )
        ],
      ),
      body: Stack(
        children: [
          // カメラプレビュー画面
          MobileScanner(
            controller: scannerController,
            onDetect: _onDetect,
          ),

          // QRコード読み取り枠のオーバーレイ（ガイド表示）
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
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