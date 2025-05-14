import 'package:flutter/material.dart';

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final String adminEmail = "admin@company.com";
  final String adminPassword = "admin123";

  void checkLogin() {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email == adminEmail && password == adminPassword) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid email or password"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter your email';
    }
    bool emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
    if (!emailValid) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Admin Login")),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Enter your Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => validateEmail(value ?? ''),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) => validatePassword(value ?? ''),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      checkLogin();
                    }
                  },
                  child: Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          "Welcome to the Dashboard!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
