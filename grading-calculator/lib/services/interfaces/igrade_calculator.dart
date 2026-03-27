// Interface (using abstract class in Dart)
abstract class IGradeCalculator {
  double calculateTotal(Map<String, double> scores);
  String determineLetterGrade(double percentage);
  Map<String, dynamic> generateReport();
}