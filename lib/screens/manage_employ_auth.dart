import 'package:flutter/material.dart';
import 'employ_operations.dart';

class ManageEmployAuth extends StatefulWidget {
  @override
  _ManageEmployAuthState createState() => _ManageEmployAuthState();
}

class _ManageEmployAuthState extends State<ManageEmployAuth> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final String _correctPin = '1234'; // Default PIN

  // Function to verify the entered PIN
  void verifyPin() {
    if (_pinController.text == _correctPin) {
      // If PIN is correct, redirect to the employee operations screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EmployeeOperationsScreen()),
      );
    } else {
      // Show error if PIN is incorrect
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Invalid PIN"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Operations Authentication"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PIN input field
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true, // Mask the PIN for security
                decoration: InputDecoration(
                  labelText: "Enter 4-Digit PIN",
                  border: OutlineInputBorder(),
                  counterText: '', // Hide the counter
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your PIN';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Verify Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    verifyPin(); // Verify the entered PIN
                  }
                },
                child: Text("Verify"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


