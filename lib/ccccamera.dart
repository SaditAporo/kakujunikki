import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'previe.dart';

class CameraPage extends StatefulWidget {
  final int userId;
  final String name;
  final String userName;
  final Map diary;
  const CameraPage({super.key, required this.userId, required this.name, required this.userName, required this.diary});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  int _selectedCameraIndex = 0; // 0: 外カメラ, 1: 内カメラ
  List<CameraDescription> _cameras = []; // カメラリストを保持

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  // 1. カメラリストを取得して初期化
  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    
    await _setupController(_cameras[_selectedCameraIndex]);
  }

  // 2. 指定したカメラでコントローラーを作成・初期化
  Future<void> _setupController(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose(); // 前のコントローラーを破棄
    }
    
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);
    
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint("カメラ初期化エラー: $e");
    }
  }

  // 3. カメラを切り替える処理
  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return; 
    
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupController(_cameras[_selectedCameraIndex]);
  }

  @override
  void dispose() {
    _controller?.dispose(); // 画面を閉じるときにカメラを解放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 指示メッセージ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 239, 179),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            margin: const EdgeInsets.all(10),
            child: const Text(
              "💊 今日服用する薬の写真を撮ってください。\n\n🪟 薬がない人は、窓から見える景色を撮ってください。",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // カメラ映像
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
          ),

          // ボタンエリア
// 3. ボタンエリア
        Container(
          height: 120,
          width: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
              // 【真ん中】に配置
              Align(
                alignment: Alignment.center,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () async {
                                        try {
                      final image = await _controller!.takePicture();
                      if (!context.mounted) return;
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImageConfirmPage(
                            imagePath: image.path, 
                            userId: widget.userId, 
                            name: widget.name,
                            userName: widget.userName,
                            diary: widget.diary,
                          ),
                        ),
                      );
                    } catch (e) {
                      debugPrint("撮影エラー: $e");
                    }
                  },
                  child: const Icon(Icons.camera_alt, color: Colors.black, size: 35),
                ),
              ),

              // 【右側】に配置
              Align(
                alignment: Alignment.centerRight, // ⬅️ これ！直感通り！
                child: Padding(
                  padding: const EdgeInsets.only(right: 30), // 右端にベタ付けだと変なので少し隙間を
                  child: IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 35),
                    onPressed: _switchCamera,
                  ),
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}