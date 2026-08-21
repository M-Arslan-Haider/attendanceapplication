import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ========== LOGIN API ==========
  Future<LoginResponse> login({
    required String employeeId,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'
            '?employee_id=$employeeId'
            '&password=$password',
      );

      print('🔵 Login API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again.');
        },
      );

      print('🟢 Login Response Status: ${response.statusCode}');
      print('🟢 Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return LoginResponse.fromJson(jsonData);
      } else {
        return LoginResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
          user: null,
        );
      }
    } catch (e) {
      print('🔴 Login Error: $e');
      return LoginResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        user: null,
      );
    }
  }

  // ========== PROFILE API ==========
  Future<LoginResponse> getProfile({
    required String employeeId,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.profileEndpoint}'
            '?employee_id=$employeeId',
      );

      print('🔵 Profile API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again.');
        },
      );

      print('🟢 Profile Response Status: ${response.statusCode}');
      print('🟢 Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['items'] != null &&
            jsonData['items'] is List &&
            jsonData['items'].isNotEmpty) {
          final userData = jsonData['items'][0];
          return LoginResponse(
            success: true,
            message: 'Profile fetched successfully',
            user: User.fromJson(userData),
          );
        } else {
          return await _getLoginProfile(employeeId);
        }
      } else {
        return LoginResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
          user: null,
        );
      }
    } catch (e) {
      print('🔴 Profile Error: $e');
      return LoginResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        user: null,
      );
    }
  }

  // ========== FALLBACK: Get from LOGIN table ==========
  Future<LoginResponse> _getLoginProfile(String employeeId) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'
            '?employee_id=$employeeId',
      );

      print('🔵 Fallback Login API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again.');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return LoginResponse.fromJson(jsonData);
      } else {
        return LoginResponse(
          success: false,
          message: 'Employee not found',
          user: null,
        );
      }
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Error fetching profile: ${e.toString()}',
        user: null,
      );
    }
  }

  // ========== LOCATIONS API ==========
  Future<LocationResponse> getLocations() async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.locationEndpoint}',
      );

      print('🔵 Locations API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again.');
        },
      );

      print('🟢 Locations Response Status: ${response.statusCode}');
      print('🟢 Locations Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return LocationResponse.fromJson(jsonData);
      } else {
        return await _getLocationsAlternate();
      }
    } catch (e) {
      print('🔴 Locations Error: $e');
      return await _getLocationsAlternate();
    }
  }

  // ========== LOCATIONS ALTERNATE ENDPOINT ==========
  Future<LocationResponse> _getLocationsAlternate() async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/locations/GET',
      );

      print('🔵 Locations Alternate API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again.');
        },
      );

      print('🟢 Locations Alternate Response Status: ${response.statusCode}');
      print('🟢 Locations Alternate Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return LocationResponse.fromJson(jsonData);
      } else {
        return LocationResponse(
          success: false,
          message: 'No locations found',
          locations: [],
        );
      }
    } catch (e) {
      print('🔴 Locations Alternate Error: $e');
      return LocationResponse(
        success: false,
        message: 'Error fetching locations: ${e.toString()}',
        locations: [],
      );
    }
  }

  // ========== EMPLOYEE LOCATIONS API ==========
  Future<EmployeeLocationResponse> getEmployeeLocations({
    required String employeeId,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.employeeLocationsEndpoint}'
            '?employee_id=$employeeId',
      );

      print('🔵 Employee Locations API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again.');
        },
      );

      print('🟢 Employee Locations Response Status: ${response.statusCode}');
      print('🟢 Employee Locations Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['items'] != null &&
            jsonData['items'] is List &&
            jsonData['items'].isNotEmpty) {
          return EmployeeLocationResponse.fromJson(jsonData);
        } else {
          return EmployeeLocationResponse(
            success: true,
            message: 'No employee locations found',
            employeeLocations: [],
          );
        }
      } else {
        print('⚠️ Employee Locations API returned ${response.statusCode}, using empty list');
        return EmployeeLocationResponse(
          success: false,
          message: 'API returned ${response.statusCode}',
          employeeLocations: [],
        );
      }
    } catch (e) {
      print('🔴 Employee Locations Error: $e');
      return EmployeeLocationResponse(
        success: false,
        message: 'Error: ${e.toString()}',
        employeeLocations: [],
      );
    }
  }

  // ========== CHECK-IN API ==========
  Future<Map<String, dynamic>> checkIn({
    required String attendanceCode,
    required String employeeId,
    required String employeeName,
    required String designation,
    required String locationName,
    required String checkInTime,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.attendanceInEndpoint}',
      );

      print('🔵 Check-In API URL: $url');

      final body = {
        'attendance_code': attendanceCode,
        'employee_id': employeeId,
        'employee_name': employeeName,
        'designation': designation,
        'location_name': locationName,
        'check_in_time': checkInTime,
      };

      print('🔵 Check-In Request Body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again.');
        },
      );

      print('🟢 Check-In Response Status: ${response.statusCode}');
      print('🟢 Check-In Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonData = json.decode(response.body);
          final bool isSuccess = jsonData['status'] == 'success';

          return {
            'success': isSuccess,
            'message': jsonData['message'] ?? 'Check-in processed',
            'attendance_code': jsonData['attendance_code'] ?? attendanceCode,
          };
        } catch (e) {
          print('⚠️ Could not parse JSON response, but status was 200');
          return {
            'success': true,
            'message': 'Check-in successful',
            'attendance_code': attendanceCode,
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🔴 Check-In Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // ========== CHECK-OUT API ==========
  Future<Map<String, dynamic>> checkOut({
    required String attendanceCode,
    required String checkOutTime,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.attendanceOutEndpoint}',
      );

      print('🔵 Check-Out API URL: $url');

      final body = {
        'attendance_code': attendanceCode,
        'check_out_time': checkOutTime,
      };

      print('🔵 Check-Out Request Body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again.');
        },
      );

      print('🟢 Check-Out Response Status: ${response.statusCode}');
      print('🟢 Check-Out Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonData = json.decode(response.body);
          final bool isSuccess = jsonData['status'] == 'success';

          return {
            'success': isSuccess,
            'message': jsonData['message'] ?? 'Check-out processed',
            'totalTime': jsonData['total_time'] ?? 'N/A',
          };
        } catch (e) {
          print('⚠️ Could not parse JSON response, but status was 200');
          return {
            'success': true,
            'message': 'Check-out successful',
            'totalTime': 'N/A',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'totalTime': 'N/A',
        };
      }
    } catch (e) {
      print('🔴 Check-Out Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'totalTime': 'N/A',
      };
    }
  }

  // ========== TEST CONNECTION ==========
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}