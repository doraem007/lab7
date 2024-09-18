import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/exam_result.dart';
import '../model/course.dart';
import 'package:http/http.dart' as http;

class AddExamResultScreen extends StatefulWidget {
  final ExamResult? exam_result;
  final List<Course>? courses;
  const AddExamResultScreen({
    super.key,
    this.exam_result,
    this.courses,
  });

  @override
  State<AddExamResultScreen> createState() => _AddExamResultScreenState();
}

class _AddExamResultScreenState extends State<AddExamResultScreen> {
  ExamResult? exam_result;
  List<Course>? courses;
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController pointController = TextEditingController();
  double pointValue = 0;

  String dropdownValue = "";

  @override
  void initState() {
    super.initState();
    exam_result = widget.exam_result;
    if (exam_result != null) {
      idController.text = exam_result!.id;
      codeController.text = exam_result!.studentCode;
      nameController.text = exam_result!.courseCode;
      pointController.text = exam_result!.point.toString();
      pointValue = exam_result!.point;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add ExamResult"),
        actions: [
          IconButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  codeController.text.isEmpty ||
                  pointController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields.')),
                );
                return;
              }

              int rt = await addExamResult(ExamResult(
                id: idController.text,
                studentCode: codeController.text,
                courseCode: nameController.text,
                point: pointValue,
              ));

              if (rt == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ExamResult add successfully.')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Failed to add exam_result. Error code: $rt')),
                );
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Student Code',
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

Future<int> addExamResult(ExamResult exam_result) async {
  final response = await http.post(
    Uri.parse('http://192.168.31.153/api/exam_result.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'course_code': exam_result.studentCode,
      'student_code': exam_result.courseCode,
      'point': exam_result.point,
    }),
  );

  return response.statusCode;
}
