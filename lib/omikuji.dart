import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class OmikujiPage extends StatefulWidget {
  const OmikujiPage({super.key});

  @override
  State<OmikujiPage> createState() => _OmikujiPageState();
}

class _OmikujiPageState extends State<OmikujiPage> with TickerProviderStateMixin {
  String verticalText(String text) {
  return text.split('').join('\n');
}
  String result = "？";
  bool isSpinning = false;
  final fortunes = ["大吉", "中吉", "小吉", "吉", "末吉", "大凶"];

  Color _bgStartColor = Colors.red[50]!;
  String _message = "ボタンを押して運勢を占おう！";
  IconData _icon = Icons.help_outline;

  List<Point<double>> _emojiPositions = [];

  late AnimationController _floatingController;
  late AnimationController _shakeController;
  late AnimationController _scrollController;
  late AnimationController _glowController; // 大吉用の光るアニメ
  late Animation<double> _scrollAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scrollAnimation = CurvedAnimation(
      parent: _scrollController,
      curve: Curves.easeOutCubic,
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // 輝きを速く（2s -> 1s）
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _shakeController.dispose();
    _scrollController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  final Map<String, List<String>> _messageLibrary = {
    "大吉": ["最高の一日！何か良いことがあるかも✨", "絶好調！やりたかったことに挑戦しよう！", "運気最高潮！笑顔がさらなる福を呼びます", "全てがうまくいく予感！感謝を忘れずに", "今日はあなたが主役！思い切り楽しんで", "素晴らしい出会いや発見がある予感！"],
    "中吉": ["なかなかの運勢！自信を持って進もう！", "良い波が来ています✨その調子で頑張って", "努力が実を結びそう！あともう一踏ん張り！", "嬉しい知らせが届くかも！楽しみに待とう", "周囲との調和が吉！協力して進もう", "やりかけの事を片付けるとさらに運気アップ！"],
    "小吉": ["小さな幸せが見つかる予感♪", "平穏な幸せを感じる一日になりそう", "焦らずゆっくり進むのが成功の鍵", "整理整頓をすると運気が上がります", "優しい言葉をかけると自分も幸せに", "欲張らなければ、良い結果が得られます"],
    "吉": ["平穏な一日!お茶でも飲んでリラックス", "堅実な一歩が大きな成果に繋がります", "忘れ物に注意!余裕を持って行動しよう", "読書や勉強が捗る一日✨自分磨きに最適", "旬のものを食べるとパワーが湧いてきます", "地道な努力が報われる兆しがあります"],
    "末吉": ["これからの伸びしろに期待！", "基礎を固める時期！じっくり取り組みましょう", "控えめな行動が後の幸運に繋がります", "掃除をすると気持ちがスッキリしますよ", "焦りは禁物！自分を信じて待ちましょう", "今は我慢の時！次に備えて準備しよう"],
    "大凶": ["今日は慎重に！家でゆっくり過ごすのが吉", "無理は禁物！早めに休んで体力を温存しよう", "深呼吸をして落ち着いて✨明日は明日の風が吹く", "お財布の紐を締めると吉♪無駄遣いに注意", "謙虚な姿勢がトラブルを防ぎます", "逆にここからは上がるだけ！前向きに"],
  };

  String getDecorationEmojis(String fortune) {
    switch (fortune) {
      case "大吉": return "✨🎊🎉💎";
      case "中吉": return "🎈🌸✨🌸";
      case "小吉": return "🍀🎵🍀🎵";
      case "吉": return "🍃🍵🍃🍵";
      case "末吉": return "🌱☀️🌱☀️";
      case "大凶": return "☔️💀☁️💧";
      default: return "";
    }
  }

  Map<String, dynamic> getFortuneConfig(String fortune) {
    switch (fortune) {
      case "大吉": return {"color": Colors.orange, "bg": const Color(0xFFFFF9C4), "icon": Icons.star};
      case "中吉": return {"color": Colors.redAccent, "bg": Colors.orange[50], "icon": Icons.thumb_up};
      case "小吉": return {"color": Colors.blueAccent, "bg": Colors.blue[50], "icon": Icons.sentiment_satisfied};
      case "吉": return {"color": Colors.green, "bg": Colors.green[50], "icon": Icons.eco};
      case "末吉": return {"color": Colors.blueGrey, "bg": Colors.grey[100], "icon": Icons.trending_up};
      case "大凶": return {"color": Colors.purple, "bg": const Color(0xFF311B92), "icon": Icons.umbrella};
      default: return {"color": Colors.redAccent, "bg": Colors.red[50], "icon": Icons.help_outline};
    }
  }

  // メッセージを指定した文字数（maxCharsPerLine）ごとに分割して縦書きの列を作る
List<Widget> buildVerticalMessage(String text, int maxCharsPerLine) {
  List<Widget> columns = [];
  
  // 右から左へ並べるため、分割したリストを逆順（reversed）にする
  for (int i = 0; i < text.length; i += maxCharsPerLine) {
    int end = (i + maxCharsPerLine < text.length) ? i + maxCharsPerLine : text.length;
    String lineText = text.substring(i, end);
    
    columns.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4), // 行間の隙間
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: lineText.split('').map((char) {
            return Text(
              char,
              style: TextStyle(
                fontFamily: 'FudeFont',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.1,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  // 日本の縦書きは「右から左」なので reversed をつけて返す
  return columns.reversed.toList();
}

  Future<void> drawOmikuji() async {
    if (isSpinning) return;

    setState(() {
      isSpinning = true;
      result = "？";
      _message = "おみくじを振っています...";
      _emojiPositions = [];
    });

    _scrollController.reset();
    _shakeController.repeat(reverse: true);

    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(milliseconds: 70));
      setState(() {
        result = fortunes[Random().nextInt(fortunes.length)];
      });
    }

    _shakeController.stop();
    _shakeController.reset();

    await Future.delayed(const Duration(milliseconds: 500));

    final finalResult = fortunes[Random().nextInt(fortunes.length)];
    final config = getFortuneConfig(finalResult);
    final messageList = _messageLibrary[finalResult] ?? ["占いを開始しましょう"];

    const cleanPositions = [
      Point(0.15, 0.15), Point(0.5, 0.08), Point(0.85, 0.15),
      Point(0.1, 0.35), Point(0.9, 0.35),
      Point(0.1, 0.65), Point(0.9, 0.65),
      Point(0.15, 0.85), Point(0.5, 0.95), Point(0.85, 0.85),
      Point(0.25, 0.25), Point(0.75, 0.25),
    ];

    setState(() {
      result = finalResult;
      isSpinning = false;
      _bgStartColor = config["bg"];
      _message = messageList[Random().nextInt(messageList.length)];
      _icon = config["icon"];
      _emojiPositions = cleanPositions;
    });

    _scrollController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final config = getFortuneConfig(result);
    final String decoration = getDecorationEmojis(result);
    final emojiList = decoration.characters.toList();

    // デザイン定数
    const double boxWidth = 340.0;
    const double boxHeight = 400.0;
    const double translationY = -300.0;
    const double holeHeight = 25.0;
    const double boxBottomY = boxHeight + translationY; // 100.0
    const double paperTop = boxBottomY - holeHeight; // 75.0

    return Scaffold(
      appBar: AppBar(
        title: const Text("今日のおみくじ"),
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _bgStartColor,
              (!isSpinning && result == "大凶") ? Colors.black : Colors.white,
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景の絵文字
            if (!isSpinning && result != "？" && emojiList.isNotEmpty)
              ..._emojiPositions.asMap().entries.map((entry) {
                final pos = entry.value;
                final index = entry.key;
                final emoji = emojiList[index % emojiList.length];
                return AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    double offsetX = sin(_floatingController.value * 2 * pi + index) * 0.5;
                    double offsetY = cos(_floatingController.value * 2 * pi + index) * 0.5;
                    return Align(
                      alignment: Alignment((pos.x * 2 - 1), (pos.y * 2 - 1)),
                      child: Transform.translate(
                        offset: Offset(offsetX * 100, offsetY * 100),
                        child: AnimatedOpacity(
                          opacity: 0.4,
                          duration: const Duration(milliseconds: 800),
                          child: Text(emoji, style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                    );
                  },
                );
              }),

            Center(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        // 1. おみくじ箱 (背面)
                        AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            double doyoonShake = (!isSpinning && result == "大凶") ? (sin(DateTime.now().millisecondsSinceEpoch * 0.05) * 2) : 0;
                            double shakeRotation = isSpinning ? (sin(_shakeController.value * pi * 2) * 0.03) : 0;
                            double shakeX = isSpinning ? (cos(_shakeController.value * pi * 4) * 10) : doyoonShake;
                            double shakeY = isSpinning ? (sin(_shakeController.value * pi * 2) * 5) : 0;

                            return Transform.translate(
                              offset: Offset(shakeX, shakeY + translationY),
                              child: Transform.rotate(
                                angle: shakeRotation,
                                child: Container(
                                  width: boxWidth,
                                  height: boxHeight,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDEB887),
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (!isSpinning && result == "大凶") ? Colors.deepPurple.withValues(alpha: 0.5) : Colors.black45,
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      )
                                    ],
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.brown[800]!.withValues(alpha: 0.4),
                                        Colors.transparent,
                                        Colors.white.withValues(alpha: 0.25),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                    border: Border.all(color: const Color(0xFF8B4513), width: 6),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      // 「御神籤」の文字を削除
                                      Container(
                                        width: 200,
                                        height: holeHeight,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF21100D),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                          border: Border.all(color: const Color(0xFF8B4513), width: 2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // 2. 紙 (前面)
                        Positioned(
                          top: paperTop,
                          child: SizeTransition(
                            sizeFactor: _scrollAnimation,
                            axis: Axis.vertical,
                            axisAlignment: -1,
                            child: AnimatedBuilder(
                                animation: _glowController,
                                builder: (context, child) {
                                  return Container(
                                    width: 200,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                                      border: Border.all(
                                        color: result == "大吉" ? Colors.orangeAccent : Colors.grey[300]!,
                                        width: result == "大吉" ? 4 : 1.5, // ボーダーを少し太く
                                      ),
                                      boxShadow: [
                                        if (result == "大吉") ...[
                                          // 複数のオーラを重ねて光を強化
                                          BoxShadow(
                                            color: Colors.yellowAccent.withValues(alpha: 0.6 + (_glowController.value * 1.0)),
                                            blurRadius: 30 + (_glowController.value * 30),
                                            spreadRadius: 30 + (_glowController.value * 15),
                                          ),
                                          BoxShadow(
                                            color: Colors.orangeAccent.withValues(alpha: 1.0 + (_glowController.value * 0.3)),
                                            blurRadius: 50 + (_glowController.value * 40),
                                            spreadRadius: 50 + (_glowController.value * 20),
                                          ),
                                        ],
                                        if (result == "大凶")
                                          const BoxShadow(
                                            color: Colors.black,
                                            blurRadius: 25,
                                            spreadRadius: 2,
                                          )
                                        else if (result != "大吉")
                                          const BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8)),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          result,
                                          style: GoogleFonts.notoSansJp(
                                            textStyle: TextStyle(
                                              fontSize: 60,
                                              fontWeight: FontWeight.w900,
                                              color: config["color"],
                                              letterSpacing: -2,
                                              shadows: result == "大吉" ? [
                                                Shadow(color: Colors.yellow, blurRadius: 15 + (_glowController.value * 10)),
                                                Shadow(color: Colors.orange, blurRadius: 25 + (_glowController.value * 15)),
                                              ] : null,
                                            ),
                                          ),
                                        ),
                                        const Divider(height: 20, thickness: 2.5),
                                        Icon(_icon, size: 36, color: config["color"]),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          direction: Axis.horizontal, // 行を横に並べる
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment: WrapCrossAlignment.start,
                                          children: buildVerticalMessage(_message, 8), 
                                        ),
                                      ],
                                    ),
                                  );
                                }
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 下部ボタン
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: isSpinning ? null : drawOmikuji,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 22),
                        textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        elevation: 15,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                      ),
                      child: Text(isSpinning ? "念じ中..." : "おみくじを振る"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
