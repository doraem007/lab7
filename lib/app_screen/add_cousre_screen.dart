import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/course.dart';
import 'package:http/http.dart' as http;

class AddCourseScreen extends StatefulWidget {
  final Course? course;
  const AddCourseScreen({super.key, this.course});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  Course? course;
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController creditController = TextEditingController();
  int creditValue = 0;

  @override
  void initState() {
    super.initState();
    course = widget.course;
    if (course != null) {
      codeController.text = course!.courseCode;
      nameController.text = course!.courseName;
      creditController.text = course!.credit.toString();
      creditValue = course!.credit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Course"),
        actions: [
          IconButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  codeController.text.isEmpty ||
                  creditController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields.')),
                );
                return;
              }

              int rt = await addCourse(Course(
                courseCode: codeController.text,
                courseName: nameController.text,
                credit: creditValue,
              ));

              if (rt == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course add successfully.')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to add course. Error code: $rt')),
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

Future<int> addCourse(Course course) async {
  final response = await http.post(
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

  return response.statusCode;
}
