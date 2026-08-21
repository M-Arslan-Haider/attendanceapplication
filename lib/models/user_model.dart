class User {
  final int id;
  final String employeeId;
  final String employeeName;
  final String shiftStartTime;
  final String shiftEndTime;
  // New Profile Fields
  final String fatherName;
  final String designation;
  final String phoneNumber;
  final String email;

  User({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.shiftStartTime,
    required this.shiftEndTime,
    this.fatherName = '',
    this.designation = '',
    this.phoneNumber = '',
    this.email = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Try different key formats
    final id = json['ID'] ?? json['id'] ?? 0;
    final employeeId = json['EMPLOYEE_ID']?.toString() ??
        json['employee_id']?.toString() ??
        '';
    final employeeName = json['EMPLOYEE_NAME']?.toString() ??
        json['employee_name']?.toString() ??
        '';
    final shiftStartTime = json['SHIFT_START_TIME']?.toString() ??
        json['shift_start_time']?.toString() ??
        '';
    final shiftEndTime = json['SHIFT_END_TIME']?.toString() ??
        json['shift_end_time']?.toString() ??
        '';
    final fatherName = json['FATHER_NAME']?.toString() ??
        json['father_name']?.toString() ??
        '';
    final designation = json['DESIGNATION']?.toString() ??
        json['designation']?.toString() ??
        '';
    final phoneNumber = json['PHONE_NUMBER']?.toString() ??
        json['phone_number']?.toString() ??
        '';
    final email = json['EMAIL']?.toString() ??
        json['email']?.toString() ??
        '';

    return User(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      shiftStartTime: shiftStartTime,
      shiftEndTime: shiftEndTime,
      fatherName: fatherName,
      designation: designation,
      phoneNumber: phoneNumber,
      email: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'EMPLOYEE_ID': employeeId,
      'EMPLOYEE_NAME': employeeName,
      'SHIFT_START_TIME': shiftStartTime,
      'SHIFT_END_TIME': shiftEndTime,
      'FATHER_NAME': fatherName,
      'DESIGNATION': designation,
      'PHONE_NUMBER': phoneNumber,
      'EMAIL': email,
    };
  }
}

// ========== LOCATION MODEL ==========
class Location {
  final int id;
  final String locationName;
  final double latitude;
  final double longitude;
  final double radius;

  Location({
    required this.id,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['ID'] ?? json['id'] ?? 0,
      locationName: json['LOCATION_NAME']?.toString() ??
          json['location_name']?.toString() ??
          '',
      latitude: (json['LATITUDE'] ?? json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['LONGITUDE'] ?? json['longitude'] ?? 0.0).toDouble(),
      radius: (json['RADIUS'] ?? json['radius'] ?? 100.0).toDouble(),
    );
  }
}

// ========== EMPLOYEE LOCATION MODEL ==========
class EmployeeLocation {
  final int id;
  final String employeeId;
  final int locationId;
  final String locationName;
  final bool isPrimary;

  EmployeeLocation({
    required this.id,
    required this.employeeId,
    required this.locationId,
    required this.locationName,
    required this.isPrimary,
  });

  factory EmployeeLocation.fromJson(Map<String, dynamic> json) {
    return EmployeeLocation(
      id: json['ID'] ?? json['id'] ?? 0,
      employeeId: json['EMPLOYEE_ID']?.toString() ??
          json['employee_id']?.toString() ??
          '',
      locationId: json['LOCATION_ID'] ?? json['location_id'] ?? 0,
      locationName: json['LOCATION_NAME']?.toString() ??
          json['location_name']?.toString() ??
          '',
      isPrimary: json['IS_PRIMARY'] ?? json['is_primary'] ?? false,
    );
  }
}

// ========== LOCATION RESPONSE ==========
class LocationResponse {
  final bool success;
  final String message;
  final List<Location> locations;

  LocationResponse({
    required this.success,
    required this.message,
    this.locations = const [],
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null && json['items'] is List) {
      final locations = (json['items'] as List)
          .map((item) => Location.fromJson(item))
          .toList();
      return LocationResponse(
        success: true,
        message: 'Success',
        locations: locations,
      );
    } else {
      return LocationResponse(
        success: false,
        message: 'No locations found',
        locations: [],
      );
    }
  }
}

// ========== EMPLOYEE LOCATION RESPONSE ==========
class EmployeeLocationResponse {
  final bool success;
  final String message;
  final List<EmployeeLocation> employeeLocations;

  EmployeeLocationResponse({
    required this.success,
    required this.message,
    this.employeeLocations = const [],
  });

  factory EmployeeLocationResponse.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null && json['items'] is List) {
      final locations = (json['items'] as List)
          .map((item) => EmployeeLocation.fromJson(item))
          .toList();
      return EmployeeLocationResponse(
        success: true,
        message: 'Success',
        employeeLocations: locations,
      );
    } else {
      return EmployeeLocationResponse(
        success: false,
        message: 'No locations found for employee',
        employeeLocations: [],
      );
    }
  }
}

// Login Response Model
class LoginResponse {
  final bool success;
  final String message;
  final User? user;

  LoginResponse({
    required this.success,
    required this.message,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Check if we have items in response
    if (json['items'] != null && json['items'] is List && json['items'].isNotEmpty) {
      final userData = json['items'][0];
      return LoginResponse(
        success: true,
        message: 'Success',
        user: User.fromJson(userData),
      );
    } else {
      return LoginResponse(
        success: false,
        message: 'No data found for this employee',
        user: null,
      );
    }
  }
}