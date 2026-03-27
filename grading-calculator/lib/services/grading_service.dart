import 'interfaces/igrade_calculator.dart';
import '../models/student.dart';

class GradingService implements IGradeCalculator {
  @override
  double calculateTotal(Map<String, double> scores) {
    double total = 0.0;
    scores.forEach((key, value) {
      total += value;
    });
    return total;
  }

  @override
  String determineLetterGrade(double percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  @override
  Map<String, dynamic> generateReport() {
    return {
      'totalStudents': 0,
      'averageScore': 0.0,
      'highestScore': 0.0,
      'lowestScore': 0.0,
    };
  }

  // Additional methods
  List<Student> sortByGrade(List<Student> students) {
    students.sort((a, b) => b.calculateTotalScore().compareTo(a.calculateTotalScore()));
    return students;
  }
}