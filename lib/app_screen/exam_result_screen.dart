import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../model/course.dart';
import '../model/exam_result.dart';
import 'add_exam_result_screen.dart';
import 'edit_result_screen.dart';
import 'package:http/http.dart' as http;

class ExamResultScreen extends StatefulWidget {
  final List<Course>? courses;
  const ExamResultScreen({
    super.key,
    this.courses,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  List<Course>? courses;
  late Future<List<ExamResult>> examResults;
  String dropdownValue = "";

  @override
  void initState() {
    print("initState"); // สำหรับทดสอบ
    super.initState();
    courses = (widget.courses ?? []).toList();
    if (courses!.isNotEmpty) {
      dropdownValue = courses!.first.courseCode;
      examResults = fetchExamResults(dropdownValue);
    }
  }

  void _refreshData(String courseCode) {
    setState(() {
      print("setState"); // สำหรับทดสอบ
      examResults = fetchExamResults(courseCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Result'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddExamResultScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<ExamResult>>(
          future: examResults,
          builder: (context, snapshot) {
            print("builder"); // สำหรับทดสอบ
            print(snapshot.connectionState); // สำหรับทดสอบ
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                    child: snapshot.data!.isNotEmpty
                        ? ListView.separated(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(snapshot.data![index].studentCode),
                                subtitle:
                                    Text(snapshot.data![index].point.toString()),
                                trailing: Wrap(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditResultScreen(
                                                    studentCode:
                                                        snapshot.data![index]),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text('Confirm Delete'),
                                            content: Text(
                                                "Do you want to delete: ${snapshot.data![index].studentCode}"),
                                            actions: <Widget>[
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                                onPressed: () async {
                                                  await deleteExam(
                                                      snapshot.data![index]);
                                                  setState(() {
                                                    examResults =
                                                        fetchExamResults(
                                                            dropdownValue);
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Delete'),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      Colors.blueGrey,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          )
                        : const Center(child: Text('No items')),
                  ),
                  if (courses!.isNotEmpty)
                    Expanded(
                      child: DropdownMenu<String>(
                        initialSelection: dropdownValue,
                        onSelected: (String? value) {
                          setState(() {
                            dropdownValue = value!;
                            _refreshData(dropdownValue);
                          });
                        },
                        dropdownMenuEntries: courses!
                            .map<DropdownMenuEntry<String>>((Course value) {
                          return DropdownMenuEntry<String>(
                            value: value.courseCode,
                            label: value.courseCode,
                          );
                        }).toList(),
                      ),
                    ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // ปุ่มทดสอบสำหรับดึงข้อมูลซ้ำ
        onPressed: () {
          setState(() {
            _refreshData(
                dropdownValue); // เรียกฟังก์ชันอัพเดทข้อมูลโดยใช้ dropdownValue ปัจจุบัน
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// ดึงข้อมูลผลการสอบ
Future<List<ExamResult>> fetchExamResults(String courseCode) async {
  final response = await http.get(Uri.parse(
      'http://192.168.31.153/api/exam_result.php?course_code=$courseCode'));

  if (response.statusCode == 200) {
    return compute(parseExamResults, response.body);
  } else {
    throw Exception('Failed to load Exam Results');
  }
}

// ลบผลการสอบ
Future<int> deleteExam(ExamResult examResult) async {
  final response = await http.delete(
    Uri.parse('http://192.168.31.153/api/exam_result.php?id=${examResult.id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    return response.statusCode;
  } else {
    throw Exception('Failed to delete exam result.');
  }
}

// แปลง JSON เป็น List ของ ExamResult
List<ExamResult> parseExamResults(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<ExamResult>((json) => ExamResult.fromJson(json)).toList();
}
