import '../models/course.dart';
import '../models/student.dart';
import '../models/grading_system.dart';
import '../services/grading_service.dart';

class GradingController {
  Course? currentCourse;
  final GradingService _gradingService;

  // Constructor with dependency injection
  GradingController({required GradingService gradingService})
      : _gradingService = gradingService;

  // Default constructor
  GradingController.defaultController()
      : _gradingService = GradingService();

  void createCourse(String name, String code) {
    currentCourse = Course(
      courseName: name,
      courseCode: code,
    );
  }

  void addStudentToCourse(Student student) {
    if (currentCourse != null) {
      currentCourse!.students.add(student);
    }
  }

  void addGradeToStudent(String studentId, Grade grade) {
    if (currentCourse != null) {
      var student = currentCourse!.students.firstWhere(
            (s) => s.id == studentId,
        orElse: () => Student.empty(),
      );

      if (student.id.isNotEmpty) {
        student.addGrade(grade);
      }
    }
  }

  Map<String, dynamic> getCourseStatistics() {
    if (currentCourse == null) return {};

    return {
      'courseName': currentCourse!.courseName,
      'courseCode': currentCourse!.courseCode,
      'totalStudents': currentCourse!.students.length,
      'classAverage': currentCourse!.calculateClassAverage(),
      'passingStudents': currentCourse!.getPassingStudents().length,
    };
  }
}