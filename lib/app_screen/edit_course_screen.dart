import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/course.dart';
import 'package:http/http.dart' as http;

class EditCourseScreen extends StatefulWidget {
  final Course? course;
  const EditCourseScreen({
    super.key,
    this.course,
  });

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  Course? course;
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController creditController = TextEditingController();
  int creditValue = 0;

  @override
  void initState() {
    print("initState");
    super.initState();
    if (widget.course != null) {
      course = widget.course;
      codeController.text = course!.courseCode;
      nameController.text = course!.courseName;
      creditController.text = course!.credit.toString();
      creditValue = course!.credit;
    } else {
      course = Course(courseCode: '', courseName: '', credit: 0);
      codeController.text = '';
      nameController.text = '';
      creditController.text = '0';
      creditValue = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Course"),
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                creditValue = int.tryParse(creditController.text) ?? 0;
              });

              // เรียกใช้ฟังก์ชัน updateCourse
              int responseCode = await updateCourse(Course(
                  courseCode: codeController.text,
                  courseName: nameController.text,
                  credit: creditValue));

              if (responseCode == 200) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update course. Status code: ${responseCode}')),
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
              enabled: false,
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
                labelText: 'Course Name',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: creditController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Credit',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  creditValue = int.tryParse(value) ?? 0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<int> updateCourse(Course course) async {
  final response = await http.put(
    Uri.parse('http://192.168.31.153/api/course.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },

    body: jsonEncode(<String, dynamic>{
      'course_code': course.courseCode,
      'course_name': course.courseName,
      'credit': course.credit,
    }),
  );
  print(course.courseCode);
  print(course.courseName);
  print(course.credit);

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    if (responseBody['status'] == 'ok') {
      return response.statusCode;
    } else {
      throw Exception('Failed to update course. ${responseBody['message']}');
    }
  } else {
    throw Exception('Failed to update course. Status code: ${response.statusCode}');
  }
}
