import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/grading_system.dart';

class AddStudentDialog extends StatefulWidget {
  final Student student;
  final VoidCallback onGradeAdded;

  const AddStudentDialog({
    super.key,
    required this.student,
    required this.onGradeAdded,
  });

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final TextEditingController _gradeNameController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  double _weight = 1.0;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Grade for ${widget.student.name}'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _gradeNameController,
              decoration: const InputDecoration(
                labelText: 'Assignment Name',
                hintText: 'e.g., Midterm Exam',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _scoreController,
              decoration: InputDecoration(
                labelText: 'Score (0-100)',
                hintText: 'e.g., 85.5',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Weight: '),
                Expanded(
                  child: Slider(
                    value: _weight,
                    min: 0.1,
                    max: 2.0,
                    divisions: 19,
                    label: _weight.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _weight = value;
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_weight.toStringAsFixed(1)}x',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Weight affects how much this assignment counts toward the final grade',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addGrade,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Add Grade'),
        ),
      ],
    );
  }

  void _addGrade() {
    if (_gradeNameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter assignment name';
      });
      return;
    }

    if (_scoreController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a score';
      });
      return;
    }

    double? score = double.tryParse(_scoreController.text);
    if (score == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return;
    }

    if (score < 0 || score > 100) {
      setState(() {
        _errorMessage = 'Score must be between 0 and 100';
      });
      return;
    }

    // Add the grade
    widget.student.addGrade(Grade(
      name: _gradeNameController.text,
      score: score,
      weight: _weight,
    ));

    widget.onGradeAdded();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grade added for ${widget.student.name}!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _gradeNameController.dispose();
    _scoreController.dispose();
    super.dispose();
  }
}