import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';

class FaithfulUpdateScreen extends StatefulWidget {
  final String name;

  const FaithfulUpdateScreen({super.key, required this.name});

  @override
  State<FaithfulUpdateScreen> createState() => _FaithfulUpdateScreenState();
}

class _FaithfulUpdateScreenState extends State<FaithfulUpdateScreen> {
  int _currentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  final Map<String, dynamic> _formData = {};
  bool _isSubmitting = false;
  bool _isLoading = true;
  Map<String, dynamic>? _faithfulData;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _physicalAddressController = TextEditingController();
  final _specialNeedsController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;

  String? _mosque;
  DateTime? _dateOfJoin;
  final _gpsCoordinatesController = TextEditingController();

  String? _household;
  String? _maritalStatus;
  final _spouseNameController = TextEditingController();
  final _numberOfDependantsController = TextEditingController();
  final _ageOfDependantsController = TextEditingController();

  String? _educationLevel;
  String? _occupation;
  final _occupationOtherController = TextEditingController();
  String? _monthlyHouseholdIncome;
  File? _specialNeedsProof;
  File? _profileImage;
  File? _nationalIdDocument;
  String? _profileImageUrl;
  String? _nationalIdDocumentUrl;
  String? _specialNeedsProofUrl;

  final List<String> _incomeOptions = [
    r'<$500',
    r'$500-$1000',
    r'$1100-$100000',
    r'$10000000+',
  ];

  @override
  void initState() {
    super.initState();
    _fetchFaithfulData();
  }

