import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  String? _errorMessage;

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
                    'Enter OTP',
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
                  child: FormBuilderTextField(
                    name: 'otp',
                    decoration: InputDecoration(
                      labelText: 'OTP Code',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: AppColors.background.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
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
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator(color: AppColors.accent)
                    : Column(
                        children: [
                          ElevatedButton(
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
                                  final response = await apiService.verifyOtp(
                                    email: widget.email,
                                    otp: formData['otp'],
                                  );
                                  if (response['status'] == 'success') {
                                    if (mounted) {
                                      context.go('/home');
                                    }
                                  } else {
                                    setState(() {
                                      _errorMessage = response['message'] ?? 'OTP verification failed';
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
                              'Verify OTP',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                              });
                              try {
                                final apiService = Provider.of<ApiService>(context, listen: false);
                                final response = await apiService.sendOtp(email: widget.email);
                                if (response['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('OTP resent successfully')),
                                  );
                                } else {
                                  setState(() {
                                    _errorMessage = response['message'] ?? 'Failed to resend OTP';
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
                            },
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 16,
                                color: AppColors.accent,
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
    );
  }
}