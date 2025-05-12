import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'package:vet_assist/services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Google. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF00838F);
    final textColor = Colors.white;
    final borderColor = Colors.grey[400];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Title
                Center(
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 30),

                // Divider with "Continue With" text
                Row(
                  children: [
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey[400]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Continue With',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Social Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Button
                    IconButton(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: SvgPicture.asset(
                        'assest/icons/google.svg',
                        height: 55,
                        colorFilter: ColorFilter.mode(
                          primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Facebook Button (currently not implemented)
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assest/icons/fb.svg',
                        height: 52,
                        colorFilter: ColorFilter.mode(
                          primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Login Prompt
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: const Color(0xFF00838F),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(context, '/login');
                                },
                        ),
                      ],
                    ),
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
