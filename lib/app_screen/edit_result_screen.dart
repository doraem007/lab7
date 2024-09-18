import 'dart:convert';

import 'package:flutter/material.dart';
import '../model/exam_result.dart';
import 'package:http/http.dart' as http;

class EditResultScreen extends StatefulWidget {
  final ExamResult? studentCode;
  const EditResultScreen({
    super.key,
    this.studentCode,
  });

  @override
  State<EditResultScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditResultScreen> {
  ExamResult? studentCode;
  TextEditingController idController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController pointController = TextEditingController();
  double pointValue = 0;

  @override
  void initState() {
    print("initState"); // สำหรับทดสอบ
    super.initState();

    if (widget.studentCode != null) {
      studentCode = widget.studentCode;
      idController.text = studentCode!.id;
      codeController.text = studentCode!.studentCode;
      nameController.text = studentCode!.courseCode;
      pointController.text = studentCode!.point.toString();
      pointValue = studentCode!.point;
    } else {
      studentCode =
          ExamResult(id: '', courseCode: '', studentCode: '', point: 0);
      idController.text = '';
      codeController.text = '';
      nameController.text = '';
      pointController.text = '0';
      pointValue = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Point"),
        actions: [
          IconButton(
              onPressed: () async {
                int rt = await updateExam(ExamResult(
                    id: idController.text,
                    studentCode: studentCode!.studentCode,
                    courseCode: nameController.text,
                    point: pointValue));
                if (rt != 0) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save)),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: codeController,
              enabled: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Student Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              enabled: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'courseCode',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pointController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Point',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  pointValue = double.tryParse(value) ?? 0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<int> updateExam(ExamResult studentCode) async {
  final response = await http.put(
    Uri.parse('http://192.168.31.153/api/exam_result.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'student_code': studentCode.studentCode,
      'course_code': studentCode.courseCode,
      'point': studentCode.point,
    }),
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return response.statusCode;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to update student.');
  }
}
