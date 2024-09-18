import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/student.dart';
import 'package:http/http.dart' as http;

class AddStudentScreen extends StatefulWidget {
  final Student? student;
  const AddStudentScreen({super.key, this.student});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  Student? student;
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  String dropdownValue = '';

  @override
  void initState() {
    super.initState();
    student = widget.student;
    if (student != null) {
      codeController.text = student!.studentCode;
      nameController.text = student!.studentName;
      dropdownValue = student!.gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Student"),
        actions: [
          IconButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  codeController.text.isEmpty ||
                  dropdownValue.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields.')),
                );
                return;
              }

              int rt = await addStudent(Student(
                studentCode: codeController.text,
                studentName: nameController.text,
                gender: dropdownValue,
              ));

              if (rt == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student add successfully.')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to add student. Error code: $rt')),
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
                labelText: 'Student Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Student Name',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: dropdownValue.isNotEmpty ? dropdownValue : null,
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value ?? '';
                });
              },
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: ['F', 'M'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

Future<int> addStudent(Student student) async {
  final response = await http.post(
    Uri.parse('http://192.168.31.153/api/student.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'student_code': student.studentCode,
      'student_name': student.studentName,
      'gender': student.gender,
    }),
  );

  return response.statusCode;
}
