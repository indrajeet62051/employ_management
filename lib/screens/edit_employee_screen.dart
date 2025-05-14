import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:employ_management/database/employee_database.dart';
import 'package:employ_management/models/employee.dart';

class EditEmployeeDetailsScreen extends StatefulWidget {
  final Employee employee;

  EditEmployeeDetailsScreen({required this.employee});

  @override
  _EditEmployeeDetailsScreenState createState() =>
      _EditEmployeeDetailsScreenState();
}

class _EditEmployeeDetailsScreenState extends State<EditEmployeeDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController hobbyController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.employee.name;
    contactController.text = widget.employee.empId; // Using empId as contact
    hobbyController.text = widget.employee.department; // Using department as hobby
    designationController.text = widget.employee.designation;
    emailController.text = widget.employee.email;
    _imageFile = widget.employee.imagePath != null
        ? File(widget.employee.imagePath!)
        : null;
  }

  Future<void> pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void updateEmployee() async {
    if (_formKey.currentState!.validate()) {
      final updatedEmployee = Employee(
        id: widget.employee.id,
        name: nameController.text,
        empId: contactController.text,
        department: hobbyController.text,
        designation: designationController.text,
        email: emailController.text,
        imagePath: _imageFile?.path ?? widget.employee.imagePath,
      );

      final dbHelper = DBHelper();
      await dbHelper.updateEmployee(updatedEmployee);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Employee details updated successfully!")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Employee"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : widget.employee.imagePath != null
                      ? FileImage(File(widget.employee.imagePath!))
                      : null,
                  child: _imageFile == null && widget.employee.imagePath == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                      : null,
                ),
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Employee Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Enter employee name' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter contact number';
                  // Regex: first digit 6-9, followed by exactly 9 more digits
                  final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                  return phoneRegex.hasMatch(value)
                      ? null
                      : 'Enter a valid 10-digit number starting with 6-9';
                },
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: hobbyController,
                decoration: InputDecoration(
                  labelText: 'Hobby',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter hobby' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: designationController,
                decoration: InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Enter designation' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter email';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) return 'Enter valid email';
                  return null;
                },
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: updateEmployee,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                ),
                child: Text("Update Employee"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
