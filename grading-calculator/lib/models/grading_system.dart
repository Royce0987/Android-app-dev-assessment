import 'package:flutter/material.dart';

class GradingSystem {
  // Custom grading scale with your exact requirements
  final List<GradeRange> gradeScale;

  GradingSystem() : gradeScale = [
    GradeRange(
        grade: 'A',
        minScore: 80,
        maxScore: 100,
        description: 'Excellent',
        passed: true,
        color: const Color(0xFF10B981),
        gradient: const [Color(0xFF10B981), Color(0xFF34D399)]
    ),
    GradeRange(
        grade: 'B+',
        minScore: 70,
        maxScore: 79,
        description: 'Very Good',
        passed: true,
        color: const Color(0xFF3B82F6),
        gradient: const [Color(0xFF3B82F6), Color(0xFF60A5FA)]
    ),
    GradeRange(
        grade: 'B',
        minScore: 60,
        maxScore: 69,
        description: 'Good',
        passed: true,
        color: const Color(0xFF6366F1),
        gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)]
    ),
    GradeRange(
        grade: 'C+',
        minScore: 55,
        maxScore: 59,
        description: 'Satisfactory',
        passed: true,
        color: const Color(0xFFF59E0B),
        gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)]
    ),
    GradeRange(
        grade: 'C',
        minScore: 50,
        maxScore: 54,
        description: 'Average',
        passed: true,
        color: const Color(0xFFF97316),
        gradient: const [Color(0xFFF97316), Color(0xFFFDBA74)]
    ),
    GradeRange(
        grade: 'D+',
        minScore: 45,
        maxScore: 49,
        description: 'Below Average',
        passed: false,
        color: const Color(0xFFEF4444),
        gradient: const [Color(0xFFEF4444), Color(0xFFF87171)]
    ),
    GradeRange(
        grade: 'D',
        minScore: 40,
        maxScore: 44,
        description: 'Poor',
        passed: false,
        color: const Color(0xFFDC2626),
        gradient: const [Color(0xFFDC2626), Color(0xFFF87171)]
    ),
    GradeRange(
        grade: 'F',
        minScore: 0,
        maxScore: 39,
        description: 'Fail',
        passed: false,
        color: const Color(0xFF991B1B),
        gradient: const [Color(0xFF991B1B), Color(0xFFDC2626)]
    ),
  ];

  String calculateLetterGrade(double score) {
    for (var range in gradeScale) {
      if (score >= range.minScore && score <= range.maxScore) {
        return range.grade;
      }
    }
    return 'F';
  }

  bool isPassing(double score) {
    for (var range in gradeScale) {
      if (score >= range.minScore && score <= range.maxScore) {
        return range.passed;
      }
    }
    return false;
  }

  GradeRange getGradeRange(String grade) {
    return gradeScale.firstWhere((range) => range.grade == grade);
  }

  GradeRange getRangeForScore(double score) {
    return gradeScale.firstWhere((range) => score >= range.minScore && score <= range.maxScore);
  }
}

class GradeRange {
  final String grade;
  final double minScore;
  final double maxScore;
  final String description;
  final bool passed;
  final Color color;
  final List<Color> gradient;

  GradeRange({
    required this.grade,
    required this.minScore,
    required this.maxScore,
    required this.description,
    required this.passed,
    required this.color,
    required this.gradient,
  });
}