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
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController hobbyController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.employee.name;
    contactNumberController.text = widget.employee.contactNumber;
    hobbyController.text = widget.employee.hobby;
    designationController.text = widget.employee.designation;
    emailController.text = widget.employee.email;

    _imageFile =
        widget.employee.imagePath != null
            ? File(widget.employee.imagePath!)
            : null;
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
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
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void updateEmployee() async {
    if (_formKey.currentState!.validate()) {
      final updatedEmployee = Employee(
        id: widget.employee.id,
        name: nameController.text,
        contactNumber: contactNumberController.text,
        hobby: hobbyController.text,
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
                onTap: _showImageSourceSelector,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _imageFile != null
                          ? FileImage(_imageFile!)
                          : widget.employee.imagePath != null
                          ? FileImage(File(widget.employee.imagePath!))
                          : null,
                  child:
                      _imageFile == null &&
                              (widget.employee.imagePath == null ||
                                  widget.employee.imagePath!.isEmpty)
                          ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white70,
                          )
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
                validator:
                    (value) => value!.isEmpty ? 'Enter employee name' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: contactNumberController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
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
                validator:
                    (value) => value!.isEmpty ? 'Enter designation' : null,
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
