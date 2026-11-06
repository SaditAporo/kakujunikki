import 'dart:math';
import 'package:flutter/material.dart';

class Keisan extends StatelessWidget {
  const Keisan({super.key});

  @override
  Widget build(BuildContext context) {
    return const RandomMathQuiz();
  }
}

class RandomMathQuiz extends StatefulWidget {
  const RandomMathQuiz({super.key});

  @override
  State<RandomMathQuiz> createState() => _RandomMathQuizState();
}

class _RandomMathQuizState extends State<RandomMathQuiz> {
  final Random _random = Random();

  late String _equation; // 表示する計算式
  late double _answer;   // 計算結果

  int _currentQuestion = 1; // 現在の問題番号
  final int _totalQuestions = 10;
  int _correct = 0;
  int _incorrect = 0;
  String? _feedbackSymbol; // "○" か "×" を入れる
  String _input = "";

  @override
  void initState() {
    super.initState();
    _generateEquation();
  }

  void _generateEquation() {
    int a = _random.nextInt(10) + 1;
    int b = _random.nextInt(10) + 1;
    List<String> operators = ['+', '-', '×', '÷'];
    String op = operators[_random.nextInt(operators.length)];

    // 引き算は負にならないように調整
    if (op == '-') {
      if (a < b) {
        int temp = a;
        a = b;
        b = temp;
      }
    }

    // 割り算は整数になるように調整
    if (op == '÷') {
      a = a * b;
    }

    _equation = '$a $op $b';
    _answer = _calculate(a, b, op);
  }

  double _calculate(int a, int b, String op) {
    switch (op) {
      case '+':
        return a + b.toDouble();
      case '-':
        return a - b.toDouble();
      case '×':
        return a * b.toDouble();
      case '÷':
        return a / b.toDouble();
      default:
        return 0;
    }
  }

void _checkAnswer(String input) async { 
  // _controller.text ではなく、引数の input を使う
  double? userAnswer = double.tryParse(input);
  
  if (userAnswer == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数字を入力してください')),
    );
    return;
  }

  // --- 判定と記号のセット ---
  setState(() {
    if ((userAnswer - _answer).abs() < 0.0001) {
      _correct++;
      _feedbackSymbol = "○";
    } else {
      _incorrect++;
      _feedbackSymbol = "×";
    }
  });

  // --- 1秒間待つ ---
  await Future.delayed(const Duration(seconds: 1));

  // --- 次の問題へ ---
  setState(() {
    _feedbackSymbol = null;
    
    if (_currentQuestion >= _totalQuestions) {
      _showResult();
    } else {
      _currentQuestion++;
      // _controller.clear() はもう不要なので消してOK
      _input = ""; // ここで入力をリセット
      _generateEquation();
    }
  });
}

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('結果'),
        content: Text(
          '正解数: $_correct\n不正解数: $_incorrect',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 239, 179),
      appBar: AppBar(
        title: const Text(
          '計算トレーニング',
          style: TextStyle(fontFamily: 'FudeFont', fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[600],
      ),
      // --- Stack を使って前面に重ねられるようにする ---
      body: Stack(
        children: [
          // 元々のメインコンテンツ
          Align(
            alignment: const Alignment(0, 0.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: // ... (変数の宣言に String _input = ""; を追加しておいてください)

Column(
  children: [
    const Spacer(flex: 1),
    Text(
      '問題 $_currentQuestion/$_totalQuestions',
      style: const TextStyle(fontSize: 24),
    ),
    Text(
      _equation,
      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 10),
    // --- 入力された数字を表示する場所 ---
    Container(
      width: double.infinity,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Text(
        _input, // 入力中の数字を表示
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    ),
    const SizedBox(height: 20),
    // --- 数字ボタン（0-9）のグリッド ---
    SizedBox(
      height: 250, // ボタンエリアの高さ
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5列並べる
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          // 1, 2, 3... 9, 0 の順で並べるための工夫
          int number = (index + 1) % 10; 
          return ElevatedButton(
            onPressed: () {
              setState(() => _input += number.toString());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('$number', style: const TextStyle(fontSize: 35)),
          );
        },
      ),
    ),
    const SizedBox(height: 10),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          onPressed: () => setState(() => _input = ""),
          child: const Text('消去', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        // 判定ボタン
        ElevatedButton(
          onPressed: () {
            // _input を使って判定処理へ
            _checkAnswer(_input); 
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 199, 18, 151),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text('判定', style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
    const Spacer(flex: 2),
  ],
            ),
            ),
          ),

          // --- ここに ○ や × を重ねる ---
          if (_feedbackSymbol != null)
            Container(
              color: Colors.white.withValues(alpha: 0.3), // 記号が出ている間、背景を少し暗く（任意）
              child: Center(
                child: Text(
                  _feedbackSymbol!,
                  style: TextStyle(
                    fontSize: 250, // 画面いっぱいのサイズ
                    fontWeight: FontWeight.w900,
                    // 丸は赤っぽく、バツは青っぽく
                    color: _feedbackSymbol == "○" 
                        ? Colors.red.withValues(alpha: 0.7) 
                        : Colors.blue.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}