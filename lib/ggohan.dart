import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'hozon2.dart';

class Gohan extends StatefulWidget {
  final String userName;
  final int userId;
  const Gohan({super.key, required this.userName, required this.userId});

  @override
  State<Gohan> createState() => _GohanState();
  
}

class _GohanState extends State<Gohan> {
  String? selectedIcon;
  String? selectedIcon2;
  final List<String> selectedIconsRight = [];
  final List<String> selectedIconsLeft = [];
  List<String> icons = [];
  final GlobalKey repaintkey = GlobalKey();
  
  Future<void> openPage(Widget page) async {
    final String? icon = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
          if (icon != null) {
            // 戻り値がある場合の処理
            setState(() {
              selectedIconsRight.add(icon);
            });
          }
  }

  Widget iconhyoji(String icon, Size size, bool isWide) {
    return SvgPicture.asset(
            icon,
            width: isWide ? 70 : size.width * 0.07,
            height: isWide ? 70 : size.width * 0.07
          );
  }

  Text mojicolor(String label, Size size, bool isWide) {
    return Text(
          label,
          style: TextStyle(
            fontSize: isWide ? 80 : size.width * 0.08,
            color: const Color.fromARGB(255, 246, 251, 214),
          ),
        );
  }

Future<Uint8List?> captureScreen() async {
  try {
    // 描画が確実に終わるまで1フレーム待つ
    await Future.delayed(const Duration(milliseconds: 20)); 

    RenderRepaintBoundary? boundary =
        repaintkey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) return null;

    // もし画像がまだ読み込み中だと真っ白になるので注意
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  } catch (e) {
    debugPrint("キャプチャ失敗: $e");
    return null;
  }
}
  
  @override
  Widget build(BuildContext context){
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      appBar: AppBar(title: const Text('食事記録', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black),),
      body: RepaintBoundary(
              key: repaintkey,
              child:Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
        // --- 主菜と副菜を横に並べるセクション ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 左側：主菜エリア（アイコン or ボタン）
            if (selectedIcon != null)
              Row(
                children: [
                  Wrap(
                    direction: Axis.vertical, // 縦に並べる
                    children: selectedIconsLeft.map((icon) => iconhyoji(icon, size, isWide)).toList(),
                  ),
                  const SizedBox(width: 10),
                  SvgPicture.asset(
                    selectedIcon!,
                    width: isWide ? 150 : size.width * 0.18,
                    height: isWide ? 150 : size.width * 0.18,
                  ),
                  const SizedBox(width: 10),
                  Wrap(
                    direction: Axis.vertical, // 縦に並べる
                    children: selectedIconsRight.map((icon) => iconhyoji(icon, size, isWide)).toList(),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () async {
                  final String? icon = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Syusai()),
                  );
                  if (icon != null) setState(() => selectedIcon = icon);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 245, 28, 28),
                  padding: EdgeInsets.symmetric(
                    vertical: isWide ? 50 : size.height * 0.05,
                    horizontal: isWide ? 30 : size.width * 0.05,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: mojicolor('主菜', size, isWide),
              ),

            const SizedBox(width: 20), // 主菜と副菜の間のスキマ

            // 右側：副菜追加ボタン
            if (selectedIcon != null) 
            ElevatedButton(
              onPressed: () async {
                final String? icon = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Fukusai(fukusaiCounter: selectedIconsLeft.length + selectedIconsRight.length)),
                );
                if (icon != null) {
                  setState(() {
                    // 左右にバランスよく振り分け
                    if (selectedIconsLeft.length <= selectedIconsRight.length) {
                      selectedIconsLeft.add(icon);
                    } else {
                      selectedIconsRight.add(icon);
                    }
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(20),
                shape: const CircleBorder(),
              ),
              //child: const Icon(Icons.add, color: Colors.white, size: 30),
              child: Column(
  mainAxisSize: MainAxisSize.min, // 余計な隙間を詰め
  children: [
    Text(
      '副菜\n追加', // \n で改行すると丸いボタンの中に綺麗に収まります
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: isWide ? 16 : size.width * 0.025,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),
            ),
          ],
        ),


                    const SizedBox(height: 65),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Expanded(child: GohanButton(label: '主食', color: const Color.fromARGB(255, 212, 97, 9), page: const Syusyoku())),
                        GohanButton(label: '主食', color: const Color.fromARGB(255, 212, 97, 9), page: const Syusyoku()),
                        const SizedBox(width: 60),
                        GohanButton(label: '汁物', color: const Color.fromARGB(255, 111, 154, 18), page: const Sirumono()),
                      ]
                    ),
                  ],
                )
              ),
      ),
      floatingActionButton: FloatingActionButton.large( 
        onPressed: () async {
          final imageBytes = await captureScreen();
          if (imageBytes != null) {
            if (!context.mounted) return;
            
            // HozonPage に画像データを渡して移動
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HozonPage(imageBytes: imageBytes, userId: widget.userId),
              ),
            );
          } else {
            debugPrint('画像のキャプチャに失敗しました');
          }
        },
        backgroundColor: const Color.fromARGB(255, 18, 137, 199),
        child: Text(
          '保存',
          style: TextStyle(
            fontSize: isWide ? 40 : size.width * 0.04,
            color: const Color.fromARGB(255, 233, 241, 242),
          ),
        ),
      ),
      
    );
  }
}

