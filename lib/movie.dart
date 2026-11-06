import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'videoresult.dart';

class AutoVideoRecorderPage extends StatefulWidget {
  final int userId;
  final String name;
  final String userName;
  final Map diary;
  final String imagePath;
  const AutoVideoRecorderPage({super.key, required this.userId, required this.name, required this.userName, required this.diary, required this.imagePath});

  @override
  State<AutoVideoRecorderPage> createState() => _AutoVideoRecorderPageState();
}

class _AutoVideoRecorderPageState extends State<AutoVideoRecorderPage> {
  CameraController? _controller;
  int _secondsRemaining = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    final cameras = await availableCameras();
    // 内カメラ（front）を探す
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});

    // 撮影開始！
    await _controller!.startVideoRecording();
    
    // 10秒のカウントダウン開始
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _finishRecording();
      }
    });
  }

  Future<void> _finishRecording() async {
    _timer?.cancel();
    if (_controller != null && _controller!.value.isRecordingVideo) {
      final XFile videoFile = await _controller!.stopVideoRecording();
      
      // 自動的に次の画面（結果・送信画面）へ
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VideoResultPage(
          videoPath: videoFile.path,
          userId: widget.userId,
          name: widget.name,
          diary: widget.diary,
          userName: widget.userName,
          imagePath: widget.imagePath,
        )),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          CameraPreview(_controller!),
          // カウントダウン表示
          Positioned(
            top: 100,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.7), shape: BoxShape.circle),
              child: Text(
                "$_secondsRemaining",
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Positioned(
            bottom: 50,
            child: Text("そのままお待ちください...", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}