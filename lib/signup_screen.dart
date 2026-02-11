import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpSent = false;

  void _handleSignUp() async {
    // 1. SEND OTP
    if (!_isOtpSent) {
      if (_formKey.currentState!.validate()) {
        setState(() => _isOtpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('OTP Sent: 1234'), backgroundColor: Colors.green),
        );
      }
      return;
    }

    // 2. VERIFY OTP
    if (_isOtpSent) {
      if (_otpController.text == "1234") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameController.text);
        await prefs.setString('user_email', _emailController.text);
        await prefs.setString('user_pass', _passController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Success! Please Login.'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid OTP!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Create Account"),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  enabled: !_isOtpSent,
                  decoration: const InputDecoration(
                      labelText: "Full Name", prefixIcon: Icon(Icons.person)),
                  validator: (v) => v!.isEmpty ? "Name Required" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  enabled: !_isOtpSent,
                  decoration: const InputDecoration(
                      labelText: "Email", prefixIcon: Icon(Icons.email)),
                  validator: (v) => !v!.contains('@') ? "Invalid Email" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passController,
                  enabled: !_isOtpSent,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: "Password", prefixIcon: Icon(Icons.lock)),
                  validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
                ),
                const SizedBox(height: 20),
                if (_isOtpSent)
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Enter OTP (1234)",
                        prefixIcon: Icon(Icons.sms),
                        fillColor: Colors.yellowAccent,
                        filled: true),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isOtpSent ? Colors.green : Colors.redAccent,
                        foregroundColor: Colors.white),
                    onPressed: _handleSignUp,
                    child: Text(_isOtpSent ? "VERIFY & REGISTER" : "GET OTP"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
