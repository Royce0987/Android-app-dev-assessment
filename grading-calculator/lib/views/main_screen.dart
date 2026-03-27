import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/grading_controller.dart';
import '../services/excel_service.dart';
import '../models/student.dart';
import '../widgets/add_student_dialog.dart';
import '../widgets/grade_display_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final GradingController _controller = GradingController.defaultController();
  final ExcelService _excelService = ExcelService();

  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentEmailController = TextEditingController();
  final TextEditingController _studentDepartmentController = TextEditingController();

  bool _isCourseCreated = false;
  bool _isLoading = false;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: _isCourseCreated ? _buildMainContent() : _buildCourseCreation(),
        ),
      ),
    );
  }

  Widget _buildCourseCreation() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school,
                  size: 80,
                  color: Color(0xFF667EEA),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to Grading Calculator',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF667EEA),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Android Application Development Course',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _courseNameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    prefixIcon: Icon(Icons.book),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _courseCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Course Code',
                    prefixIcon: Icon(Icons.code),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _createCourse,
                  child: const Text('Create Course'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _importCourseFromExcel,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import from Excel'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Color(0xFF667EEA)),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatisticsCards(),
                const SizedBox(height: 16),
                _buildGradeDistributionChart(),
                const SizedBox(height: 16),
                _buildStudentManagement(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _controller.currentCourse!.courseName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _controller.currentCourse!.courseCode,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    onPressed: _importGrades,
                    tooltip: 'Import Grades',
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.white),
                    onPressed: _exportToExcel,
                    tooltip: 'Export to Excel',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    var stats = _controller.getCourseStatistics();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Students',
          '${stats['totalStudents']}',
          Icons.people,
          const Color(0xFF4A90E2),
          const Color(0xFF667EEA),
        ),
        _buildStatCard(
          'Class Average',
          '${stats['classAverage']?.toStringAsFixed(1) ?? '0'}%',
          Icons.show_chart,
          const Color(0xFF50E3C2),
          const Color(0xFF48D1CC),
        ),
        _buildStatCard(
          'Passing Students',
          '${stats['passingStudents']}',
          Icons.verified,
          const Color(0xFF4CAF50),
          const Color(0xFF8BC34A),
        ),
        _buildStatCard(
          'Assignments',
          '${_getTotalAssignments()}',
          Icons.assignment,
          const Color(0xFFFF9800),
          const Color(0xFFFFB74D),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color startColor, Color endColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeDistributionChart() {
    if (_controller.currentCourse == null || _controller.currentCourse!.students.isEmpty) {
      return const SizedBox.shrink();
    }

    Map<String, int> distribution = {
      'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0
    };

    for (var student in _controller.currentCourse!.students) {
      String grade = student.getFinalGrade();
      distribution[grade] = (distribution[grade] ?? 0) + 1;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Color(0xFF667EEA)),
                const SizedBox(width: 8),
                const Text(
                  'Grade Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _controller.currentCourse!.students.length.toDouble(),
                  barGroups: distribution.entries.map((entry) {
                    return BarChartGroupData(
                      x: _getGradeIndex(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: _getGradeColor(entry.key),
                          width: 30,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(_getGradeFromIndex(value.toInt()));
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentManagement() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _studentNameController,
                    decoration: const InputDecoration(
                      labelText: 'Student Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Student ID',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _studentEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _studentDepartmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addStudent,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importStudentsFromExcel,
                    icon: const Icon(Icons.upload),
                    label: const Text('Import'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF667EEA)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _controller.currentCourse!.students.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No students added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Add students or import from Excel',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controller.currentCourse!.students.length,
              itemBuilder: (context, index) {
                var student = _controller.currentCourse!.students[index];
                return GradeDisplayWidget(
                  student: student,
                  onAddGrade: () => _showAddGradeDialog(student),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createCourse() {
    if (_courseNameController.text.isNotEmpty && _courseCodeController.text.isNotEmpty) {
      setState(() {
        _controller.createCourse(
          _courseNameController.text,
          _courseCodeController.text,
        );
        _isCourseCreated = true;
      });
    }
  }

  void _addStudent() {
    if (_studentNameController.text.isNotEmpty && _studentIdController.text.isNotEmpty) {
      setState(() {
        var student = Student(
          name: _studentNameController.text,
          id: _studentIdController.text,
          email: _studentEmailController.text,
          department: _studentDepartmentController.text,
        );
        _controller.addStudentToCourse(student);
        _studentNameController.clear();
        _studentIdController.clear();
        _studentEmailController.clear();
        _studentDepartmentController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _importStudentsFromExcel() async {
    setState(() => _isLoading = true);

    var students = await _excelService.importStudentsFromExcel();

    if (students != null && students.isNotEmpty) {
      setState(() {
        for (var student in students) {
          _controller.addStudentToCourse(student);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported ${students.length} students successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No students imported or file cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importGrades() async {
    setState(() => _isLoading = true);

    var gradesMap = await _excelService.importGradesFromExcel();

    if (gradesMap != null && gradesMap.isNotEmpty) {
      setState(() {
        gradesMap.forEach((studentId, grades) {
          var student = _controller.currentCourse?.students.firstWhere(
                (s) => s.id == studentId,
            orElse: () => Student.empty(),
          );

          if (student != null && student.id.isNotEmpty) {
            for (var grade in grades) {
              student.addGrade(grade);
            }
          }
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported grades for ${gradesMap.length} students!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importCourseFromExcel() async {
    var students = await _excelService.importStudentsFromExcel();

    if (students != null && students.isNotEmpty) {
      setState(() {
        _controller.createCourse('Imported Course', 'IMP001');
        for (var student in students) {
          _controller.addStudentToCourse(student);
        }
        _isCourseCreated = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course imported with ${students.length} students!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showAddGradeDialog(Student student) {
    showDialog(
      context: context,
      builder: (context) => AddStudentDialog(
        student: student,
        onGradeAdded: () {
          setState(() {});
        },
      ),
    );
  }

  Future<void> _exportToExcel() async {
    setState(() => _isLoading = true);

    await _excelService.exportCourseReport(
      _controller.currentCourse!,
      '${_controller.currentCourse!.courseCode}_report',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exported to Excel successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  int _getTotalAssignments() {
    int total = 0;
    final students = _controller.currentCourse?.students ?? [];
    for (var student in students) {
      total += student.grades.length;
    }
    return total;
  }
  int _getGradeIndex(String grade) {
    switch (grade) {
      case 'A': return 0;
      case 'B': return 1;
      case 'C': return 2;
      case 'D': return 3;
      default: return 4;
    }
  }

  String _getGradeFromIndex(int index) {
    switch (index) {
      case 0: return 'A';
      case 1: return 'B';
      case 2: return 'C';
      case 3: return 'D';
      default: return 'F';
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A': return const Color(0xFF4CAF50);
      case 'B': return const Color(0xFF8BC34A);
      case 'C': return const Color(0xFFFFC107);
      case 'D': return const Color(0xFFFF9800);
      default: return const Color(0xFFF44336);
    }
  }
}