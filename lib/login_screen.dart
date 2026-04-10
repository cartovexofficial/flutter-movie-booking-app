import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helloworld/app_theme.dart';
import 'package:helloworld/home_screen.dart';
import 'package:helloworld/signup_screen.dart';
import 'package:helloworld/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? registeredEmail;
  const LoginScreen({super.key, this.registeredEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailCtrl;
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.registeredEmail ?? '');
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_id');
    final savedPass = prefs.getString('user_pass');

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (savedEmail == null) {
      _showError('No account found. Please register first.');
      return;
    }

    if (_emailCtrl.text == savedEmail && _passCtrl.text == savedPass) {
      Navigator.pushReplacement(
        context,
        CinemaRoute(page: HomeScreen(username: savedEmail)),
      );
    } else {
      _showError('Invalid email or password.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo ────────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.glowShadow,
                        ),
                        child: const Icon(Icons.movie_filter_rounded,
                            size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text('Welcome Back', style: AppTheme.headline(28)),
                      const SizedBox(height: 4),
                      Text('Sign in to continue',
                          style: AppTheme.body(14)),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0, duration: 600.ms),

                const SizedBox(height: 40),

                // ── Glass form card ──────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: AppTheme.glassDecoration(radius: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sign In', style: AppTheme.headline(22)),
                          const SizedBox(height: 6),
                          Text('Your next movie experience awaits',
                              style: AppTheme.body(13)),
                          const SizedBox(height: 28),

                          // Email
                          Text('Email', style: AppTheme.label(13)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: AppTheme.label(15),
                            decoration: AppTheme.cinemaInput(
                              hint: 'you@example.com',
                              icon: Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password
                          Text('Password', style: AppTheme.label(13)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passCtrl,
                            obscureText: _obscurePass,
                            style: AppTheme.label(15),
                            decoration: AppTheme.cinemaInput(
                              hint: 'Your password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: () => setState(
                                    () => _obscurePass = !_obscurePass),
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  CinemaRoute(
                                      page:
                                          const ForgotPasswordScreen())),
                              child: Text('Forgot Password?',
                                  style: AppTheme.body(13,
                                      color: AppTheme.primary)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: DecoratedBox(
                              decoration:
                                  AppTheme.primaryButtonDecoration,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5))
                                    : Text('Sign In',
                                        style: AppTheme.label(16,
                                            color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(
                        begin: 0.15,
                        end: 0,
                        delay: 200.ms,
                        duration: 600.ms),

                const SizedBox(height: 24),

                // Sign up link
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(context,
                        CinemaRoute(page: const SignupScreen())),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: AppTheme.body(14),
                        children: [
                          TextSpan(
                            text: 'Register',
                            style: AppTheme.label(14,
                                color: AppTheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
