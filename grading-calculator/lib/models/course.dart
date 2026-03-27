import 'student.dart';

class Course {
  String courseName;
  String courseCode;
  List<Student> students;

  // Default constructor
  Course({
    required this.courseName,
    required this.courseCode,
    List<Student>? students,
  }) : students = students ?? [];

  double calculateClassAverage() {
    if (students.isEmpty) return 0.0;

    double sum = 0.0;
    // Using single loop (2 of 4 allowed loops)
    for (var student in students) {
      sum += student.calculateTotalScore();
    }
    return sum / students.length;
  }

  List<Student> getPassingStudents() {
    List<Student> passing = [];
    // Using single loop (3 of 4 allowed loops)
    for (var student in students) {
      if (student.getFinalGrade() != 'F') {
        passing.add(student);
      }
    }
    return passing;
  }
}