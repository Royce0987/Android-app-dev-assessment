import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/excel_service.dart';

class HistoryScreen extends StatefulWidget {
  final ExcelService excelService;

  const HistoryScreen({
    super.key,
    required this.excelService,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    // In a real app, you'd load from shared_preferences or a database
    // For now, show sample data
    setState(() {
      _history = [
        {
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'students': 25,
          'average': 78.5,
          'file': 'CS101_Final_Grades.xlsx',
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'students': 32,
          'average': 72.3,
          'file': 'Math201_Midterm.xlsx',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: _history.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No history yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Import and calculate grades to see history',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insert_drive_file, color: Color(0xFF6366F1)),
              ),
              title: Text(
                item['file'],
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${item['students']} students • Avg: ${item['average']}%',
                style: GoogleFonts.inter(fontSize: 12),
              ),
              trailing: Text(
                _formatDate(item['date']),
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                // In a real app, you'd load the previous results
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}