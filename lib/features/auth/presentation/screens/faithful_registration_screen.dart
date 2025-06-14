import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salam/core/constants/app_colors.dart';
import 'package:salam/core/services/api_service.dart';

class FaithfulRegistrationScreen extends StatefulWidget {
  const FaithfulRegistrationScreen({super.key});

  @override
  State<FaithfulRegistrationScreen> createState() => _FaithfulRegistrationScreenState();
}

class _FaithfulRegistrationScreenState extends State<FaithfulRegistrationScreen> {
  int _currentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  final Map<String, dynamic> _formData = {};
  bool _isSubmitting = false;

  // Controllers for each section
  // Personal Information
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _physicalAddressController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;

  // Community Information
  String? _mosque;
  DateTime? _dateOfJoin;
  final _gpsCoordinatesController = TextEditingController();

  // Family Information
  String? _household;
  String? _maritalStatus;
  final _spouseNameController = TextEditingController();
  final _numberOfDependantsController = TextEditingController();
  final _ageOfDependantsController = TextEditingController();

  // Socio-Economic Information
  String? _educationLevel;
  String? _occupation;
  final _occupationOtherController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  String? _specialNeeds;
  final _specialNeedsProofController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _placeOfBirthController.dispose();
    _nationalIdController.dispose();
    _physicalAddressController.dispose();
    _gpsCoordinatesController.dispose();
    _spouseNameController.dispose();
    _numberOfDependantsController.dispose();
    _ageOfDependantsController.dispose();
    _occupationOtherController.dispose();
    _monthlyIncomeController.dispose();
    _specialNeedsProofController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirth) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isBirth
          ? DateTime.now().subtract(const Duration(days: 365 * 18))
          : DateTime.now(),
      firstDate: isBirth ? DateTime(1900) : DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isBirth) {
          _dateOfBirth = picked;
        } else {
          _dateOfJoin = picked;
        }
      });
    }
  }

  void _saveStepData(int step) {
    switch (step) {
      case 0: // Personal
        _formData['full_name'] = _fullNameController.text;
        _formData['email'] = _emailController.text;
        _formData['phone'] = _phoneController.text;
        _formData['date_of_birth'] = _dateOfBirth != null
            ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
            : '';
        _formData['gender'] = _gender ?? '';
        _formData['place_of_birth'] = _placeOfBirthController.text;
        _formData['national_id_number'] = _nationalIdController.text;
        _formData['physical_address'] = _physicalAddressController.text;
        break;
      case 1: // Community
        _formData['mosque'] = _mosque ?? '';
        _formData['date_joined_community'] = _dateOfJoin != null
            ? DateFormat('yyyy-MM-dd').format(_dateOfJoin!)
            : '';
        _formData['gps_location'] = _gpsCoordinatesController.text;
        break;
      case 2: // Family
        _formData['household'] = _household ?? '';
        _formData['marital_status'] = _maritalStatus ?? '';
        _formData['spouse_name'] = _spouseNameController.text;
        _formData['number_of_dependants'] = _numberOfDependantsController.text;
        _formData['age_of_dependants'] = _ageOfDependantsController.text;
        break;
      case 3: // Socio-Economic
        _formData['education_level'] = _educationLevel ?? '';
        _formData['occupation'] = _occupation == 'Other' ? _occupationOtherController.text : _occupation ?? '';
        _formData['monthly_income'] = _monthlyIncomeController.text;
        _formData['special_needs'] = _specialNeeds ?? '';
        _formData['special_needs_proof'] = _specialNeedsProofController.text;
        break;
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final response = await apiService.registerFaithful(
        fullName: _formData['full_name'] ?? '',
        phone: _formData['phone'] ?? '',
        physicalAddress: _formData['physical_address'] ?? '',
        numberOfDependants: int.tryParse(_formData['number_of_dependants'] ?? '0') ?? 0,
        email: _formData['email'] ?? '',
        gender: _formData['gender'] ?? '',
        mosque: _formData['mosque'] ?? '',
        household: _formData['household'] ?? '',
        dateOfBirth: _formData['date_of_birth'] ?? '',
        placeOfBirth: _formData['place_of_birth'] ?? '',
        nationalIdNumber: _formData['national_id_number'] ?? '',
        maritalStatus: _formData['marital_status'] ?? '',
        spouseName: _formData['spouse_name'] ?? '',
        ageOfDependants: _formData['age_of_dependants'] ?? '',
        educationLevel: _formData['education_level'] ?? '',
        occupation: _formData['occupation'] ?? '',
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Faithful registered successfully!',
              style: TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: AppColors.accent,
          ),
        );
        Navigator.pop(context); // Return to previous screen
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: const TextStyle(fontFamily: 'Amiri'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register Faithful',
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
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep == 0) {
                if (_formKeys[_currentStep].currentState!.validate()) {
                  _saveStepData(_currentStep);
                  setState(() => _currentStep += 1);
                }
              } else if (_currentStep < 3) {
                if (_formKeys[_currentStep].currentState!.validate()) {
                  _saveStepData(_currentStep);
                  setState(() => _currentStep += 1);
                }
              } else {
                if (_formKeys[_currentStep].currentState!.validate()) {
                  _saveStepData(_currentStep);
                  _submitForm();
                }
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text(
                          'Previous',
                          style: TextStyle(fontFamily: 'Amiri', color: AppColors.accent),
                        ),
                      ),
                    if (_currentStep < 3) ...[
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: () {
                            _saveStepData(_currentStep);
                            setState(() => _currentStep += 1);
                          },
                          child: const Text(
                            'Skip',
                            style: TextStyle(fontFamily: 'Amiri', color: AppColors.accent),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                        ),
                      ),
                    ] else
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: AppColors.primary)
                            : const Text(
                                'Submit',
                                style: TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                              ),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text(
                  'Personal Information',
                  style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
                ),
                content: Form(
                  key: _formKeys[0],
                  child: Column(
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
                      GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: _inputDecoration('Date of Birth').copyWith(
                              suffixIcon: const Icon(Icons.calendar_today, color: AppColors.accent),
                            ),
                            style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                            controller: TextEditingController(
                              text: _dateOfBirth != null
                                  ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
                                  : '',
                            ),
                          ),
                        ),
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
                      TextFormField(
                        controller: _placeOfBirthController,
                        decoration: _inputDecoration('Place of Birth'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nationalIdController,
                        decoration: _inputDecoration('National ID/Passport'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _physicalAddressController,
                        decoration: _inputDecoration('Physical Address'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text(
                  'Community Information',
                  style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
                ),
                content: Form(
                  key: _formKeys[1],
                  child: Column(
                    children: [
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
                        onTap: () => _selectDate(context, false),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: _inputDecoration('Date Joined Community').copyWith(
                              suffixIcon: const Icon(Icons.calendar_today, color: AppColors.accent),
                            ),
                            style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                            controller: TextEditingController(
                              text: _dateOfJoin != null
                                  ? DateFormat('yyyy-MM-dd').format(_dateOfJoin!)
                                  : '',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _gpsCoordinatesController,
                        decoration: _inputDecoration('GPS Coordinates'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text(
                  'Family Information',
                  style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
                ),
                content: Form(
                  key: _formKeys[2],
                  child: Column(
                    children: [
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: Provider.of<ApiService>(context).getAllHouseholds(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(color: AppColors.accent);
                          }
                          final households = snapshot.data ?? [];
                          return DropdownButtonFormField<String>(
                            value: _household,
                            decoration: _inputDecoration('Household'),
                            style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                            items: households
                                .map((h) => DropdownMenuItem<String>(
                                      value: h['name'] as String,
                                      child: Text(h['household_name'] as String? ?? h['name'] as String),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(() => _household = value),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _maritalStatus,
                        decoration: _inputDecoration('Marital Status'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        items: ['Single', 'Married', 'Divorced', 'Widowed']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (value) => setState(() => _maritalStatus = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _spouseNameController,
                        decoration: _inputDecoration('Spouse Name'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _numberOfDependantsController,
                        decoration: _inputDecoration('Number of Dependants'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ageOfDependantsController,
                        decoration: _inputDecoration('Ages of Dependants (comma-separated)'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text(
                  'Socio-Economic Information',
                  style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
                ),
                content: Form(
                  key: _formKeys[3],
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _educationLevel,
                        decoration: _inputDecoration('Education Level'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        items: [
                          'No Formal',
                          'Quranic',
                          'Primary',
                          'Secondary',
                          'Tertiary'
                        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (value) => setState(() => _educationLevel = value),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _occupation,
                        decoration: _inputDecoration('Occupation'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        items: [
                          'Student',
                          'Farmer',
                          'Teacher',
                          'Trader',
                          'Driver',
                          'Unemployed',
                          'Other'
                        ].map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                        onChanged: (value) => setState(() => _occupation = value),
                      ),
                      if (_occupation == 'Other') ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _occupationOtherController,
                          decoration: _inputDecoration('Specify Occupation'),
                          style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _monthlyIncomeController,
                        decoration: _inputDecoration('Monthly Household Income'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _specialNeeds,
                        decoration: _inputDecoration('Special Needs'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        items: ['Yes', 'No']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (value) => setState(() => _specialNeeds = value),
                      ),
                      if (_specialNeeds == 'Yes') ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _specialNeedsProofController,
                          decoration: _inputDecoration('Special Needs Proof (File Path)'),
                          style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        ),
                      ],
                    ],
                  ),
                ),
                isActive: _currentStep >= 3,
                state: _currentStep >= 3 ? StepState.complete : StepState.indexed,
              ),
            ],
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
