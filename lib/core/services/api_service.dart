import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'dart:convert';

class ApiService with ChangeNotifier {
  static const String baseUrl = 'http://192.168.1.102/api/method/';
  static const String imageBaseUrl = 'http://192.168.1.102';
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
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
  final Map<String, String> _householdNameCache = {};
  final Map<String, String> _mosqueNameCache = {};

  // Public getter for _sid
  String? get sid => _sid;

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

  Future<List<Map<String, dynamic>>> searchFaithful({required String name}) async {
    try {
      final response = await _dio.get(
        'faithful_registration.api.faithful.get_faithful',
        queryParameters: {'full_name': name},
      );
      print('Search Faithful Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['status'] == 'success' && data['data'] != null) {
        final faithfulData = data['data'] as List<dynamic>;
        return faithfulData.map((faithful) {
          return {
            'name': faithful['name'],
            'full_name': faithful['full_name'],
            'email': faithful['email'],
            'phone': faithful['phone'],
            'household': faithful['household'],
            'household_name': faithful['household_name'],
            'date_of_birth': faithful['date_of_birth'],
            'gender': faithful['gender'],
            'mosque': faithful['mosque'],
            'mosque_name': faithful['mosque_name'],
            'marital_status': faithful['marital_status'],
            'occupation': faithful['occupation'],
            'education_level': faithful['education_level'],
            'monthly_household_income': faithful['monthly_household_income'],
            'date_joined_community': faithful['date_joined_community'],
            'gps_coordinates': faithful['gps_coordinates'],
            'profile_image': faithful['profile_image'] != null
                ? '$imageBaseUrl${faithful['profile_image']}'
                : null,
            'national_id_document': faithful['national_id_document'] != null
                ? '$imageBaseUrl${faithful['national_id_document']}'
                : null,
            'special_needs_proof': faithful['special_needs_proof'] != null
                ? '$imageBaseUrl${faithful['special_needs_proof']}'
                : null,
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Search Faithful Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> searchFaithfulById({required String name}) async {
    try {
      final response = await _dio.get(
        'faithful_registration.api.faithful.get_faithful',
        queryParameters: {'name': name},
      );
      print('Search Faithful By ID Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['status'] == 'success' && data['data'] != null) {
        final faithfulData = data['data'] as Map<String, dynamic>;
        return {
          'status': 'success',
          'message': data['message'] ?? 'Faithful found',
          'name': faithfulData['name'],
          'full_name': faithfulData['full_name'],
          'email': faithfulData['email'],
          'phone': faithfulData['phone'],
          'household': faithfulData['household'],
          'household_name': faithfulData['household_name'],
          'date_of_birth': faithfulData['date_of_birth'],
          'gender': faithfulData['gender'],
          'mosque': faithfulData['mosque'],
          'mosque_name': faithfulData['mosque_name'],
          'spouse_name': faithfulData['spouse_name'],
          'place_of_birth': faithfulData['place_of_birth'],
          'national_id_number': faithfulData['national_id_number'],
          'age_of_dependants': faithfulData['age_of_dependants'],
          'number_of_dependants': faithfulData['number_of_dependants'],
          'special_needs_details': faithfulData['special_needs_details'],
          'physical_address': faithfulData['physical_address'],
          'marital_status': faithfulData['marital_status'],
          'occupation': faithfulData['occupation'],
          'education_level': faithfulData['education_level'],
          'monthly_household_income': faithfulData['monthly_household_income'],
          'date_joined_community': faithfulData['date_joined_community'],
          'gps_coordinates': faithfulData['gps_coordinates'],
          'profile_image': faithfulData['profile_image'] != null
              ? '$imageBaseUrl${faithfulData['profile_image']}'
              : null,
          'national_id_document': faithfulData['national_id_document'] != null
              ? '$imageBaseUrl${faithfulData['national_id_document']}'
              : null,
          'special_needs_proof': faithfulData['special_needs_proof'] != null
              ? '$imageBaseUrl${faithfulData['special_needs_proof']}'
              : null,
        };
      }
      return {
        'status': 'error',
        'message': data['message'] ?? 'Faithful not found',
      };
    } catch (e) {
      print('Search Faithful By ID Error: $e');
      return {'status': 'error', 'message': 'Failed to search faithful: $e'};
    }
  }

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
      print('Get All Faithfuls Response: ${response.data}');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.map((item) {
          final faithful = item as Map<String, dynamic>;
          return {
            'name': faithful['name'],
            'full_name': faithful['full_name'],
            'email': faithful['email'],
            'phone': faithful['phone'],
            'household': faithful['household'],
            'household_name': faithful['household_name'],
            'date_of_birth': faithful['date_of_birth'],
            'gender': faithful['gender'],
            'mosque': faithful['mosque'],
            'mosque_name': faithful['mosque_name'],
            'marital_status': faithful['marital_status'],
            'occupation': faithful['occupation'],
            'education_level': faithful['education_level'],
            'monthly_household_income': faithful['monthly_household_income'],
            'spouse_name': faithful['spouse_name'],
            'place_of_birth': faithful['place_of_birth'],
            'age_of_dependants': faithful['age_of_dependants'],
            'number_of_dependants': faithful['number_of_dependants'],
            'special_needs_details': faithful['special_needs_details'],
            'physical_address': faithful['physical_address'],
            'national_id_number': faithful['national_id_number'],
            'date_joined_community': faithful['date_joined_community'],
            'gps_coordinates': faithful['gps_coordinates'],
            'profile_image': faithful['profile_image'] != null
                ? '$imageBaseUrl${faithful['profile_image']}'
                : null,
            'national_id_document': faithful['national_id_document'] != null
                ? '$imageBaseUrl${faithful['national_id_document']}'
                : null,
            'special_needs_proof': faithful['special_needs_proof'] != null
                ? '$imageBaseUrl${faithful['special_needs_proof']}'
                : null,
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Get All Faithfuls Error: $e');
      return [];
    }
  }

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

  Future<List<Map<String, dynamic>>> getAllImams() async {
    try {
      final response = await _dio.get('faithful_registration.api.imam.get_all_imams');
      if (response.data['status'] == 'success') {
        return List<Map<String, dynamic>>.from(response.data['data']).map((imam) {
          return {
            'name': imam['name'] as String? ?? 'N/A',
            'imam_name': imam['imam_name'] as String? ?? 'N/A',
            'mosque_assigned': imam['mosque_assigned'] as String? ?? 'N/A',
            'role_in_mosque': imam['role_in_mosque'] as String? ?? 'N/A',
            'status': imam['status'] as String? ?? 'N/A',
          };
        }).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch imams');
    } catch (e) {
      throw Exception('Error fetching imams: $e');
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
      final faithfuls = await getAllFaithfuls();
      final householdMap = <String, Map<String, dynamic>>{};
      for (var f in faithfuls) {
        final household = f['household'] as String?;
        if (household != null && household.isNotEmpty) {
          if (!householdMap.containsKey(household)) {
            householdMap[household] = {
              'household': household,
              'household_name': f['household_name'] as String? ?? 'Unknown',
              'count': 0,
              'members': <Map<String, dynamic>>[],
            };
          }
          householdMap[household]!['count'] = (householdMap[household]!['count'] as int) + 1;
          householdMap[household]!['members'].add({
            'name': f['name'] as String? ?? 'N/A',
            'full_name': f['full_name'] as String? ?? 'N/A',
            'phone': f['phone'] as String? ?? 'N/A',
            'national_id_number': f['national_id_number'] as String? ?? 'N/A',
            'mosque_name': f['mosque_name'] as String? ?? 'N/A',
            'mosque': f['mosque'] as String? ?? 'N/A',
            'marital_status': f['marital_status'] as String? ?? 'N/A',
            'profile_image': f['profile_image'],
          });
        }
      }
      return householdMap.values.toList();
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
          if (specialNeeds != null && specialNeeds.isNotEmpty) 'special_needs_details': specialNeeds,
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

  Future<Map<String, dynamic>> registerMosque({
    required String mosqueName,
    required String location,
    required String dateEstablished,
    required String headImam,
    required int totalCapacity,
    required String contactEmail,
    required String contactPhone,
    String? frontImage,
    String? backImage,
    String? madrasaImage,
    String? insideImage,
    String? ceilingImage,
    String? minbarImage,
  }) async {
    try {
      final response = await _dio.post(
        'faithful_registration.api.mosque.register_mosque',
        data: {
          'data': {
            'mosque_name': mosqueName,
            'location': location,
            'date_established': dateEstablished,
            'head_imam': headImam,
            'total_capacity': totalCapacity,
            'contact_email': contactEmail,
            'contact_phone': contactPhone,
            'front_image': frontImage,
            'back_image': backImage,
            'madrasa_image': madrasaImage,
            'inside_image': insideImage,
            'ceiling_image': ceilingImage,
            'minbar_image': minbarImage,
          },
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Error registering mosque: $e');
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
    String? frontImage,
    String? backImage,
    String? madrasaImage,
    String? insideImage,
    String? ceilingImage,
    String? minbarImage,
  }) async {
    try {
      final response = await _dio.put(
        'faithful_registration.api.mosque.update_mosque',
        data: {
          'data': {
            'name': name,
            'mosque_name': mosqueName,
            'location': location,
            'date_established': dateEstablished,
            'head_imam': headImam,
            'total_capacity': totalCapacity,
            'contact_email': contactEmail,
            'contact_phone': contactPhone,
            'front_image': frontImage,
            'back_image': backImage,
            'madrasa_image': madrasaImage,
            'inside_image': insideImage,
            'ceiling_image': ceilingImage,
            'minbar_image': minbarImage,
          },
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Error updating mosque: $e');
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
          if (specialNeeds != null && specialNeeds.isNotEmpty) 'special_needs_details': specialNeeds,
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
