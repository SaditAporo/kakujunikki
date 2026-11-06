import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/material.dart';
import 'benrikansu.dart';
import 'hozon.dart';
import 'ccccamera.dart';

class DiaryPage extends StatefulWidget {
  final String userName;
  final String name;
  final int userId;
  const DiaryPage({super.key, required this.userName, required this.name, required this.userId});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController eventController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  String? lineId ;

  int _systolic = 120; // 上の血圧
  int _diastolic = 80; // 下の血圧
  int _pulse = 70; // 脈拍
  int _temperature = 36; // 体温
  int _tems = 5;
  String? selectedMood;
  String? selectedWeather;

  @override
  void initState() {
    super.initState();
    loadLineId();
  }

  Future<void> loadLineId() async {
    final id = await ApiService.getLineId(widget.userId);
    setState(() {
      lineId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
      final size = MediaQuery.of(context).size;
      final isWide = size.width > 600;
      final now = DateTime.now();
      final formattedDateTime = '${now.year}/${now.month}/${now.day}   '
          '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';
      return Scaffold(
      appBar: AppBar(
        title: Text(formattedDateTime, style: TextStyle(fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            SizedBox(
              width: isWide ? 800 : size.width * 0.8,
              child: TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '日記のタイトル（必須）',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'タイトルは必須です';
                }
                return null;
              },
            ),
            ),
            const SizedBox(height: 70),
            const Text('🌤️ 今日の天気を選んでください:'),
            ChoiceSelector(
              options: ['☀️','⛅','🌧️','⛄'],
              onSelected: (weather) { selectedWeather = weather; },
            ),
            const SizedBox(height: 70),

        const Text('血圧を入力',textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumberPicker(
              minValue: 50,
              maxValue: 300,
              value: _systolic,
              onChanged: (v) => setState(() => _systolic = v),
            ),
            const SizedBox(width: 10),
            const Text('/'),
            const SizedBox(width: 10),
            NumberPicker(
              minValue: 30,
              maxValue: 200,
              value: _diastolic,
              onChanged: (v) => setState(() => _diastolic = v),
            ),
            const SizedBox(width: 10),
            const Text('/'),
            const SizedBox(width: 10),
            NumberPicker(
              minValue: 30,
              maxValue: 200,
              value: _pulse,
              onChanged: (v) => setState(() => _pulse = v),
            ),
          ],
        ),

            const SizedBox(height: 10),
            Text('$_systolic / $_diastolic / $_pulse',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 70),

    Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const SizedBox(height: 20),
      const Text('体温を入力してください',
      style: TextStyle(fontSize: 18),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NumberPicker(
            value: _temperature,
            minValue: 30,
            maxValue: 42,
            onChanged: (v) => setState(() => _temperature = v),
          ),
            NumberPicker(
            value: _tems,
            minValue: 0,
            maxValue: 9,
            onChanged: (v) => setState(() => _tems = v),
          ),
          const SizedBox(width: 10),
          const Text('℃', style: TextStyle(fontSize: 20)),
        ],
      ),
    ],
  ),

            const SizedBox(height: 10),
            Text('$_temperature. $_tems℃',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 70),

            const SizedBox(height: 70),
            const Text('😄 今日の気分を選んでください:'),
            ChoiceSelector(
              options: ['😊','😐','😢','😡','😴'],
              onSelected: (mood) { selectedMood = mood; },
            ),
            const SizedBox(height: 70),
            SizedBox(
              width: isWide ? 800 : size.width * 0.8,
            child: TextField(
              controller: eventController,
              decoration: const InputDecoration(
                labelText: '今日の出来事',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              ),
            ),
            const SizedBox(height: 70),

            ElevatedButton(
              onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  } 
                final diary = {
                  'user_id': widget.userId,
                  'user_name': widget.userName,
                  'notify_to': lineId,
                  'diary': {
                    'title': titleController.text,
                    'weather': selectedWeather,
                    'mood': selectedMood,
                    'blood_pressure': '$_systolic / $_diastolic / $_pulse',
                    'temperature': '$_temperature.$_tems',
                    'event': eventController.text,
                    'date': now.toIso8601String(),
                  },
              };

              Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraPage(userName: widget.userName,name: widget.name,userId: widget.userId, diary:diary)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('保存', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
      ),
    );
  }
}