// Abstract class demonstrating abstraction
abstract class Assessment {
  String name;
  double maxScore;
  double weight; // Weight in percentage (e.g., 0.3 for 30%)

  Assessment({
    required this.name,
    required this.maxScore,
    required this.weight,
  });

  // Abstract method - must be implemented by child classes
  double calculateContribution(double score);

  // Concrete method - will be inherited
  double getPercentageScore(double score) {
    return (score / maxScore) * 100;
  }
}