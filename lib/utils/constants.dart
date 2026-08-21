class ApiConstants {
  // Base URL
  static const String baseUrl =
      'https://g6f3af2243f84d3-devprokit.adb.ap-singapore-1.oraclecloudapps.com/ords/devprokit';

  // Endpoints
  static const String loginEndpoint = '/loginget/get/';
  static const String profileEndpoint = '/profile/GET';
  static const String locationEndpoint = '/locations/';
  static const String employeeLocationsEndpoint = '/employee_locations/GET';

  // Attendance Endpoints - WITH trailing slashes (as per your working URL)
  static const String attendanceInEndpoint = '/attendancein/post/';
  static const String attendanceOutEndpoint = '/attendanceout/post/';

  // Headers
  static const String contentType = 'application/json';
}