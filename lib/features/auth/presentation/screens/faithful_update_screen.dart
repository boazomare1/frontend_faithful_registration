import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';

class FaithfulUpdateScreen extends StatefulWidget {
  final Map<String, dynamic> faithful;

  const FaithfulUpdateScreen({super.key, required this.faithful});

  @override
  State<FaithfulUpdateScreen> createState() => _FaithfulUpdateScreenState();
}

class _FaithfulUpdateScreenState extends State<FaithfulUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _gender;
  String? _mosque;
  DateTime? _dateOfBirth;
  File? _profileImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.faithful['full_name'] ?? '');
    _emailController = TextEditingController(text: widget.faithful['email'] ?? '');
    _phoneController = TextEditingController(text: widget.faithful['phone'] ?? '');
    _gender = widget.faithful['gender'];
    _mosque = widget.faithful['mosque'];
    if (widget.faithful['date_of_birth'] != null) {
      try {
        _dateOfBirth = DateFormat('yyyy-MM-dd').parse(widget.faithful['date_of_birth']);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      final maxSize = 5 * 1024 * 1024; // 5MB
      if (file.lengthSync() > maxSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Profile image size exceeds 5MB limit',
              style: TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      setState(() => _profileImage = file);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile image selected',
            style: TextStyle(fontFamily: 'Amiri'),
          ),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final response = await apiService.updateFaithful(
        name: widget.faithful['name'],
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        gender: _gender ?? '',
        mosque: _mosque ?? '',
        dateOfBirth: _dateOfBirth != null ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!) : null,
        profileImage: _profileImage,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'],
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: response['status'] == 'success' ? AppColors.accent : Colors.redAccent,
          ),
        );
        if (response['status'] == 'success') {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Faithful',
          style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: _inputDecoration('Full Name *'),
                      style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                      validator: (value) => value!.isEmpty ? 'Full Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration('Email *'),
                      style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _inputDecoration('Phone *'),
                      style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) return 'Phone is required';
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _inputDecoration('Gender *'),
                      style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                      items: ['Male', 'Female']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (value) => setState(() => _gender = value),
                      validator: (value) => value == null ? 'Gender is required' : null,
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: Provider.of<ApiService>(context).getAllMosques(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(color: AppColors.accent);
                        }
                        final mosques = snapshot.data ?? [];
                        return DropdownButtonFormField<String>(
                          value: _mosque,
                          decoration: _inputDecoration('Mosque *'),
                          style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                          items: mosques
                              .map((m) => DropdownMenuItem<String>(
                                    value: m['name'] as String,
                                    child: Text(m['mosque_name'] as String? ?? m['name'] as String),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _mosque = value),
                          validator: (value) => value == null ? 'Mosque is required' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: _inputDecoration('Date of Birth *').copyWith(
                            suffixIcon: const Icon(Icons.calendar_today, color: AppColors.accent),
                          ),
                          style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                          controller: TextEditingController(
                            text: _dateOfBirth != null
                                ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
                                : '',
                          ),
                          validator: (value) => _dateOfBirth == null ? 'Date of Birth is required' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _pickFile(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Upload Profile Image',
                        style: TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: AppColors.primary)
                          : const Text(
                              'Update',
                              style: TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                            ),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Amiri', color: Colors.white70),
      filled: true,
      fillColor: AppColors.background.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}