class Syusyoku extends StatefulWidget {
  const Syusyoku({super.key});

  @override
  State<Syusyoku> createState() => _SyusyokuState();
}

class _SyusyokuState extends State<Syusyoku> {
  final TextEditingController syusyokuController = TextEditingController();
  bool isbreadSelected = false;
  bool isnoodleSelected = false;

  @override
  void dispose() {
    syusyokuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      appBar: AppBar(title: const Text('主食入力', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(child: Text('主食を入力してください')),
            SizedBox(height: isWide ? 20 : size.height * 0.02),
            TextField(
              controller: syusyokuController,
              decoration: InputDecoration(
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final String? selectedRiceIcon = await Navigator.push(context, MaterialPageRoute(builder: (_) => Rice()));
                         if (selectedRiceIcon != null) {
                          // 戻り値がある場合の処理
                          setState(()
                          {
                            Navigator.pop(context, selectedRiceIcon);
                          });
                        }
                        
                      },
                      icon: Icon(Icons.rice_bowl,size: isWide ? 80 : size.width * 0.08,color: Color.fromARGB(255, 24, 21, 3)),
                    ),
                    SizedBox(width: isWide ? 50 : size.width * 0.05),
                    IconButton(
                      onPressed: () async {
                        final String? selectedBreadIcon = await Navigator.push(context, MaterialPageRoute(builder: (_) => Bread()));
                         if (selectedBreadIcon != null) {
                          // 戻り値がある場合の処理
                          setState(()
                          {
                            Navigator.pop(context, selectedBreadIcon);
                          });
                        }
                      },
                      icon: Icon(Icons.bakery_dining,size: isWide ? 80 : size.width * 0.08,color: Color.fromARGB(255, 98, 56, 8)),
                    ),
                    SizedBox(width: isWide ? 50 : size.width * 0.05),
                    IconButton(
                      onPressed: () async {
                        final String? selectedNoodleIcon = await Navigator.push(context, MaterialPageRoute(builder: (_) => Noodle()));
                         if (selectedNoodleIcon != null) {
                          // 戻り値がある場合の処理
                          setState(()
                          {
                            Navigator.pop(context, selectedNoodleIcon);
                          });
                        }
                      },
                      icon: Icon(Icons.dinner_dining,size: isWide ? 80 : size.width * 0.08,color: Color.fromARGB(255, 48, 50, 3)),
                    ),
                    SizedBox(width: isWide ? 50 : size.width * 0.05),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context, null);
                      },
                      icon: Icon(Icons.no_food,size: isWide ? 80 : size.width * 0.08,color: Color.fromARGB(255, 96, 96, 96)),
                    ),
                  ],
                ),
              )
            ),
            SizedBox(height: isWide ? 50 : size.height * 0.05),
            
            /*TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                labelText: "主食",
                border: OutlineInputBorder(),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}

class Rice extends StatefulWidget {
  const Rice({super.key});

  @override
  State<Rice> createState() => _RiceState();
}

class _RiceState extends State<Rice> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      appBar: AppBar(title: const Text('ご飯の種類選択', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(child: Text('ご飯の種類を選択してください')),
            SizedBox(height: isWide ? 20 : size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GohanSelectButton(iconname: 'assets/flutter_svg/gohan.svg', color: Color.fromARGB(255, 17, 1, 44), label: '白ご飯', size: isWide ? 100 : size.width * 0.1),
                SizedBox(width: isWide ? 20 : size.width * 0.02),
                GohanSelectButton(iconname: 'assets/flutter_svg/onigiri.svg', color: Color.fromARGB(255, 5, 18, 0), label: 'おにぎり', size: isWide ? 100 : size.width * 0.1),
                SizedBox(width: isWide ? 20 : size.width * 0.02),
                GohanSelectButton(iconname: 'assets/flutter_svg/curry.svg', color: Color.fromARGB(255, 20, 8, 0), label: 'カレー', size: isWide ? 100 : size.width * 0.1),
              ],
            ),
            SizedBox(height: isWide ? 20 : size.height * 0.02),
            IconButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              icon: Icon(Icons.no_food,size: isWide ? 100 : size.width * 0.1,color: Color.fromARGB(255, 96, 96, 96)),
            ),
          ],
        ),
      ),
    );
  }
}

class Bread extends StatefulWidget {
  const Bread({super.key});

  @override
  State<Bread> createState() => _BreadState();
}

class _BreadState extends State<Bread> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      appBar: AppBar(title: const Text('パンの種類選択', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            const Center(child: Text('パンの種類を選択してください')),
            SizedBox(height: isWide ? 20 : size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GohanSelectButton(iconname: 'assets/flutter_svg/pan1.svg', color: Color.fromARGB(255, 190, 110, 18), label: 'トースト', size: isWide ? 100 : size.width * 0.1),
                SizedBox(width: isWide ? 20 : size.width * 0.02),
                GohanSelectButton(iconname: 'assets/flutter_svg/baget.svg', color: Color.fromARGB(255, 137, 76, 6), label: 'フランスパン', size: isWide ? 100 : size.width * 0.1),
                SizedBox(width: isWide ? 20 : size.width * 0.02),
                GohanSelectButton(iconname: 'assets/flutter_svg/sand.svg', color: Color.fromARGB(255, 246, 205, 72), label: 'サンドウィッチ', size: isWide ? 100 : size.width * 0.1),
                SizedBox(width: isWide ? 20 : size.width * 0.02),
                GohanSelectButton(iconname: 'assets/flutter_svg/burger.svg', color: Color.fromARGB(255, 170, 111, 44), label: 'ハンバーガー', size: isWide ? 100 : size.width * 0.1),
              ],
            ),
            SizedBox(height: isWide ? 20 : size.height * 0.02),
            IconButton(
              onPressed: () {
                const Text('not selected');
                //Navigator.pop(context, null);
              },
              icon: Icon(Icons.no_food,size: isWide ? 100 : size.width * 0.1,color: Color.fromARGB(255, 96, 96, 96)),
            ),
          ],
        ),
      ),
    );
  }
}

class Noodle extends StatefulWidget {
  const Noodle({super.key});

  @override
  State<Noodle> createState() => _NoodleState();
}

class _NoodleState extends State<Noodle> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      appBar: AppBar(title: const Text('麺の種類選択', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(child: Text('麺の種類を選択してください')),
            SizedBox(height: isWide ? 20 : size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GohanSelectButton(iconname: 'assets/flutter_svg/ramen.svg', color: Color.fromARGB(255, 253, 147, 26), label: 'ラーメン', size: isWide ? 100 : size.width * 0.1),
                SizedBox(width: isWide ? 20 : size.width * 0.02),
                GohanSelectButton(iconname: 'assets/flutter_svg/soba.svg', color: Color.fromARGB(255, 88, 79, 87), label: '蕎麦', size: isWide ? 100 : size.width * 0.1),
                SizedBox(width: isWide ? 20 : size.width * 0.02),
                GohanSelectButton(iconname: 'assets/flutter_svg/udon.svg', color: Color.fromARGB(255, 191, 101, 16), label: 'うどん', size: isWide ? 100 : size.width * 0.1),
                SizedBox(width: isWide ? 20 : size.width * 0.02),
                GohanSelectButton(iconname: 'assets/flutter_svg/pasta.svg', color: Color.fromARGB(255, 228, 228, 78), label: 'パスタ', size: isWide ? 100 : size.width * 0.1),
              ],
            ),
            SizedBox(height: isWide ? 20 : size.height * 0.02),
            IconButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              icon: Icon(Icons.no_food,size: isWide ? 100 : size.width * 0.1,color: Color.fromARGB(255, 96, 96, 96)),
            ),
          ],
        ),
      ),
    );
  }
}

class Sirumono extends StatefulWidget {
  const Sirumono({super.key});

  @override
  State<Sirumono> createState() => _SirumonoState();
}

class _SirumonoState extends State<Sirumono> {
  final TextEditingController sirumonoController = TextEditingController();
  bool isbreadSelected = false;
  bool isnoodleSelected = false;

  @override
  void dispose() {
    sirumonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      appBar: AppBar(title: const Text('汁物入力', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(child: Text('近しい物を選んでください')),
            SizedBox(height: isWide ? 20 : size.height * 0.02),
            TextField(
              controller: sirumonoController,
              decoration: InputDecoration(
                suffixIcon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GohanSelectButton(iconname: 'assets/flutter_svg/misosiru.svg', color: Color.fromARGB(255, 213, 153, 32), label: '味噌汁', size: isWide ? 100 : size.width * 0.1),
                    SizedBox(width: isWide ? 50 : size.width * 0.05),
                    GohanSelectButton(iconname: 'assets/flutter_svg/soup.svg', color: Color.fromARGB(255, 107, 57, 3), label: 'スープ', size: isWide ? 100 : size.width * 0.1),
                    SizedBox(width: isWide ? 50 : size.width * 0.05),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context, null);
                      },
                      icon: Icon(Icons.no_food,size: isWide ? 80 : size.width * 0.08,color: Color.fromARGB(255, 96, 96, 96)),
                    ),
                  ],
                ),
              )
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class Syusai extends StatefulWidget {
  const Syusai({super.key});

  @override
  State<Syusai> createState() => _SyusaiState();
}

class _SyusaiState extends State<Syusai> {
  final TextEditingController syusyokuController = TextEditingController();
  bool isbreadSelected = false;
  bool isnoodleSelected = false;

  @override
  void dispose() {
    syusyokuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      appBar: AppBar(title: const Text('主食入力', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(child: Text('主食を入力してください')),
            SizedBox(height: isWide ? 20 : size.height * 0.02),
            TextField(
              controller: syusyokuController,
              decoration: InputDecoration(
                suffixIcon:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GohanSelectButton(iconname: 'assets/flutter_svg/stack.svg', color: Color.fromARGB(255, 168, 11, 11), label: '肉類', size: isWide ? 200 : size.width * 0.2),
                        SizedBox(width: isWide ? 50 : size.width * 0.05),
                        GohanSelectButton(iconname: 'assets/flutter_svg/fish.svg', color: Color.fromARGB(252, 18, 42, 177), label: '魚類', size: isWide ? 200 : size.width * 0.2),
                      ]
                    ),
                    SizedBox(height: isWide ? 50 : size.height * 0.05),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context, null);
                      },
                      icon: Icon(Icons.no_food,size: isWide ? 80 : size.width * 0.08 ,color: Color.fromARGB(255, 96, 96, 96)),
                    ),
                  ],
                ),
              )
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class Fukusai extends StatelessWidget {
  final int fukusaiCounter;
  
  const Fukusai({
    super.key,
    required this.fukusaiCounter,
  });
  



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: RichText(
                text:TextSpan(
    style: TextStyle(color: Colors.black, fontSize: 16),
  ),
        ),
         
        backgroundColor: Colors.white, 
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: isWide ? 20 : size.width * 0.05,
          mainAxisSpacing: isWide ? 20 : size.width * 0.05,
          children: [
            // SizedBox(width: isWide ? 20 : size.width * 0.05),
            GohanSelectButton(iconname: 'assets/flutter_svg/kiwi.svg', color: Color.fromARGB(255, 97, 37, 2), label: '漬物', size: isWide ? 150 : size.width * 0.08),
            // SizedBox(width: isWide ? 20 : size.width * 0.05),
            GohanSelectButton(iconname: 'assets/flutter_svg/popai.svg', color: Color.fromARGB(255, 3, 63, 25), label: 'サラダ', size: isWide ? 150 : size.width * 0.08),
            // SizedBox(width: isWide ? 20 : size.width * 0.05),
            GohanSelectButton(iconname: 'assets/flutter_svg/ichigo.svg', color: Color.fromARGB(255, 234, 16, 13), label: '果物', size: isWide ? 150 : size.width * 0.08),
            // SizedBox(width: isWide ? 20 : size.width * 0.05),
            GohanSelectButton(iconname: 'assets/flutter_svg/dango.svg', color: Color.fromARGB(255, 16, 11, 1), label: 'お団子', size: isWide ? 150 : size.width * 0.08),
            // SizedBox(width: isWide ? 20 : size.width * 0.05),
            GohanSelectButton(iconname: 'assets/flutter_svg/dounut.svg', color: Color.fromARGB(255, 215, 15, 159), label: 'ドーナツ', size: isWide ? 150 : size.width * 0.08),
            // SizedBox(width: isWide ? 20 : size.width * 0.05),
            GohanSelectButton(iconname: 'assets/flutter_svg/cake4.svg', color: Color.fromARGB(255, 247, 2, 2), label: 'ケーキ', size: isWide ? 150 : size.width * 0.08),
            // SizedBox(width: isWide ? 20 : size.width * 0.05),
            GohanSelectButton(iconname: 'assets/flutter_svg/gyunyu.svg', color: Color.fromARGB(255, 18, 174, 199), label: '牛乳', size: isWide ? 150 : size.width * 0.08),
            // SizedBox(width: isWide ? 20 : size.width * 0.05),
            GohanSelectButton(iconname: 'assets/flutter_svg/beer2.svg', color: Color.fromARGB(255, 225, 207, 9), label: 'お酒', size: isWide ? 150 : size.width * 0.08),
            // SizedBox(width: isWide ? 20 : size.width * 0.05),
            GohanSelectButton(iconname: 'assets/flutter_svg/juice.svg', color: Color.fromARGB(255, 233, 122, 42), label: 'ジュース', size: isWide ? 150 : size.width * 0.08),
            // SizedBox(width: isWide ? 20 : size.width * 0.05),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large( 
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: const Color.fromARGB(255, 18, 137, 199),
        child: Text(
          '終了',
          style: TextStyle(
            fontSize: isWide ? 40 : size.width * 0.04,
            color: const Color.fromARGB(255, 246, 251, 214),
          ),
        ),
      ),
    );
  }
}

class GohanButton extends StatefulWidget {
  final String label;
  final Color color;
  final Widget page;

  const GohanButton({
    super.key,
    required this.label,
    required this.color,
    required this.page,
  });

  @override
  State<GohanButton> createState() => _GohanButtonState();
}

class _GohanButtonState extends State<GohanButton> {
  String? selectedIcon;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    if(selectedIcon != null) {
      return SvgPicture.asset(
        selectedIcon!,
        width: isWide ? 100 : size.width * 0.1,
        height: isWide ? 100 : size.width * 0.1
      );
    } else {
      return ElevatedButton(
        onPressed: () async {
          final String? icon = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => widget.page),
          );
          if (icon != null) {
            // 戻り値がある場合の処理
            setState(() {
              selectedIcon = icon;
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          foregroundColor: Colors.black,
          shadowColor: const Color.fromARGB(252, 6, 6, 6),
          padding: EdgeInsets.symmetric(
            vertical: isWide ? 70 : size.height * 0.07,
            horizontal: isWide ? 40 : size.width * 0.07,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
          elevation: 8,
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: isWide ? 80 : size.width * 0.08,
            color: const Color.fromARGB(255, 246, 251, 214),
          ),
        ),
      ); 
    }
  }
}

class GohanSelectButton extends StatelessWidget {
  final String iconname;
  final Color color;
  final String label;
  final double size;

  const GohanSelectButton({
    super.key,
    required this.iconname,
    required this.color,
    required this.label,
    required this.size,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell( // TextButtonよりレイアウトが崩れにくいInkWellがオススメ
      onTap: () {
        Navigator.pop(context, (iconname));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min, // 中身のサイズに合わせる
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconname,
            width: size,
            height: size,
            // ignore: deprecated_member_use
            color: color,
          ),
          const SizedBox(height: 4), // アイコンと文字の間のスキマ
          Text(
            label,
            style: TextStyle(
              fontSize: size * 0.25, // アイコンのサイズに比例して文字サイズも調整
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class GohanDragIcon extends StatefulWidget {
  final String iconname;
  final Color color;
  final double size;

  const GohanDragIcon({
    super.key,
    required this.iconname,
    required this.color,
    required this.size,
  });

  @override
  State<GohanDragIcon> createState() => _GohanDragIconState();
}

class _GohanDragIconState extends State<GohanDragIcon> {
  @override
  Widget build(BuildContext context) {
    return Draggable( 
      data: widget.iconname,
      feedback: SvgPicture.asset(
        widget.iconname,
        width: widget.size,
        height: widget.size,
        color: widget.color
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: SvgPicture.asset(
          widget.iconname,
          width: widget.size,
          height: widget.size,
          color: widget.color,
        ),
      ),
      child: SvgPicture.asset(
        widget.iconname,
        width: widget.size,
        height: widget.size,
        color: widget.color,
      ),
    );
  }
}