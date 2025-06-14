import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();
  bool _obscurePassword = true;

  void _showForgotPasswordDialog() {
    final forgotPasswordFormKey = GlobalKey<FormBuilderState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Forgot Password',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 20),
        ),
        content: FormBuilder(
          key: forgotPasswordFormKey,
          child: FormBuilderTextField(
            name: 'email',
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontFamily: 'Amiri'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Amiri', color: AppColors.accent),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (forgotPasswordFormKey.currentState!.validate()) {
                forgotPasswordFormKey.currentState!.save();
                final email = forgotPasswordFormKey.currentState!.value['email'];
                final apiService = Provider.of<ApiService>(context, listen: false);
                final response = await apiService.forgotPassword(email: email);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      response['message'],
                      style: const TextStyle(fontFamily: 'Amiri'),
                    ),
                    backgroundColor: response['status'] == 'success'
                        ? AppColors.accent
                        : Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Send Reset Link',
              style: TextStyle(fontFamily: 'Amiri', color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Welcome to Salam',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'email',
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: AppColors.background.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'password',
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: AppColors.background.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontFamily: 'Amiri'),
                    ),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator(color: AppColors.accent)
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final formData = _formKey.currentState!.value;
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            try {
                              final apiService = Provider.of<ApiService>(context, listen: false);
                              final response = await apiService.loginUser(
                                email: formData['email'],
                                password: formData['password'],
                              );
                              print('LoginScreen Response: $response');
                              if (response['status'] == 'success') {
                                await _storage.write(key: 'sid', value: response['sid']);
                                await _storage.write(key: 'user', value: response['user']);
                                await _storage.write(key: 'full_name', value: response['full_name']);
                                await apiService.sendOtp(email: formData['email']);
                                if (mounted) {
                                  context.go('/otp', extra: {'email': formData['email']});
                                }
                              } else {
                                setState(() {
                                  _errorMessage = response['message'] ?? 'Invalid email or password';
                                });
                              }
                            } catch (e) {
                              setState(() {
                                _errorMessage = 'An error occurred: $e';
                              });
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            color: Colors.black,
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