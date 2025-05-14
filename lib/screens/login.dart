import 'package:flutter/material.dart';
import 'dashboardscreen.dart';

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      // This allows the body to extend behind the app bar
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Center(child: Text("Admin Login")),
        backgroundColor: Colors.blue.withOpacity(0.8),
        // Semi-transparent app bar
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/loginBGimage.png"), // Full path
            fit: BoxFit.cover, // Cover the entire screen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 350),
                // Adjust the height to move the form down
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Enter your Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => validateEmail(value ?? ''),
                ),
                SizedBox(height: 50),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) => validatePassword(value ?? ''),
                ),
                SizedBox(height: 30),
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


