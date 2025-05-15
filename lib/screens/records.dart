import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:employ_management/database/employee_database.dart';

class RecordsPage extends StatefulWidget {
  @override
  _RecordsPageState createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final DBHelper db = DBHelper();
  DateTime selectedDate = DateTime.now();

  int presentCount = 0;
  int absentCount = 0;
  int halfDayCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCountsForDate(selectedDate);
  }

  Future<void> _fetchCountsForDate(DateTime date) async {
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    int present = await db.getAttendanceCountForDate("Present", dateStr);
    int absent = await db.getAttendanceCountForDate("Absent", dateStr);
    int halfDay = await db.getAttendanceCountForDate("Half Day", dateStr);

    setState(() {
      presentCount = present;
      absentCount = absent;
      halfDayCount = halfDay;
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchCountsForDate(picked);
    }
  }

  Widget _buildCard(String title, IconData icon, int count, Color color) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        trailing: Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(title: Text("Attendance Records")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text("Select Date: ", style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(formattedDate, style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          _buildCard("Present", Icons.check_circle, presentCount, Colors.green),
          _buildCard("Absent", Icons.cancel, absentCount, Colors.red),
          _buildCard("Half Day", Icons.access_time, halfDayCount, Colors.amber),
        ],
      ),
    );
  }
}
