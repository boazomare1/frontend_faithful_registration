import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class ApiService with ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.101/api/method/',
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
        _dio.options.headers['Cookie'] = 'sid=$_sid'; // or 'X-Session-Id': _sid
        print('Loaded sid: $_sid');
      }
    }

    void setSid(String sid) async {
      _sid = sid;
      _dio.options.headers['Cookie'] = 'sid=$_sid'; // or 'X-Session-Id': sid
      await _storage.write(key: 'sid', value: sid);
      print('Set sid: $sid');
      notifyListeners();
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
      print('response: ${response.data}');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.length;
      }
      return 0;
    } catch (e) {
      print('Get Female Count Error: $e}');
      return 0;
    }
  }

  Future<int> getMaleCount() async {
    try {
      final response = await _dio.get(
        'faithful_registration.api.faithful.get_all_faithfuls',
        queryParameters: {'gender': 'Male'},
      );
      print('response: ${response.data}');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List<dynamic>;
        return data.length;
      }
      return 0;
    } catch (e) {
      print('Get Male Count Error: $e}');
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
    required String physicalAddress,
    required int numberOfDependants,
    required String email,
    required String gender,
    required String mosque,
    required String household,
    required String dateOfBirth,
    required String placeOfBirth,
    required String nationalIdNumber,
    required String maritalStatus,
    required String spouseName,
    required String ageOfDependants,
    required String educationLevel,
    required String occupation,
  }) async {
    try {
      final requestData = {
        'data': {
          'full_name': fullName,
          'phone': phone,
          'physical_address': physicalAddress,
          'number_of_dependants': numberOfDependants,
          'email': email,
          'gender': gender,
          'mosque': mosque,
          'household': household,
          'date_of_birth': dateOfBirth,
          'place_of_birth': placeOfBirth,
          'national_id_number': nationalIdNumber,
          'marital_status': maritalStatus,
          'spouse_name': spouseName,
          'age_of_dependants': ageOfDependants,
          'education_level': educationLevel,
          'occupation': occupation,
        }
      };
      print('Register Faithful Request: $requestData');
      final response = await _dio.post(
        'faithful_registration.api.faithful.register_faithful',
        data: requestData,
      );
      print('Register Faithful Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      return data['message'] ?? {'status': 'error', 'message': 'Invalid response'};
    } catch (e) {
      print('Register Faithful Error: $e');
      return {'status': 'error', 'message': 'Failed to register faithful: $e'};
    }
  }
}