  Future<void> _fetchFaithfulData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final data = await apiService.searchFaithfulById(name: widget.name);
      print('Fetched Faithful Data: $data');
      setState(() {
        _faithfulData = data;
        _fullNameController.text = data['full_name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _placeOfBirthController.text = data['place_of_birth'] ?? '';
        _nationalIdController.text = data['national_id_number'] ?? '';
        _physicalAddressController.text = data['physical_address'] ?? '';
        _specialNeedsController.text = data['special_needs_details'] ?? '';
        print('Prefilled: place_of_birth=${_placeOfBirthController.text}, '
            'national_id=${_nationalIdController.text}, '
            'physical_address=${_physicalAddressController.text}, '
            'special_needs=${_specialNeedsController.text}');
        if (data['date_of_birth'] != null) {
          try {
            _dateOfBirth = DateFormat('yyyy-MM-dd').parse(data['date_of_birth']);
          } catch (e) {
            print('Error parsing date_of_birth: $e');
          }
        }
        _gender = data['gender'];

        _mosque = data['mosque'];
        if (data['date_joined_community'] != null) {
          try {
            _dateOfJoin = DateFormat('yyyy-MM-dd').parse(data['date_joined_community']);
          } catch (e) {
            print('Error parsing date_joined_community: $e');
          }
        }
        _gpsCoordinatesController.text = data['gps_coordinates'] ?? '';

        _household = data['household'];
        _maritalStatus = data['marital_status'];
        _spouseNameController.text = data['spouse_name'] ?? '';
        _numberOfDependantsController.text = data['number_of_dependants']?.toString() ?? '';
        _ageOfDependantsController.text = data['age_of_dependants'] ?? '';

        _educationLevel = data['education_level'];
        _occupation = data['occupation'] != null &&
                !['Student', 'Farmer', 'Teacher', 'Trader', 'Driver', 'Unemployed'].contains(data['occupation'])
            ? 'Other'
            : data['occupation'];
        _occupationOtherController.text = _occupation == 'Other' ? data['occupation'] ?? '' : '';
        _monthlyHouseholdIncome = data['monthly_household_income'];
        _profileImageUrl = data['profile_image'];
        _nationalIdDocumentUrl = data['national_id_document'];
        _specialNeedsProofUrl = data['special_needs_proof'];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error fetching data: $e',
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

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
    _specialNeedsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirth) async {
    final now = DateTime.now();
    final initialDate = isBirth
        ? _dateOfBirth ?? now.subtract(const Duration(days: 365 * 18))
        : _dateOfJoin ?? now;
    final firstDate = isBirth ? DateTime(1900) : DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now,
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

  Future<void> _pickFile(BuildContext context, String field) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      final maxSize = 5 * 1024 * 1024; // 5MB
      if (file.lengthSync() > maxSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$field file size exceeds 5MB limit',
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      setState(() {
        if (field == 'Profile Image') {
          _profileImage = file;
          _profileImageUrl = null; // Clear URL since local file is selected
        } else if (field == 'National ID Document') {
          _nationalIdDocument = file;
          _nationalIdDocumentUrl = null;
        } else if (field == 'Special Needs Proof') {
          _specialNeedsProof = file;
          _specialNeedsProofUrl = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$field selected',
            style: const TextStyle(fontFamily: 'Amiri'),
          ),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  void _removeFile(String field) {
    setState(() {
      if (field == 'Profile Image') {
        _profileImage = null;
        _profileImageUrl = null;
      } else if (field == 'National ID Document') {
        _nationalIdDocument = null;
        _nationalIdDocumentUrl = null;
      } else if (field == 'Special Needs Proof') {
        _specialNeedsProof = null;
        _specialNeedsProofUrl = null;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$field removed',
          style: const TextStyle(fontFamily: 'Amiri'),
        ),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  void _saveStepData(int step) {
    switch (step) {
      case 0: // Personal Information
        _formData['full_name'] = _fullNameController.text;
        _formData['email'] = _emailController.text;
        _formData['phone'] = _phoneController.text;
        _formData['date_of_birth'] = _dateOfBirth != null
            ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
            : null;
        _formData['gender'] = _gender;
        _formData['place_of_birth'] = _placeOfBirthController.text;
        _formData['national_id_number'] = _nationalIdController.text;
        _formData['physical_address'] = _physicalAddressController.text;
        _formData['profile_image'] = _profileImage;
        _formData['national_id_document'] = _nationalIdDocument;
        break;
      case 1: // Community Information
        _formData['mosque'] = _mosque;
        _formData['date_joined_community'] = _dateOfJoin != null
            ? DateFormat('yyyy-MM-dd').format(_dateOfJoin!)
            : null;
        _formData['gps_coordinates'] = _gpsCoordinatesController.text;
        break;
      case 2: // Family Information
        _formData['household'] = _household;
        _formData['marital_status'] = _maritalStatus;
        _formData['spouse_name'] = _spouseNameController.text;
        _formData['number_of_dependants'] = _numberOfDependantsController.text;
        _formData['age_of_dependants'] = _ageOfDependantsController.text;
        break;
      case 3: // Socio-Economic Information
        _formData['education_level'] = _educationLevel;
        _formData['occupation'] = _occupation == 'Other' ? _occupationOtherController.text : _occupation;
        _formData['monthly_household_income'] = _monthlyHouseholdIncome;
        _formData['special_needs'] = _specialNeedsController.text;
        _formData['special_needs_proof'] = _specialNeedsProof;
        break;
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final ageOfDependants = _formData['age_of_dependants'] as String?;
      if (ageOfDependants != null && ageOfDependants.isNotEmpty) {
        final ages = ageOfDependants.split(',').map((e) => e.trim()).toList();
        if (ages.any((age) => !RegExp(r'^\d+$').hasMatch(age))) {
          throw Exception('Ages of dependants must be comma-separated numbers (e.g., 6,36)');
        }
      }

      final gpsCoordinates = _formData['gps_coordinates'] as String?;
      if (gpsCoordinates != null && gpsCoordinates.isNotEmpty) {
        final coords = gpsCoordinates.split(',').map((e) => e.trim()).toList();
        if (coords.length != 2 ||
            !RegExp(r'^-?\d+\.\d+$').hasMatch(coords[0]) ||
            !RegExp(r'^-?\d+\.\d+$').hasMatch(coords[1])) {
          throw Exception('GPS coordinates must be in format lat,long (e.g., -1.36578,36.56784)');
        }
      }

      if (_dateOfBirth != null && _dateOfBirth!.isAfter(DateTime.now().subtract(const Duration(days: 365 * 18)))) {
        throw Exception('Date of Birth must be at least 18 years ago');
      }

      final response = await apiService.updateFaithful(
        name: widget.name,
        fullName: _formData['full_name'] ?? '',
        phone: _formData['phone'] ?? '',
        physicalAddress: _formData['physical_address'],
        numberOfDependants: int.tryParse(_formData['number_of_dependants'] ?? '0'),
        email: _formData['email'] ?? '',
        gender: _formData['gender'] ?? '',
        mosque: _formData['mosque'] ?? '',
        household: _formData['household'],
        dateOfBirth: _formData['date_of_birth'],
        placeOfBirth: _formData['place_of_birth'],
        nationalIdNumber: _formData['national_id_number'],
        maritalStatus: _formData['marital_status'],
        spouseName: _formData['spouse_name'],
        ageOfDependants: _formData['age_of_dependants'],
        educationLevel: _formData['education_level'],
        occupation: _formData['occupation'],
        dateJoinedCommunity: _formData['date_joined_community'],
        gpsLocation: _formData['gps_coordinates'],
        monthlyHouseholdIncome: _formData['monthly_household_income'],
        specialNeeds: _formData['special_needs'],
        specialNeedsProof: _formData['special_needs_proof'],
        profileImage: _formData['profile_image'],
        nationalIdDocument: _formData['national_id_document'],
      );
      print('Update Form Response: $response');
      if (response['status'] == 'success') {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success', style: TextStyle(fontFamily: 'Amiri')),
              content: Text(
                response['message'] ?? 'Faithful updated successfully!',
                style: const TextStyle(fontFamily: 'Amiri'),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Return to FaithfulDashboardScreen
                    print('Navigated back to FaithfulDashboardScreen');
                  },
                  child: const Text('OK', style: TextStyle(fontFamily: 'Amiri', color: AppColors.accent)),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Update failed');
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Update Faithful',
            style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

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
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Enter a valid ID number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _physicalAddressController,
                        decoration: _inputDecoration('Physical Address'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      _buildFileSection(context, 'Profile Image', _profileImage, _profileImageUrl),
                      const SizedBox(height: 12),
                      _buildFileSection(context, 'National ID Document', _nationalIdDocument, _nationalIdDocumentUrl),
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
                          final validMosque = _mosque != null && mosques.any((m) => m['name'] == _mosque)
                              ? _mosque
                              : null;
                          return DropdownButtonFormField<String>(
                            value: validMosque,
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
                            validator: (value) => _dateOfJoin == null ? 'Date Joined is required' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _gpsCoordinatesController,
                        decoration: _inputDecoration('GPS Coordinates (lat,long)'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          final coords = value.split(',').map((e) => e.trim()).toList();
                          if (coords.length != 2 ||
                              !RegExp(r'^-?\d+\.\d+$').hasMatch(coords[0]) ||
                              !RegExp(r'^-?\d+\.\d+$').hasMatch(coords[1])) {
                            return 'Enter valid coordinates (e.g., -1.36578,36.56784)';
                          }
                          return null;
                        },
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
                          final validHousehold = _household != null && households.any((h) => h['name'] == _household)
                              ? _household
                              : null;
                          return DropdownButtonFormField<String>(
                            value: validHousehold,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ageOfDependantsController,
                        decoration: _inputDecoration('Ages of Dependants (comma-separated)'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          final ages = value.split(',').map((e) => e.trim()).toList();
                          if (ages.any((age) => !RegExp(r'^\d+$').hasMatch(age))) {
                            return 'Enter valid ages (e.g., 6,36)';
                          }
                          return null;
                        },
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
                      DropdownButtonFormField<String>(
                        value: _monthlyHouseholdIncome,
                        decoration: _inputDecoration('Monthly Household Income'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        items: _incomeOptions
                            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                            .toList(),
                        onChanged: (value) => setState(() => _monthlyHouseholdIncome = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _specialNeedsController,
                        decoration: _inputDecoration('Special Needs Details'),
                        style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                        maxLines: 2,
                      ),
                      if (_specialNeedsController.text.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildFileSection(context, 'Special Needs Proof', _specialNeedsProof, _specialNeedsProofUrl),
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

  Widget _buildFileSection(BuildContext context, String field, File? localFile, String? url) {
    final isImage = url != null && RegExp(r'\.(png|jpg|jpeg)$', caseSensitive: false).hasMatch(url);
    final isLocalImage = localFile != null && RegExp(r'\.(png|jpg|jpeg)$', caseSensitive: false).hasMatch(localFile.path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (localFile != null) ...[
          isLocalImage
              ? Image.file(
                  localFile,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'Error loading image',
                    style: TextStyle(fontFamily: 'Amiri', color: Colors.redAccent),
                  ),
                )
              : Text(
                  'Selected: ${localFile.path.split('/').last}',
                  style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                ),
        ] else if (url != null) ...[
          isImage
              ? Image.network(
                  url,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'Error loading image',
                    style: TextStyle(fontFamily: 'Amiri', color: Colors.redAccent),
                  ),
                )
              : Text(
                  'Uploaded: ${url.split('/').last}',
                  style: const TextStyle(fontFamily: 'Amiri', color: Colors.black),
                ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _removeFile(field),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Remove',
                  style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _pickFile(context, field),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Replace',
                  style: TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
                ),
              ),
            ],
          ),
        ] else ...[
          ElevatedButton(
            onPressed: () => _pickFile(context, field),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Upload $field',
              style: const TextStyle(fontFamily: 'Amiri', color: AppColors.primary),
            ),
          ),
        ],
      ],
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