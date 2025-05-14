import 'dart:io';

import 'package:flutter/material.dart';
import 'package:employ_management/database/employee_database.dart';  // Import the database helper
import 'package:employ_management/models/employee.dart';
import 'edit_employee_screen.dart'; // For the Edit screen

class EditEmployeeScreen extends StatefulWidget {
  @override
  _EditEmployeeScreenState createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  TextEditingController searchController = TextEditingController();
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  // Fetch employees from the database
  Future<void> _fetchEmployees() async {
    final dbHelper = DBHelper();
    employees = await dbHelper.getEmployees();
    filteredEmployees = employees;
    setState(() {});
  }

  // Search filter logic
  void _filterEmployees(String query) {
    final filtered = employees.where((emp) {
      return emp.name.toLowerCase().contains(query.toLowerCase()) ||
          emp.empId.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredEmployees = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Employees'),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Employees',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: _filterEmployees,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: employee.imagePath != null
                          ? FileImage(File(employee.imagePath!))
                          : null,
                      child: employee.imagePath == null
                          ? Icon(Icons.person, size: 30)
                          : null,
                    ),
                    title: Text(employee.name),
                    subtitle: Text('Designation: ${employee.designation}'),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Navigate to edit screen and pass the employee data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditEmployeeDetailsScreen(employee: employee),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // Show a dialog to confirm deletion
                            _showDeleteDialog(employee);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to confirm deletion of employee
  void _showDeleteDialog(Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure you want to delete?"),
          content: Text("This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final dbHelper = DBHelper();
                await dbHelper.deleteEmployee(employee.id!); // Delete from DB
                setState(() {
                  employees.remove(employee);
                  filteredEmployees.remove(employee);
                });
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Employee deleted successfully!")),
                );
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
