import 'grading_system.dart';

class Student {
  final String name;
  final String id;
  final double score;
  String letterGrade;
  bool passed;
  double finalScore;
  GradeRange? gradeRange;

  Student({
    required this.name,
    required this.id,
    required this.score,
  }) : finalScore = score,
        letterGrade = '',
        passed = false;

  void calculateGrade(GradingSystem gradingSystem) {
    letterGrade = gradingSystem.calculateLetterGrade(score);
    passed = gradingSystem.isPassing(score);
    finalScore = score;
    gradeRange = gradingSystem.getRangeForScore(score);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'score': score,
      'letterGrade': letterGrade,
      'passed': passed,
      'finalScore': finalScore,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      name: map['name'],
      id: map['id'],
      score: map['score'],
    );
  }
}