import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helloworld/home_screen.dart';
import 'package:helloworld/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? registeredEmail;
  const LoginScreen({super.key, this.registeredEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _loginEmailController;
  final _loginPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loginEmailController =
        TextEditingController(text: widget.registeredEmail ?? "");
  }

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('user_id'); // Must match Signup key
    String? savedPass = prefs.getString('user_pass'); // Must match Signup key

    if (savedEmail == null) {
      _showError("No user found. Please register.");
      return;
    }

    if (_loginEmailController.text == savedEmail &&
        _loginPassController.text == savedPass) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(username: savedEmail)),
      );
    } else {
      _showError("Invalid Email or Password");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_open, size: 80, color: Colors.redAccent),
            const Text("Login",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
                controller: _loginEmailController,
                decoration: const InputDecoration(
                    labelText: "Email ID", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(
                controller: _loginPassController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Password", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: _login,
                child:
                    const Text("Login", style: TextStyle(color: Colors.white)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SignupScreen())),
              child: const Text("Back to Register"),
            )
          ],
        ),
      ),
    );
  }
}
