import 'package:flutter/material.dart';
import '../models/student.dart';

class GradeDisplayWidget extends StatelessWidget {
  final Student student;
  final VoidCallback onAddGrade;

  const GradeDisplayWidget({
    super.key,
    required this.student,
    required this.onAddGrade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${student.id}'),
            Text('Grades: ${student.grades.length} assignments'),
            if (student.grades.isNotEmpty)
              Text(
                'Average: ${student.getAverageScore().toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getGradeColor(student.getFinalGrade()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                student.getFinalGrade(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${student.getAverageScore().toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: onAddGrade,
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }
}