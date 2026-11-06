import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final Widget page;

  const MenuButton({
    super.key,
    required this.label,
    required this.color,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return SizedBox(
      width: isWide ? 400 : size.width * 0.9,
      height: isWide ? 60 : size.height * 0.07,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'FudeFont',
            fontSize: isWide ? 22 : size.width * 0.054,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ChoiceSelector extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String> onSelected; // 選択を親に渡す

  const ChoiceSelector({super.key, required this.options, required this.onSelected});

  @override
  State<ChoiceSelector> createState() => _ChoiceSelectorState();
}

class _ChoiceSelectorState extends State<ChoiceSelector> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: widget.options.map((option) {
        final isSelected = selected == option;
        return GestureDetector(
          onTap: () {
            setState(() {
              selected = option;
            });
            widget.onSelected(option); // 選択を親に伝える
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.blueAccent : Colors.grey[200],
            ),
            child: Text(
              option,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class HomeBackButton extends StatelessWidget {
  const HomeBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return ElevatedButton.icon(
      onPressed: () {
        // 全ての履歴を消してアプリの最初の画面に戻る
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      icon: const Icon(Icons.home, color: Colors.black), // アイコンを白に
      label: const Text(
        'ホームに戻る',
        style: TextStyle(
          fontFamily: 'FudeFont',
          fontSize: 24,
          color: Colors.black, // 文字を白に
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange, // 中の色を赤に！
        elevation: 5,               // 少し影をつけて立体感を出す
        fixedSize: Size(
          isWide ? 400 : size.width * 0.7, 
          isWide ? 50 : size.height * 0.06
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

class CardButton extends StatelessWidget {
  final String item;      // ボタンのラベル
  final Widget? page;     // 遷移先ページ（任意）
  final Color color;
  final VoidCallback? onTap; // 任意の処理

  const CardButton({
    super.key,
    required this.item,
    this.page,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap ??
            () {
              if (page != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => page!,
                  ),
                );
              }
            },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              const Icon(Icons.settings),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}