import '../../models/student.dart';
import '../../models/course.dart';

// Another interface
abstract class IExcelHandler {
  Future<void> exportToExcel(List<Student> students, String fileName);
  Future<List<Student>> importFromExcel(String filePath);
  bool validateExcelFormat(String filePath);
  Future<void> generateGradeSheet(Course course, String fileName);
}