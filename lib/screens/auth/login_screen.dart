// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/auth_gate.dart';
import 'create_account_screen.dart';

/// Login screen — wired to REAL Firebase Auth through [AuthProvider].
///
/// Why we navigate to [AuthGate] on success:
///   The onboarding / create-account screens use `pushReplacementNamed`,
///   which removes AuthGate from the navigator stack. So relying on a
///   still-mounted AuthGate to auto-route after login is unreliable.
///   Instead, on success we rebuild AuthGate fresh at the root of the
///   stack: it sees the now-signed-in user and shows Home. The same
///   mechanism makes logout reliable (AuthGate sees no user → Login).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (!ok) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login failed'),
          content: Text(
            auth.errorMessage ??
                'Incorrect email or password. Please try again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                auth.clearError();
                Navigator.pop(ctx);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Success → rebuild AuthGate at the root. It will see the signed-in
    // user and route to Home.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AuthGate.routeName,
      (route) => false,
    );
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Forgot password'),
          content: const Text(
            'Enter your email in the field above first, then tap '
            '"Forgot password?" again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.sendPasswordResetEmail(email);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ok ? 'Email sent' : 'Could not send email'),
        content: Text(
          ok
              ? 'A password reset link has been sent to $email.'
              : (auth.errorMessage ?? 'Please try again later.'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              auth.clearError();
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Colors.black),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Color(0xFF7C7C7C),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    // Explicit black input text — fixes the pink text (it was inheriting
    // a themed color).
    const inputTextStyle = TextStyle(fontSize: 13, color: Colors.black);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 290,
            height: 590,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '9:41',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Icon(Icons.more_horiz, size: 18, color: Colors.black),
                      ],
                    ),
                    const SizedBox(height: 110),
                    const Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign in to continue.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                    const SizedBox(height: 34),
                    _buildLabel('EMAIL'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: inputTextStyle,
                      decoration: _inputDecoration(
                        hintText: 'you@university.edu',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email.';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('PASSWORD'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: inputTextStyle,
                      decoration: _inputDecoration(hintText: '••••••••'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your password.';
                        }
                        if (value.trim().length < 6) {
                          return 'Password must be at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: isLoading ? null : _handleForgotPassword,
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'log in',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'New here? ',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF8A8A8A),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              CreateAccountScreen.routeName,
                            );
                          },
                          child: const Text(
                            'Create account',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
