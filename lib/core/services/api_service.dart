import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'dart:convert';

class ApiService with ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://952b-102-69-233-46.ngrok-free.app/api/method/',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _sid;

  ApiService() {
    _init();
  }

  Future<void> _init() async {
    _sid = await _storage.read(key: 'sid');
    if (_sid != null) {
      _dio.options.headers['Cookie'] = 'sid=$_sid';
      print('Loaded sid: $_sid');
    }
  }

  void setSid(String sid) async {
    _sid = sid;
    _dio.options.headers['Cookie'] = 'sid=$_sid';
    await _storage.write(key: 'sid', value: sid);
    print('Set sid: $sid');
    notifyListeners();
  }

  // **Existing Authentication Methods (unchanged)**
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final requestData = {'email': email, 'password': password};
      print('Login Request URL: ${_dio.options.baseUrl}faithful_registration.api.auth.login_user');
      print('Login Request Headers: ${_dio.options.headers}');
      print('Login Request Body: $requestData');
      final response = await _dio.post(
        'faithful_registration.api.auth.login_user',
        data: requestData,
      );
      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['message']['status'] == 'success' && data['message']['sid'] != null) {
        setSid(data['message']['sid']);
      }
      return data['message'] ?? {'status': 'error', 'message': 'Invalid response'};
    } catch (e) {
      print('Login Error: $e');
      return {'status': 'error', 'message': 'Failed to login: $e'};
    }
  }

  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    try {
      final response = await _dio.post(
        'faithful_registration.api.auth.send_otp',
        data: {'email': email},
      );
      print('Send OTP Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      return data['message'] ?? {'status': 'error', 'message': 'Invalid response'};
    } catch (e) {
      print('Send OTP Error: $e');
      return {'status': 'error', 'message': 'Failed to send OTP: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        'faithful_registration.api.auth.verify_otp',
        data: {'email': email, 'otp': otp},
      );
      print('Verify OTP Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      return data['message'] ?? {'status': 'error', 'message': 'Invalid response'};
    } catch (e) {
      print('Verify OTP Error: $e');
      return {'status': 'error', 'message': 'Failed to verify OTP: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post(
        'faithful_registration.api.auth.forgot_password',
        data: {'email': email},
      );
      print('Forgot Password Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
      };
    } catch (e) {
      print('Forgot Password Error: $e');
      return {'status': 'error', 'message': 'Failed to send reset link: $e'};
    }
  }

  // **Existing List and Count Methods (unchanged)**
  Future<List<Map<String, dynamic>>> getAllMosques() async {
    try {
      final response = await _dio.get('faithful_registration.api.mosque.get_all_mosques');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.isNotEmpty ? data.cast<Map<String, dynamic>>() : [];
      }
      return [];
    } catch (e) {
      print('Get All Mosques Error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllHouseholds() async {
    try {
      final response = await _dio.get('faithful_registration.api.household.get_all_households');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.isNotEmpty ? data.cast<Map<String, dynamic>>() : [];
      }
      return [];
    } catch (e) {
      print('Get All Households Error: $e');
      return [];
    }
  }

  Future<int> getFemaleCount() async {
    try {
      final response = await _dio.get(
        'faithful_registration.api.faithful.get_all_faithfuls',
        queryParameters: {'gender': 'Female'},
      );
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.length;
      }
      return 0;
    } catch (e) {
      print('Get Female Count Error: $e');
      return 0;
    }
  }

  Future<int> getMaleCount() async {
    try {
      final response = await _dio.get(
        'faithful_registration.api.faithful.get_all_faithfuls',
        queryParameters: {'gender': 'Male'},
      );
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.length;
      }
      return 0;
    } catch (e) {
      print('Get Male Count Error: $e');
      return 0;
    }
  }

  Future<int> getWithHouseholdCount() async {
    try {
      final response = await _dio.get('faithful_registration.api.faithful.get_all_faithfuls');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.where((f) => f['household'] != null && (f['household'] as String).isNotEmpty).length;
      }
      return 0;
    } catch (e) {
      print('Get With Household Count Error: $e');
      return 0;
    }
  }

  Future<int> getWithoutHouseholdCount() async {
    try {
      final response = await _dio.get('faithful_registration.api.faithful.get_all_faithfuls');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.where((f) => f['household'] == null || (f['household'] as String).isEmpty).length;
      }
      return 0;
    } catch (e) {
      print('Get Without Household Count Error: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getHouseholdMemberCounts() async {
    try {
      final response = await _dio.get('faithful_registration.api.faithful.get_all_faithfuls');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        final householdMap = <String, Map<String, dynamic>>{};
        for (var f in data) {
          final household = f['household'] as String?;
          if (household != null && household.isNotEmpty) {
            if (!householdMap.containsKey(household)) {
              householdMap[household] = {
                'household_name': f['household_name'] as String? ?? 'Unknown',
                'count': 0,
                'members': <Map<String, dynamic>>[],
              };
            }
            householdMap[household]!['count'] = (householdMap[household]!['count'] as int) + 1;
            householdMap[household]!['members'].add({
              'full_name': f['full_name'] as String? ?? 'N/A',
              'gender': f['gender'] as String? ?? 'N/A',
              'date_of_birth': f['date_of_birth'] as String? ?? 'N/A',
              'occupation': f['occupation'] as String? ?? 'N/A',
            });
          }
        }
        return householdMap.entries
            .map((e) => {
                  'household': e.key,
                  'household_name': e.value['household_name'],
                  'count': e.value['count'],
                  'members': e.value['members'],
                })
            .toList();
      }
      return [];
    } catch (e) {
      print('Get Household Member Counts Error: $e');
      return [];
    }
  }

  Future<int> getMosqueCount() async {
    try {
      final response = await _dio.get('faithful_registration.api.mosque.get_all_mosques');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.length;
      }
      return 0;
    } catch (e) {
      print('Get Mosque Count Error: $e');
      return 0;
    }
  }

  Future<int> getHouseholdCount() async {
    try {
      final response = await _dio.get('faithful_registration.api.household.get_all_households');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.length;
      }
      return 0;
    } catch (e) {
      print('Get Household Count Error: $e');
      return 0;
    }
  }

  Future<int> getFaithfulCount() async {
    try {
      final response = await _dio.get('faithful_registration.api.faithful.get_all_faithfuls');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.length;
      }
      return 0;
    } catch (e) {
      print('Get Faithful Count Error: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>> searchFaithful({required String name}) async {
    try {
      final response = await _dio.get(
        'faithful_registration.api.faithful.get_faithful',
        queryParameters: {'name': name},
      );
      print('Search Faithful Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      return data['message'] ?? {'status': 'error', 'message': 'Faithful not found'};
    } catch (e) {
      print('Search Faithful Error: $e');
      return {'status': 'error', 'message': 'Failed to search faithful: $e'};
    }
  }

  Future<Map<String, dynamic>> registerFaithful({
    required String fullName,
    required String phone,
    String? physicalAddress,
    int? numberOfDependants,
    required String email,
    required String gender,
    required String mosque,
    String? household,
    String? dateOfBirth,
    String? placeOfBirth,
    String? nationalIdNumber,
    String? maritalStatus,
    String? spouseName,
    String? ageOfDependants,
    String? educationLevel,
    String? occupation,
    String? dateJoinedCommunity,
    String? gpsLocation,
    String? monthlyHouseholdIncome,
    String? specialNeeds,
    File? specialNeedsProof,
    File? profileImage,
    File? nationalIdDocument,
  }) async {
    try {
      final requestData = {
        'data': {
          'full_name': fullName,
          'phone': phone,
          if (physicalAddress != null && physicalAddress.isNotEmpty) 'physical_address': physicalAddress,
          if (numberOfDependants != null) 'number_of_dependants': numberOfDependants,
          'email': email,
          'gender': gender,
          'mosque': mosque,
          if (household != null && household.isNotEmpty) 'household': household,
          if (dateOfBirth != null && dateOfBirth.isNotEmpty) 'date_of_birth': dateOfBirth,
          if (placeOfBirth != null && placeOfBirth.isNotEmpty) 'place_of_birth': placeOfBirth,
          if (nationalIdNumber != null && nationalIdNumber.isNotEmpty) 'national_id_number': nationalIdNumber,
          if (maritalStatus != null && maritalStatus.isNotEmpty) 'marital_status': maritalStatus,
          if (spouseName != null && spouseName.isNotEmpty) 'spouse_name': spouseName,
          if (ageOfDependants != null && ageOfDependants.isNotEmpty) 'age_of_dependants': ageOfDependants,
          if (educationLevel != null && educationLevel.isNotEmpty) 'education_level': educationLevel,
          if (occupation != null && occupation.isNotEmpty) 'occupation': occupation,
          if (dateJoinedCommunity != null && dateJoinedCommunity.isNotEmpty) 'date_joined_community': dateJoinedCommunity,
          if (gpsLocation != null && gpsLocation.isNotEmpty) 'gps_coordinates': gpsLocation,
          if (monthlyHouseholdIncome != null && monthlyHouseholdIncome.isNotEmpty)
            'monthly_household_income': _normalizeIncome(monthlyHouseholdIncome),
          if (specialNeeds != null && specialNeeds.isNotEmpty) 'special_needs': specialNeeds,
          if (specialNeedsProof != null)
            'special_needs_proof': _encodeFile(specialNeedsProof, 'Special Needs Proof'),
          if (profileImage != null)
            'profile_image': _encodeFile(profileImage, 'Profile Image'),
          if (nationalIdDocument != null)
            'national_id_document': _encodeFile(nationalIdDocument, 'National ID Document'),
        }
      };
      print('Register Faithful Request: $requestData');
      final response = await _dio.post(
        'faithful_registration.api.faithful.register_faithful',
        data: requestData,
      );
      print('Register Faithful Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['status'] == 'success') {
        return {
          'status': 'success',
          'message': data['message'] ?? 'Faithful registered successfully',
          'data': data['data'] ?? {},
        };
      }
      return {
        'status': 'error',
        'message': data['errors']?['description'] ?? data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('Register Faithful Error: $e');
        print('Server Response: ${e.response?.data}');
        final errorData = e.response?.data as Map<String, dynamic>?;
        return {
          'status': 'error',
          'message': errorData?['errors']?['description'] ?? errorData?['message'] ?? 'Failed to register faithful: ${e.message}',
        };
      }
      print('Register Faithful Error: $e');
      return {'status': 'error', 'message': 'Failed to register faithful: $e'};
    }
  }

  // **New Mosque Operations**
  Future<Map<String, dynamic>> registerMosque({
    required String mosqueName,
    required String location,
    required String dateEstablished,
    required String headImam,
    required int totalCapacity,
    required String contactEmail,
    required String contactPhone,
  }) async {
    try {
      final requestData = {
        'data': {
          'mosque_name': mosqueName,
          'location': location,
          'date_established': dateEstablished,
          'head_imam': headImam,
          'total_capacity': totalCapacity,
          'contact_email': contactEmail,
          'contact_phone': contactPhone,
        }
      };
      final response = await _dio.post(
        'faithful_registration.api.mosque.register_mosque',
        data: requestData,
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Register Mosque Error: $e');
      return {'status': 'error', 'message': 'Failed to register mosque: $e'};
    }
  }

  Future<Map<String, dynamic>> getMosque({required String name}) async {
    try {
      final response = await _dio.get(
        'faithful_registration.api.mosque.get_mosque',
        queryParameters: {'name': name},
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Get Mosque Error: $e');
      return {'status': 'error', 'message': 'Failed to get mosque: $e'};
    }
  }

  Future<Map<String, dynamic>> updateMosque({
    required String name,
    required String mosqueName,
    required String location,
    required String dateEstablished,
    required String headImam,
    required int totalCapacity,
    required String contactEmail,
    required String contactPhone,
  }) async {
    try {
      final requestData = {
        'data': {
          'name': name,
          'mosque_name': mosqueName,
          'location': location,
          'date_established': dateEstablished,
          'head_imam': headImam,
          'total_capacity': totalCapacity,
          'contact_email': contactEmail,
          'contact_phone': contactPhone,
        }
      };
      final response = await _dio.post(
        'faithful_registration.api.mosque.update_mosque',
        data: requestData,
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Update Mosque Error: $e');
      return {'status': 'error', 'message': 'Failed to update mosque: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteMosque({required String name}) async {
    try {
      final response = await _dio.post(
        'faithful_registration.api.mosque.delete_mosque',
        queryParameters: {'name': name},
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
      };
    } catch (e) {
      print('Delete Mosque Error: $e');
      return {'status': 'error', 'message': 'Failed to delete mosque: $e'};
    }
  }

  Future<Map<String, dynamic>> bulkRegisterMosques({required File file}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });
      final response = await _dio.post(
        'faithful_registration.api.mosque.bulk_register_mosques',
        data: formData,
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Bulk Register Mosques Error: $e');
      return {'status': 'error', 'message': 'Failed to bulk register mosques: $e'};
    }
  }

  // **New Household Operations**
  Future<Map<String, dynamic>> createHousehold({
    required String householdName,
    required String headOfHousehold,
    required String addressLine,
    required String mosque,
    required int totalMembers,
  }) async {
    try {
      final requestData = {
        'data': {
          'household_name': householdName,
          'head_of_household': headOfHousehold,
          'address_line': addressLine,
          'mosque': mosque,
          'total_members': totalMembers,
        }
      };
      final response = await _dio.post(
        'faithful_registration.api.household.create_household',
        data: requestData,
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Create Household Error: $e');
      return {'status': 'error', 'message': 'Failed to create household: $e'};
    }
  }

  Future<Map<String, dynamic>> getHousehold({required String name}) async {
    try {
      final response = await _dio.get(
        'faithful_registration.api.household.get_household',
        queryParameters: {'name': name},
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Get Household Error: $e');
      return {'status': 'error', 'message': 'Failed to get household: $e'};
    }
  }

  Future<Map<String, dynamic>> updateHousehold({
    required String name,
    required String householdName,
    required String headOfHousehold,
    required String addressLine,
    required String mosque,
    required int totalMembers,
  }) async {
    try {
      final requestData = {
        'data': {
          'name': name,
          'household_name': householdName,
          'head_of_household': headOfHousehold,
          'address_line': addressLine,
          'mosque': mosque,
          'total_members': totalMembers,
        }
      };
      final response = await _dio.post(
        'faithful_registration.api.household.update_household',
        data: requestData,
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Update Household Error: $e');
      return {'status': 'error', 'message': 'Failed to update household: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteHousehold({required String name}) async {
    try {
      final response = await _dio.post(
        'faithful_registration.api.household.delete_household',
        queryParameters: {'name': name},
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
      };
    } catch (e) {
      print('Delete Household Error: $e');
      return {'status': 'error', 'message': 'Failed to delete household: $e'};
    }
  }

  Future<Map<String, dynamic>> bulkRegisterHouseholds({required File file}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });
      final response = await _dio.post(
        'faithful_registration.api.household.bulk_register_households',
        data: formData,
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Bulk Register Households Error: $e');
      return {'status': 'error', 'message': 'Failed to bulk register households: $e'};
    }
  }

  // **New Faithful Operations**
  Future<List<Map<String, dynamic>>> getAllFaithfuls({
    String? mosque,
    String? gender,
    String? household,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (mosque != null) queryParams['mosque'] = mosque;
      if (gender != null) queryParams['gender'] = gender;
      if (household != null) queryParams['household'] = household;
      final response = await _dio.get(
        'faithful_registration.api.faithful.get_all_faithfuls',
        queryParameters: queryParams,
      );
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.isNotEmpty ? data.cast<Map<String, dynamic>>() : [];
      }
      return [];
    } catch (e) {
      print('Get All Faithfuls Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> updateFaithful({
    required String name,
    required String fullName,
    required String phone,
    String? physicalAddress,
    int? numberOfDependants,
    required String email,
    required String gender,
    required String mosque,
    String? household,
    String? dateOfBirth,
    String? placeOfBirth,
    String? nationalIdNumber,
    String? maritalStatus,
    String? spouseName,
    String? ageOfDependants,
    String? educationLevel,
    String? occupation,
    String? dateJoinedCommunity,
    String? gpsLocation,
    String? monthlyHouseholdIncome,
    String? specialNeeds,
    File? specialNeedsProof,
    File? profileImage,
    File? nationalIdDocument,
  }) async {
    try {
      final requestData = {
        'data': {
          'name': name,
          'full_name': fullName,
          'phone': phone,
          if (physicalAddress != null && physicalAddress.isNotEmpty) 'physical_address': physicalAddress,
          if (numberOfDependants != null) 'number_of_dependants': numberOfDependants,
          'email': email,
          'gender': gender,
          'mosque': mosque,
          if (household != null && household.isNotEmpty) 'household': household,
          if (dateOfBirth != null && dateOfBirth.isNotEmpty) 'date_of_birth': dateOfBirth,
          if (placeOfBirth != null && placeOfBirth.isNotEmpty) 'place_of_birth': placeOfBirth,
          if (nationalIdNumber != null && nationalIdNumber.isNotEmpty) 'national_id_number': nationalIdNumber,
          if (maritalStatus != null && maritalStatus.isNotEmpty) 'marital_status': maritalStatus,
          if (spouseName != null && spouseName.isNotEmpty) 'spouse_name': spouseName,
          if (ageOfDependants != null && ageOfDependants.isNotEmpty) 'age_of_dependants': ageOfDependants,
          if (educationLevel != null && educationLevel.isNotEmpty) 'education_level': educationLevel,
          if (occupation != null && occupation.isNotEmpty) 'occupation': occupation,
          if (dateJoinedCommunity != null && dateJoinedCommunity.isNotEmpty) 'date_joined_community': dateJoinedCommunity,
          if (gpsLocation != null && gpsLocation.isNotEmpty) 'gps_coordinates': gpsLocation,
          if (monthlyHouseholdIncome != null && monthlyHouseholdIncome.isNotEmpty)
            'monthly_household_income': _normalizeIncome(monthlyHouseholdIncome),
          if (specialNeeds != null && specialNeeds.isNotEmpty) 'special_needs': specialNeeds,
          if (specialNeedsProof != null)
            'special_needs_proof': _encodeFile(specialNeedsProof, 'Special Needs Proof'),
          if (profileImage != null)
            'profile_image': _encodeFile(profileImage, 'Profile Image'),
          if (nationalIdDocument != null)
            'national_id_document': _encodeFile(nationalIdDocument, 'National ID Document'),
        }
      };
      final response = await _dio.post(
        'faithful_registration.api.faithful.update_faithful',
        data: requestData,
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Update Faithful Error: $e');
      return {'status': 'error', 'message': 'Failed to update faithful: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteFaithful({required String name}) async {
    try {
      final response = await _dio.post(
        'faithful_registration.api.faithful.delete_faithful',
        queryParameters: {'name': name},
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
      };
    } catch (e) {
      print('Delete Faithful Error: $e');
      return {'status': 'error', 'message': 'Failed to delete faithful: $e'};
    }
  }

  Future<Map<String, dynamic>> bulkUploadFaithfuls({required File file}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });
      final response = await _dio.post(
        'faithful_registration.api.faithful.bulk_upload_faithfuls',
        data: formData,
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Bulk Upload Faithfuls Error: $e');
      return {'status': 'error', 'message': 'Failed to bulk upload faithfuls: $e'};
    }
  }

  Future<Map<String, dynamic>> reassignFaithful({
    required String faithfulId,
    required String newMosque,
    required String newHousehold,
    required String reason,
  }) async {
    try {
      final requestData = {
        'data': {
          'faithful_id': faithfulId,
          'new_mosque': newMosque,
          'new_household': newHousehold,
          'reason': reason,
        }
      };
      final response = await _dio.post(
        'faithful_registration.api.faithful.reassign_faithful',
        data: requestData,
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Reassign Faithful Error: $e');
      return {'status': 'error', 'message': 'Failed to reassign faithful: $e'};
    }
  }

  Future<Map<String, dynamic>> unassignFaithful({
    required String faithfulId,
    required String mosqueId,
    required String reason,
  }) async {
    try {
      final queryParams = {
        'faithful_id': faithfulId,
        'mosque_id': mosqueId,
        'reason': reason,
      };
      final response = await _dio.get(
        'faithful_registration.api.faithful.unassign_faithful',
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;
      return {
        'status': data['status'] ?? 'error',
        'message': data['message'] ?? 'Invalid response',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      print('Unassign Faithful Error: $e');
      return {'status': 'error', 'message': 'Failed to unassign faithful: $e'};
    }
  }

  // **Helper Methods (unchanged)**
  String _normalizeIncome(String? income) {
    if (income == null || income.isEmpty) return '';
    const incomeMap = {
      r'<$500': r'<$500',
      r'$500-$1000': r'$500-$1000',
      r'$1100-$100000': r'$1100-$100000',
      r'$10000000+': r'$10000000+',
    };
    return incomeMap[income] ?? income;
  }

  String? _encodeFile(File? file, String field) {
    if (file == null) return null;
    final bytes = file.readAsBytesSync();
    const maxFileSize = 5 * 1024 * 1024; // 5MB
    if (bytes.length > maxFileSize) {
      throw Exception('$field file size exceeds 5MB limit');
    }
    String mimeType;
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        mimeType = 'image/png';
        break;
      case 'jpg':
      case 'jpeg':
        mimeType = 'image/jpeg';
        break;
      case 'pdf':
        mimeType = 'application/pdf';
        break;
      default:
        throw Exception('Unsupported file type for $field: $extension');
    }
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }
}