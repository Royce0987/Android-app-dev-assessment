import '../services/excel_service.dart';
import '../models/course.dart';
import '../models/student.dart';

class ExcelController {
  final ExcelService _excelService;

  ExcelController() : _excelService = ExcelService();

  Future<void> exportCourseGrades(Course course, String fileName) async {
    await _excelService.generateGradeSheet(course, fileName);
  }

  Future<void> exportStudentGrades(List<Student> students, String fileName) async {
    await _excelService.exportToExcel(students, fileName);
  }
}