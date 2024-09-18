class ExamResult {
  final String id;
  final String studentCode;
  final String courseCode;
  final double point;

  ExamResult({
    required this.id,
    required this.studentCode,
    required this.courseCode,
    required this.point,
  });

  // ส่วนของ name constructor ที่จะแปลง json string มาเป็น ExamResult object
  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'],
      studentCode: json['student_code'],
      courseCode: json['course_code'],
      point: double.parse(json['point']),
    );
  }
}
