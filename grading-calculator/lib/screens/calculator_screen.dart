import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/grading_system.dart';
import '../models/student.dart';
import '../services/excel_service.dart';
import '../widgets/grade_card.dart';
import '../widgets/stat_card.dart';

class CalculatorScreen extends StatefulWidget {
  final GradingSystem gradingSystem;
  final ExcelService excelService;

  const CalculatorScreen({
    super.key,
    required this.gradingSystem,
    required this.excelService,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  List<Student> _students = [];
  bool _isLoading = false;
  String? _fileName;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
    return _isLoading
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
          ),
          const SizedBox(height: 20),
          Text(
            'Processing grades...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    )
        : CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildHeader(),
          ),
        ),
        if (_students.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(),
          )
        else ...[
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildStatistics(),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildGradeDistribution(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => GradeCard(student: _students[index])
                    .animate()
                    .fadeIn(duration: 400.ms, delay: (100 * index).ms)
                    .slideX(begin: 0.2, end: 0),
                childCount: _students.length,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA),
            const Color(0xFF764BA2),
            const Color(0xFFF093FB),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 Grading Calculator',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Smart Grade Management System',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.calculate,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _buildGradientButton(
                  onPressed: _importExcel,
                  icon: Icons.upload_file,
                  label: 'Import Excel',
                  gradient: const [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
                  textColor: const Color(0xFF667EEA),
                ),
              ),
              const SizedBox(width: 12),
              if (_students.isNotEmpty)
                Expanded(
                  child: _buildGradientButton(
                    onPressed: _exportResults,
                    icon: Icons.download,
                    label: 'Export Results',
                    gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                    textColor: Colors.white,
                  ),
                ),
            ],
          ),
          if (_fileName != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, size: 20, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _fileName!,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_students.length} students',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.2),
                  const Color(0xFF764BA2).withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.upload_file,
              size: 80,
              color: const Color(0xFF667EEA).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '✨ Welcome to Grading Calculator',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ).createShader(const Rect.fromLTWH(0, 0, 300, 50)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Import your Excel file to calculate grades automatically',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          _buildGradientButton(
            onPressed: _importExcel,
            icon: Icons.upload,
            label: 'Import Excel File',
            gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final stats = _calculateStatistics();

    return Container(
      margin: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
        children: [
          StatCard(
            title: 'Total Students',
            value: '${stats['total']}',
            icon: Icons.people_alt,
            color: const Color(0xFF667EEA),
            gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          StatCard(
            title: 'Pass Rate',
            value: '${stats['passRate']}%',
            icon: Icons.trending_up,
            color: const Color(0xFF10B981),
            gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
          ),
          StatCard(
            title: 'Class Average',
            value: '${stats['average']}%',
            icon: Icons.show_chart,
            color: const Color(0xFFF59E0B),
            gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
          ),
          StatCard(
            title: 'Top Grade',
            value: stats['topGrade'],
            icon: Icons.emoji_events,
            color: const Color(0xFFEF4444),
            gradient: const [Color(0xFFEF4444), Color(0xFFF87171)],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeDistribution() {
    final distribution = _getGradeDistribution();
    final gradeOrder = ['A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.bar_chart, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Text(
                'Grade Distribution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _students.isEmpty ? 1 : _students.length.toDouble(),
                barGroups: gradeOrder.map((grade) {
                  return BarChartGroupData(
                    x: gradeOrder.indexOf(grade),
                    barRods: [
                      BarChartRodData(
                        toY: distribution[grade]?.toDouble() ?? 0,
                        color: _getGradeColor(grade),
                        width: 36,
                        borderRadius: BorderRadius.circular(12),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _students.length.toDouble(),
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            gradeOrder[value.toInt()],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: _getGradeColor(gradeOrder[value.toInt()]),
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} students',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importExcel() async {
    setState(() => _isLoading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        _fileName = result.files.single.name;
        final students = await widget.excelService.importExcelFile(result.files.single.path!);

        setState(() {
          _students = students;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('✨ Imported ${students.length} students successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(12),
          ),
        );
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text('Error: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }

  Future<void> _exportResults() async {
    setState(() => _isLoading = true);

    try {
      final path = await widget.excelService.exportResults(
        _students,
        widget.gradingSystem,
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Results exported to: ${path.split('\\').last}')),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(12),
          action: SnackBarAction(
            label: 'Share',
            textColor: Colors.white,
            onPressed: () => _shareFile(path),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareResults() async {
    await Share.share(
      '📊 Grading Calculator Results\n\n'
          '━━━━━━━━━━━━━━━━━━━━━━\n'
          '📈 Total Students: ${_students.length}\n'
          '✅ Pass Rate: ${_calculateStatistics()['passRate']}%\n'
          '📊 Class Average: ${_calculateStatistics()['average']}%\n'
          '🏆 Top Grade: ${_calculateStatistics()['topGrade']}\n'
          '━━━━━━━━━━━━━━━━━━━━━━\n'
          'Generated by Grading Calculator ✨',
      subject: 'Grading Results',
    );
  }

  Future<void> _shareFile(String path) async {
    await Share.shareXFiles(
      [XFile(path)],
      text: '📊 Grading Calculator - Grade Report',
    );
  }

  Map<String, dynamic> _calculateStatistics() {
    if (_students.isEmpty) {
      return {'total': 0, 'passRate': 0, 'average': 0, 'topGrade': 'N/A'};
    }

    double totalAvg = 0;
    int passed = 0;
    String topGrade = 'F';
    final gradePriority = ['A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];

    for (var student in _students) {
      totalAvg += student.finalScore;
      if (student.passed) passed++;

      final currentIndex = gradePriority.indexOf(student.letterGrade);
      final topIndex = gradePriority.indexOf(topGrade);
      if (currentIndex < topIndex) {
        topGrade = student.letterGrade;
      }
    }

    return {
      'total': _students.length,
      'passRate': ((passed / _students.length) * 100).toStringAsFixed(1),
      'average': (totalAvg / _students.length).toStringAsFixed(1),
      'topGrade': topGrade,
    };
  }

  Map<String, int> _getGradeDistribution() {
    Map<String, int> distribution = {
      'A': 0, 'B+': 0, 'B': 0, 'C+': 0, 'C': 0, 'D+': 0, 'D': 0, 'F': 0
    };

    for (var student in _students) {
      distribution[student.letterGrade] = (distribution[student.letterGrade] ?? 0) + 1;
    }

    return distribution;
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A': return const Color(0xFF10B981);
      case 'B+': return const Color(0xFF3B82F6);
      case 'B': return const Color(0xFF6366F1);
      case 'C+': return const Color(0xFFF59E0B);
      case 'C': return const Color(0xFFF97316);
      case 'D+': return const Color(0xFFEF4444);
      case 'D': return const Color(0xFFDC2626);
      default: return const Color(0xFF991B1B);
    }
  }
}