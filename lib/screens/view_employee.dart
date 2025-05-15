import 'dart:io';

import 'package:flutter/material.dart';
import 'package:employ_management/database/employee_database.dart'; // Import the database helper
import 'package:employ_management/models/employee.dart'; // Database helper class

class ViewEmployeeScreen extends StatefulWidget {
  @override
  _ViewEmployeeScreenState createState() => _ViewEmployeeScreenState();
}

class _ViewEmployeeScreenState extends State<ViewEmployeeScreen> {
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _searchController.addListener(_filterList);
  }

  Future<void> _loadEmployees() async {
    final employees = await DBHelper().getEmployees();
    setState(() {
      _allEmployees = employees;
      _filteredEmployees = employees;
    });
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees =
          _allEmployees.where((emp) {
            return emp.name.toLowerCase().contains(query) ||
                emp.id.toString().toLowerCase().contains(query) ||
                emp.hobby.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employees"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Curved Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, ID, or hobby',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Employee List
            Expanded(
              child:
                  _filteredEmployees.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox, size: 80, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("No matching employees found"),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final emp = _filteredEmployees[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.blue[100],
                                    backgroundImage:
                                        emp.imagePath != null
                                            ? FileImage(File(emp.imagePath!))
                                            : null,
                                    child:
                                        emp.imagePath == null
                                            ? Text(
                                              emp.name[0].toUpperCase(),
                                              style: TextStyle(fontSize: 24),
                                            )
                                            : null,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          emp.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text("ID: ${emp.id}"),
                                        Text("Contact: ${emp.contactNumber}"),
                                        Text("Email: ${emp.email}"),
                                        Text("Designation: ${emp.designation}"),
                                        Text("Hobby: ${emp.hobby}"),
                                      ],
                                    ),
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
      ),
    );
  }
}
