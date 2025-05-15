import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:employ_management/models/employee.dart';
import 'package:employ_management/database/employee_database.dart';

class AddEmployeeScreen extends StatefulWidget {
  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _hobbyController = TextEditingController();
  final _designationController = TextEditingController();
  final _emailController = TextEditingController();
  File? _image;

  final DBHelper dbHelper = DBHelper();

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      print("Form validation passed");

      final newEmployee = Employee(
        name: _nameController.text,
        contactNumber: _contactNumberController.text,
        hobby: _hobbyController.text,
        designation: _designationController.text,
        email: _emailController.text,
        imagePath: _image?.path,
      );

      print("Employee object created: ${newEmployee.toMap()}");

      final result = await dbHelper.insertEmployee(newEmployee);
      print("Insert result: $result"); // -1 means failure

      if (result != -1) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Employee added successfully")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save employee data")));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNumberController.dispose();
    _hobbyController.dispose();
    _designationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Employee")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showImageSourceSelector,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child:
                        _image == null
                            ? Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.white70,
                            )
                            : null,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter name' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _contactNumberController,
                  decoration: InputDecoration(
                    labelText: "Contact Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Enter contact number';
                    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                    return phoneRegex.hasMatch(value)
                        ? null
                        : 'Enter a valid 10-digit number starting with 6-9';
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _hobbyController,
                  decoration: InputDecoration(
                    labelText: "Hobby",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter hobby' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _designationController,
                  decoration: InputDecoration(
                    labelText: "Designation",
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Enter designation' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) =>
                          value!.isEmpty || !value.contains('@')
                              ? 'Enter valid email'
                              : null,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveEmployee,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text("Save Employee"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
