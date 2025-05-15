import 'package:flutter/material.dart';
import 'manage_employ_auth.dart';
import 'attendance_screen.dart';
import 'records.dart';
import 'package:employ_management/database/employee_database.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  int totalEmployees = 0;
  int presentToday = 0;
  int absentToday = 0;
  int halfDayToday = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchDashboardCounts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes to foreground
      fetchDashboardCounts();
    }
  }

  Future<void> fetchDashboardCounts() async {
    setState(() {
      _isLoading = true;
    });

    final db = DBHelper();

    // Fetch counts from the DB (methods must be defined in DBHelper)
    totalEmployees = await db.getEmployeeCount();
    presentToday = await db.getAttendanceCountFor("Present");
    absentToday = await db.getAttendanceCountFor("Absent");
    halfDayToday = await db.getAttendanceCountFor("Half Day");

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchDashboardCounts,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  SizedBox(height: 20),

                  // Summary Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        buildSummaryCard(
                          "Total Employees",
                          totalEmployees,
                          Colors.blue,
                        ),
                        buildSummaryCard(
                          "Present Today",
                          presentToday,
                          Colors.green,
                        ),
                        buildSummaryCard(
                          "Absent Today",
                          absentToday,
                          Colors.red,
                        ),
                        buildSummaryCard(
                          "Half Day Today",
                          halfDayToday,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Admin Operations
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              "Admin Operations",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                operationTile(
                                  icon: Icons.check_circle_outline,
                                  label: "Attendance",
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AttendanceScreen(),
                                      ),
                                    );
                                    // Refresh data when returning from Attendance screen
                                    fetchDashboardCounts();
                                  },
                                ),
                                operationTile(
                                  icon: Icons.list_alt,
                                  label: "Records",
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => RecordsPage()));
                                  },
                                ),
                                operationTile(
                                  icon: Icons.manage_accounts,
                                  label: "Employees",
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ManageEmployAuth(),
                                      ),
                                    );
                                    // Refresh data when returning from Manage Employees screen
                                    fetchDashboardCounts();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Spacer(),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // logout
                        },
                        icon: Icon(Icons.logout),
                        label: Text("Logout"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget buildSummaryCard(String title, int count, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget operationTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, size: 28, color: Colors.blue),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
