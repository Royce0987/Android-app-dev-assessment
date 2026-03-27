import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/student.dart';
import '../models/grading_system.dart';

class ExcelService {
  Future<List<Student>> importExcelFile(String filePath) async {
    List<Student> students = [];

    try {
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      var sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) return students;

      // Assume first row is headers: Name, ID, Score
      for (var row in sheet.rows.skip(1)) {
        if (row.length >= 3 && row[0]?.value != null) {
          String name = row[0]!.value.toString();
          String id = row[1]?.value.toString() ?? '';
          double score = double.tryParse(row[2]?.value.toString() ?? '0') ?? 0;

          students.add(Student(name: name, id: id, score: score));
        }
      }
    } catch (e) {
      throw Exception('Error reading Excel file: $e');
    }

    return students;
  }

  Future<String> exportResults(List<Student> students, GradingSystem gradingSystem) async {
    // Calculate grades first
    for (var student in students) {
      student.calculateGrade(gradingSystem);
    }

    var excel = Excel.createExcel();
    Sheet sheet = excel['Grade Results'];

    // Header row - use TextCellValue for strings
    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('ID'),
      TextCellValue('Original Score'),
      TextCellValue('Final Score'),
      TextCellValue('Grade'),
      TextCellValue('Status'),
    ]);

    // Add data
    for (var student in students) {
      sheet.appendRow([
        TextCellValue(student.name),
        TextCellValue(student.id),
        DoubleCellValue(student.score),
        DoubleCellValue(student.finalScore),
        TextCellValue(student.letterGrade),
        TextCellValue(student.passed ? 'PASS' : 'FAIL'),
      ]);
    }

    // Add empty row
    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([TextCellValue('Statistics')]);

    int passedCount = students.where((s) => s.passed).length;
    double passRate = students.isEmpty ? 0 : (passedCount / students.length) * 100;
    double averageScore = students.isEmpty ? 0 : students.map((s) => s.finalScore).reduce((a, b) => a + b) / students.length;

    sheet.appendRow([
      TextCellValue('Total Students'),
      IntCellValue(students.length),
    ]);
    sheet.appendRow([
      TextCellValue('Passed'),
      IntCellValue(passedCount),
    ]);
    sheet.appendRow([
      TextCellValue('Failed'),
      IntCellValue(students.length - passedCount),
    ]);
    sheet.appendRow([
      TextCellValue('Pass Rate'),
      TextCellValue('${passRate.toStringAsFixed(1)}%'),
    ]);
    sheet.appendRow([
      TextCellValue('Class Average'),
      DoubleCellValue(averageScore),
    ]);

    // Save file
    final directory = await getDownloadsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${directory?.path}/grade_results_$timestamp.xlsx';

    File(path).writeAsBytesSync(excel.encode()!);

    return path;
  }
}