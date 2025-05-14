import 'package:flutter/material.dart';
import 'add_employ.dart';

class EmployeeOperationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Operations"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add Employee Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => AddEmployeeScreen()));
              },
              child: Text("Add Employee"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            // Edit Employee Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Edit Employee Screen
              },
              child: Text("Edit Employee"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            // Delete Employee Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Delete Employee Screen
              },
              child: Text("Delete Employee"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}