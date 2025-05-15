import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:employ_management/database/employee_database.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final DBHelper db = DBHelper();

  List<Map<String, dynamic>> attendanceList = [];
  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Map<int, String> currentAttendance = {}; // Store current attendance states

  @override
  void initState() {
    super.initState();
    fetchAttendanceAndEmployees();
  }

  Future<void> fetchAttendanceAndEmployees() async {
    setState(() {
      isLoading = true;
    });

    // Fetch all employees
    employees = (await db.getEmployees()).map((e) => e.toMap()).toList();

    // Fetch attendance for selected date
    attendanceList = await db.getAttendanceByDate(formattedDate);

    // Initialize all employees as absent by default
    for (var employee in employees) {
      int employeeId = employee['id'];
      currentAttendance[employeeId] = getStatus(employeeId);
    }

    setState(() {
      isLoading = false;
    });
  }

  // Get attendance status for an employee, returns "Absent" if not marked
  String getStatus(int employeeId) {
    final record = attendanceList.firstWhere(
      (element) => element['employeeId'] == employeeId,
      orElse: () => {},
    );
    return record.isNotEmpty ? record['status'] : 'Absent';
  }

  // Mark attendance for an employee
  Future<void> markAttendance(int employeeId, String status) async {
    // Update local attendance state first
    setState(() {
      currentAttendance[employeeId] = status;
    });
  }

  // Save all attendance records at once
  Future<void> saveAllAttendance() async {
    setState(() {
      isLoading = true;
    });

    // First delete existing records for this date to avoid duplicates
    for (var record in attendanceList) {
      await db.deleteAttendance(record['id']);
    }

    // Insert all current attendance records
    for (var employee in employees) {
      int employeeId = employee['id'];
      String status = currentAttendance[employeeId] ?? 'Absent';
      await db.insertAttendance(
        employeeId: employeeId,
        status: status,
        date: formattedDate,
      );
    }

    // Refresh data from database
    await fetchAttendanceAndEmployees();

    // Show success dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Attendance saved. Email sent to all employees.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  // Show date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
      fetchAttendanceAndEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Attendance")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance"),
        actions: [
          // Date picker button
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Select date',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${DateFormat('dd MMM, yyyy').format(selectedDate)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Quick options for attendance
                DropdownButton<String>(
                  hint: Text('Mark all as...'),
                  items:
                      ['Present', 'Half Day', 'Absent']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        for (var employee in employees) {
                          currentAttendance[employee['id']] = value;
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Attendance list
          Expanded(
            child: ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                final employeeId = employee['id'];
                final status = currentAttendance[employeeId] ?? 'Absent';

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(employee['name']),
                    subtitle: Text("Status: $status"),
                    trailing: DropdownButton<String>(
                      value: status,
                      items:
                          ['Present', 'Half Day', 'Absent']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          markAttendance(employeeId, value);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Submit button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: saveAllAttendance,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.blue,
              ),
              child: Text('Submit Attendance', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
