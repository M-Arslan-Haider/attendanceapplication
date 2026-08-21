//
//
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../models/user_model.dart';
// import '../theme/app_theme.dart';
// import '../services/api_service.dart';
// import '../services/session_service.dart';
// import '../widgets/app_snackbar.dart';
// import 'login_screen.dart';
// import 'profile_screen.dart';
// import 'leave_screen.dart';
// import 'setting_screen.dart';
//
// class DashboardScreen extends StatefulWidget {
//   final User user;
//
//   const DashboardScreen({super.key, required this.user});
//
//   @override
//   DashboardScreenState createState() => DashboardScreenState();
// }
//
// class DashboardScreenState extends State<DashboardScreen> {
//   final ApiService _apiService = ApiService();
//   bool _isCheckedIn = false;
//   bool _isLoading = false;
//   String _timerText = '00:00:00';
//   int _seconds = 0;
//   late User _userData;
//   bool _isLoadingProfile = true;
//   String _profileError = '';
//   int _selectedIndex = 0;
//
//   // Attendance tracking
//   String? _attendanceCode;
//
//   // Location related
//   List<Location> _locations = [];
//   List<EmployeeLocation> _employeeLocations = [];
//   Location? _selectedLocation;
//   bool _isLoadingLocations = false;
//   bool _isCheckingIn = false;
//   bool _hasLocationPermission = false;
//   Position? _currentPosition;
//   bool _isWithinRadius = false;
//   double _distanceToLocation = 0;
//
//   // List of pages for bottom navigation
//   late final List<Widget> _pages;
//
//   @override
//   void initState() {
//     super.initState();
//     _userData = widget.user;
//     print('🔍 Dashboard initialized with user: ${_userData.employeeId}');
//     _fetchUserProfile();
//     _fetchEmployeeLocations();
//     _checkLocationPermission();
//
//     // Initialize pages with user data
//     _pages = [
//       HomePage(
//         user: _userData,
//         onRefresh: _fetchUserProfile,
//         onCheckIn: _handleCheckIn,
//         onCheckOut: _handleCheckOut,
//         locations: _locations,
//         employeeLocations: _employeeLocations,
//         isCheckingIn: _isCheckingIn,
//         isCheckedIn: _isCheckedIn,
//         timerText: _timerText,
//         hasPermission: _hasLocationPermission,
//         currentPosition: _currentPosition,
//         isWithinRadius: _isWithinRadius,
//         distanceToLocation: _distanceToLocation,
//         attendanceCode: _attendanceCode,
//       ),
//       ProfileScreen(user: _userData),
//       LeaveScreen(user: _userData),
//       SettingsScreen(user: _userData),
//     ];
//   }
//
//   // ========== GENERATE ATTENDANCE CODE ==========
//   String _generateAttendanceCode() {
//     // Format: ATD-EMP-001-XXXXX (where XXXXX is random 5-digit number)
//     final random = (10000 + (DateTime.now().millisecondsSinceEpoch % 90000)).toString();
//     return 'ATD-${_userData.employeeId}-$random';
//   }
//
//   // ========== GET FORMATTED CHECK-IN TIME ==========
//   String _getFormattedCheckInTime() {
//     final now = DateTime.now();
//     return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
//         '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
//   }
//
//   // ========== GET FORMATTED CHECK-OUT TIME ==========
//   String _getFormattedCheckOutTime() {
//     final now = DateTime.now();
//     return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
//         '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
//   }
//
//   // ========== CHECK LOCATION PERMISSION ==========
//   Future<void> _checkLocationPermission() async {
//     try {
//       final status = await Permission.location.status;
//       print('📍 Location Permission Status: $status');
//
//       if (status.isGranted) {
//         setState(() {
//           _hasLocationPermission = true;
//         });
//         await _getCurrentLocation();
//       } else if (status.isDenied) {
//         final result = await Permission.location.request();
//         setState(() {
//           _hasLocationPermission = result.isGranted;
//         });
//         if (result.isGranted) {
//           await _getCurrentLocation();
//         } else {
//           if (mounted) {
//             _showPermissionDialog();
//           }
//         }
//       } else if (status.isPermanentlyDenied) {
//         if (mounted) {
//           _showSettingsDialog();
//         }
//       }
//
//       _updateHomePage();
//     } catch (e) {
//       print('🔴 Error checking location permission: $e');
//     }
//   }
//
//   void _showPermissionDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Location Permission Required'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.location_on,
//               size: 50,
//               color: Colors.orange,
//             ),
//             SizedBox(height: 12),
//             Text(
//               'This app needs location access to verify your attendance location.\n\n'
//                   'Please allow location permission to check-in at your assigned location.',
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _checkLocationPermission();
//             },
//             child: const Text('Try Again'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               final result = await Permission.location.request();
//               setState(() {
//                 _hasLocationPermission = result.isGranted;
//               });
//               if (result.isGranted) {
//                 await _getCurrentLocation();
//               }
//               _updateHomePage();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primaryColor,
//             ),
//             child: const Text('Allow Location'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSettingsDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Location Permission Required'),
//         content: const Text(
//           'Location permission is permanently denied. Please enable it from app settings.',
//           textAlign: TextAlign.center,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _checkLocationPermission();
//             },
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               openAppSettings();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primaryColor,
//             ),
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         print('⚠️ Location services are disabled');
//         if (mounted) {
//           AppSnackBar.warning(context, '⚠️ Please enable GPS/location services');
//         }
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         return;
//       }
//
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       setState(() {
//         _currentPosition = position;
//       });
//       print('📍 Current Location: ${position.latitude}, ${position.longitude}');
//
//       _checkIfWithinRadius();
//     } catch (e) {
//       print('🔴 Error getting location: $e');
//     }
//   }
//
//   // ========== CHECK IF USER IS WITHIN RADIUS ==========
//   void _checkIfWithinRadius() {
//     if (_selectedLocation == null || _currentPosition == null) {
//       setState(() {
//         _isWithinRadius = false;
//         _distanceToLocation = 0;
//       });
//       return;
//     }
//
//     final distance = Geolocator.distanceBetween(
//       _currentPosition!.latitude,
//       _currentPosition!.longitude,
//       _selectedLocation!.latitude,
//       _selectedLocation!.longitude,
//     );
//
//     setState(() {
//       _distanceToLocation = distance;
//       _isWithinRadius = distance <= _selectedLocation!.radius;
//     });
//
//     print('📍 Distance to ${_selectedLocation!.locationName}: ${distance.toStringAsFixed(2)}m');
//     print('📍 Within radius: $_isWithinRadius (Radius: ${_selectedLocation!.radius}m)');
//
//     _updateHomePage();
//   }
//
//   Future<void> _fetchEmployeeLocations() async {
//     try {
//       setState(() {
//         _isLoadingLocations = true;
//       });
//
//       final locationResponse = await _apiService.getLocations();
//
//       if (locationResponse.success && locationResponse.locations.isNotEmpty) {
//         setState(() {
//           _locations = locationResponse.locations;
//         });
//         print('✅ Loaded ${_locations.length} locations from API');
//       } else {
//         print('⚠️ No locations from API, using sample data');
//         _addSampleLocations();
//         setState(() {
//           _isLoadingLocations = false;
//         });
//         _updateHomePage();
//         return;
//       }
//
//       final employeeResponse = await _apiService.getEmployeeLocations(
//         employeeId: _userData.employeeId,
//       );
//
//       if (employeeResponse.success && employeeResponse.employeeLocations.isNotEmpty) {
//         setState(() {
//           _employeeLocations = employeeResponse.employeeLocations;
//           final primary = _employeeLocations.firstWhere(
//                 (el) => el.isPrimary,
//             orElse: () => _employeeLocations.first,
//           );
//           final matchedLocation = _locations.firstWhere(
//                 (loc) => loc.id == primary.locationId,
//             orElse: () => _locations.first,
//           );
//           _selectedLocation = matchedLocation;
//           _isLoadingLocations = false;
//         });
//         print('✅ Loaded ${_employeeLocations.length} employee locations');
//       } else {
//         setState(() {
//           _employeeLocations = _locations.map((loc) => EmployeeLocation(
//             id: loc.id,
//             employeeId: _userData.employeeId,
//             locationId: loc.id,
//             locationName: loc.locationName,
//             isPrimary: loc.id == 1,
//           )).toList();
//           _selectedLocation = _locations.first;
//           _isLoadingLocations = false;
//         });
//         print('⚠️ No employee locations, using all locations');
//       }
//
//       _checkIfWithinRadius();
//       _updateHomePage();
//     } catch (e) {
//       print('🔴 Error fetching locations: $e');
//       _addSampleLocations();
//       _updateHomePage();
//     }
//   }
//
//   void _addSampleLocations() {
//     setState(() {
//       _locations = [
//         Location(
//           id: 1,
//           locationName: 'MetaXperts Office',
//           latitude: 32.5011987,
//           longitude: 74.4976395,
//           radius: 100,
//         ),
//         Location(
//           id: 2,
//           locationName: 'Model Town, Sialkot',
//           latitude: 32.5012163,
//           longitude: 74.5214267,
//           radius: 100,
//         ),
//         Location(
//           id: 3,
//           locationName: 'Sialkot Clock Tower',
//           latitude: 32.5161556,
//           longitude: 74.5564577,
//           radius: 100,
//         ),
//       ];
//
//       _employeeLocations = [
//         EmployeeLocation(
//           id: 1,
//           employeeId: _userData.employeeId,
//           locationId: 1,
//           locationName: 'MetaXperts Office',
//           isPrimary: true,
//         ),
//         EmployeeLocation(
//           id: 2,
//           employeeId: _userData.employeeId,
//           locationId: 2,
//           locationName: 'Model Town, Sialkot',
//           isPrimary: false,
//         ),
//         EmployeeLocation(
//           id: 3,
//           employeeId: _userData.employeeId,
//           locationId: 3,
//           locationName: 'Sialkot Clock Tower',
//           isPrimary: false,
//         ),
//       ];
//
//       _selectedLocation = _locations.first;
//       _isLoadingLocations = false;
//       _checkIfWithinRadius();
//
//       print('✅ Added sample locations for testing');
//     });
//   }
//
//   void _updateHomePage() {
//     _pages[0] = HomePage(
//       user: _userData,
//       onRefresh: _fetchUserProfile,
//       onCheckIn: _handleCheckIn,
//       onCheckOut: _handleCheckOut,
//       locations: _locations,
//       employeeLocations: _employeeLocations,
//       isCheckingIn: _isCheckingIn,
//       isCheckedIn: _isCheckedIn,
//       timerText: _timerText,
//       hasPermission: _hasLocationPermission,
//       currentPosition: _currentPosition,
//       isWithinRadius: _isWithinRadius,
//       distanceToLocation: _distanceToLocation,
//       attendanceCode: _attendanceCode,
//     );
//   }
//
//   // ========== HANDLE CHECK-IN ==========
//   Future<void> _handleCheckIn(Location? selectedLocation) async {
//     if (selectedLocation == null) {
//       AppSnackBar.warning(context, '⚠️ Please select a location first');
//       return;
//     }
//
//     // ========== CHECK LOCATION PERMISSION ==========
//     if (!_hasLocationPermission) {
//       final status = await Permission.location.request();
//       if (!status.isGranted) {
//         if (mounted) {
//           AppSnackBar.error(context, '⚠️ Location permission is required to check in');
//         }
//         return;
//       }
//       setState(() {
//         _hasLocationPermission = true;
//       });
//     }
//
//     // ========== GET CURRENT LOCATION ==========
//     final position = await _getCurrentPosition();
//     if (position == null) {
//       if (mounted) {
//         AppSnackBar.warning(context, '⚠️ Unable to get your current location. Please enable GPS.');
//       }
//       return;
//     }
//
//     // ========== CHECK IF WITHIN RADIUS ==========
//     final distance = Geolocator.distanceBetween(
//       position.latitude,
//       position.longitude,
//       selectedLocation.latitude,
//       selectedLocation.longitude,
//     );
//
//     print('📍 Distance to ${selectedLocation.locationName}: ${distance.toStringAsFixed(2)}m');
//
//     setState(() {
//       _currentPosition = position;
//       _distanceToLocation = distance;
//       _isWithinRadius = distance <= selectedLocation.radius;
//     });
//
//     if (distance > selectedLocation.radius) {
//       if (mounted) {
//         AppSnackBar.error(
//           context,
//           '❌ You are too far from ${selectedLocation.locationName}',
//           subtitle: 'Distance: ${distance.toStringAsFixed(0)}m (Max: ${selectedLocation.radius.toStringAsFixed(0)}m) — check-in blocked',
//           duration: const Duration(seconds: 4),
//         );
//       }
//       _updateHomePage();
//       return;
//     }
//
//     // ========== PROCEED WITH CHECK-IN ==========
//     setState(() {
//       _isCheckingIn = true;
//     });
//
//     try {
//       // Generate attendance code: ATD-EMP-001-XXXXX
//       final attendanceCode = _generateAttendanceCode();
//
//       // Get current device time for check-in
//       final checkInTime = _getFormattedCheckInTime();
//
//       // Call Check-In API with check-in time
//       final response = await _apiService.checkIn(
//         attendanceCode: attendanceCode,
//         employeeId: _userData.employeeId,
//         employeeName: _userData.employeeName,
//         designation: _userData.designation,
//         locationName: selectedLocation.locationName,
//         checkInTime: checkInTime,  // ← Pass the device time
//       );
//
//       if (!mounted) return;
//
//       if (response['success']) {
//         final code = response['attendance_code'] ?? attendanceCode;
//
//         setState(() {
//           _isCheckingIn = false;
//           _isCheckedIn = true;
//           _selectedLocation = selectedLocation;
//           _attendanceCode = code;
//         });
//         _startTimer();
//         _updateHomePage();
//
//         AppSnackBar.success(
//           context,
//           '✅ Checked In Successfully!',
//           subtitle: '📋 $code · ⏰ $checkInTime',
//         );
//       } else {
//         setState(() {
//           _isCheckingIn = false;
//         });
//         AppSnackBar.error(
//           context,
//           '❌ Check-in failed',
//           subtitle: response['message'] ?? 'Please try again',
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isCheckingIn = false;
//       });
//       AppSnackBar.error(
//         context,
//         '❌ Check-in failed',
//         subtitle: e.toString(),
//       );
//     }
//   }
//
//   // ========== HANDLE CHECK-OUT ==========
//   // ========== HANDLE CHECK-OUT ==========
//   Future<void> _handleCheckOut() async {
//     if (_attendanceCode == null || _attendanceCode!.isEmpty) {
//       AppSnackBar.error(context, '❌ No active check-in found');
//       return;
//     }
//
//     setState(() {
//       _isCheckingIn = true;
//     });
//
//     try {
//       // Get current device time for check-out
//       final checkOutTime = _getFormattedCheckOutTime();
//
//       // Call Check-Out API with the SAME attendance code
//       final response = await _apiService.checkOut(
//         attendanceCode: _attendanceCode!,  // Same code from check-in
//         checkOutTime: checkOutTime,
//       );
//
//       if (!mounted) return;
//
//       if (response['success']) {
//         final code = _attendanceCode;
//         _stopTimer();
//         // Reset all states properly
//         setState(() {
//           _isCheckingIn = false;
//           _isCheckedIn = false;
//           _attendanceCode = null;
//           _seconds = 0;
//           _timerText = '00:00:00';
//           // Re-check location to update "Within Radius" status
//           _checkIfWithinRadius();
//         });
//         _updateHomePage();
//
//         AppSnackBar.success(
//           context,
//           '✅ Checked Out Successfully!',
//           subtitle: '📋 $code · ⏰ $checkOutTime · Total: ${response['totalTime'] ?? 'N/A'}',
//         );
//       } else {
//         setState(() {
//           _isCheckingIn = false;
//         });
//         AppSnackBar.error(
//           context,
//           '❌ Check-out failed',
//           subtitle: response['message'] ?? 'Please try again',
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isCheckingIn = false;
//       });
//       AppSnackBar.error(
//         context,
//         '❌ Check-out failed',
//         subtitle: e.toString(),
//       );
//     }
//   }
//
//   Future<Position?> _getCurrentPosition() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         return null;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           return null;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         return null;
//       }
//
//       return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//     } catch (e) {
//       print('🔴 Error getting location: $e');
//       return null;
//     }
//   }
//
//   void _startTimer() {
//     _seconds = 0;
//     Future.doWhile(() async {
//       await Future.delayed(const Duration(seconds: 1));
//       if (!mounted || !_isCheckedIn) return false;
//       setState(() {
//         _seconds++;
//         _timerText = _formatTime(_seconds);
//         _updateHomePage();
//       });
//       return true;
//     });
//   }
//
//   void _stopTimer() {
//     setState(() {
//       _seconds = 0;
//       _timerText = '00:00:00';
//       _isCheckedIn = false;
//     });
//   }
//
//   String _formatTime(int seconds) {
//     final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
//     final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
//     final secs = (seconds % 60).toString().padLeft(2, '0');
//     return '$hours:$minutes:$secs';
//   }
//
//   void changeTab(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   Future<void> _fetchUserProfile() async {
//     try {
//       setState(() {
//         _isLoadingProfile = true;
//         _profileError = '';
//       });
//
//       String employeeId = _userData.employeeId.trim();
//
//       if (employeeId.isEmpty) {
//         setState(() {
//           _isLoadingProfile = false;
//           _profileError = 'Employee ID is empty. Please login again.';
//         });
//         if (mounted) {
//           AppSnackBar.error(context, '⚠️ Employee ID is empty. Please login again.');
//         }
//         return;
//       }
//
//       final response = await _apiService.getProfile(
//         employeeId: employeeId,
//       );
//
//       if (response.success && response.user != null) {
//         setState(() {
//           _userData = User(
//             id: _userData.id,
//             employeeId: _userData.employeeId,
//             employeeName: response.user!.employeeName.isNotEmpty
//                 ? response.user!.employeeName
//                 : _userData.employeeName,
//             shiftStartTime: response.user!.shiftStartTime.isNotEmpty
//                 ? response.user!.shiftStartTime
//                 : _userData.shiftStartTime,
//             shiftEndTime: response.user!.shiftEndTime.isNotEmpty
//                 ? response.user!.shiftEndTime
//                 : _userData.shiftEndTime,
//             fatherName: response.user!.fatherName,
//             designation: response.user!.designation,
//             phoneNumber: response.user!.phoneNumber,
//             email: response.user!.email,
//           );
//           _isLoadingProfile = false;
//
//           _pages[0] = HomePage(
//             user: _userData,
//             onRefresh: _fetchUserProfile,
//             onCheckIn: _handleCheckIn,
//             onCheckOut: _handleCheckOut,
//             locations: _locations,
//             employeeLocations: _employeeLocations,
//             isCheckingIn: _isCheckingIn,
//             isCheckedIn: _isCheckedIn,
//             timerText: _timerText,
//             hasPermission: _hasLocationPermission,
//             currentPosition: _currentPosition,
//             isWithinRadius: _isWithinRadius,
//             distanceToLocation: _distanceToLocation,
//             attendanceCode: _attendanceCode,
//           );
//           _pages[1] = ProfileScreen(user: _userData);
//           _pages[2] = LeaveScreen(user: _userData);
//           _pages[3] = SettingsScreen(user: _userData);
//         });
//
//         if (mounted) {
//           AppSnackBar.success(context, '✅ Profile loaded successfully!');
//         }
//       } else {
//         setState(() {
//           _isLoadingProfile = false;
//           _profileError = 'Additional profile details not available.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingProfile = false;
//         _profileError = e.toString();
//       });
//       print('🔴 Profile Error: $e');
//     }
//   }
//
//   void _logout() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await SessionService.clearSession();
//               if (mounted) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const LoginScreen(),
//                   ),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.errorColor,
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.fingerprint,
//                 size: 20,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'Attendance Pro',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: () {
//               Scaffold.of(context).openDrawer();
//             },
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {
//               AppSnackBar.info(context, 'No new notifications');
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchUserProfile,
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppTheme.primaryColor,
//                     AppTheme.primaryColor.withOpacity(0.7),
//                   ],
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   Container(
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Colors.white,
//                         width: 3,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         _userData.employeeName.isNotEmpty
//                             ? _userData.employeeName[0].toUpperCase()
//                             : '?',
//                         style: TextStyle(
//                           fontSize: 30,
//                           fontWeight: FontWeight.bold,
//                           color: AppTheme.primaryColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     _userData.employeeName,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'ID: ${_userData.employeeId}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                   ),
//                   if (_userData.designation.isNotEmpty) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       _userData.designation,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Text(
//                       '● Active',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 10),
//             _buildDrawerItem(
//               Icons.home_outlined,
//               'Home',
//                   () {
//                 Navigator.pop(context);
//                 changeTab(0);
//               },
//             ),
//             _buildDrawerItem(
//               Icons.fingerprint_outlined,
//               'Mark Attendance',
//                   () {
//                 Navigator.pop(context);
//                 changeTab(0);
//               },
//             ),
//             _buildDrawerItem(
//               Icons.history_outlined,
//               'History',
//                   () {
//                 Navigator.pop(context);
//                 AppSnackBar.info(context, 'History coming soon');
//               },
//             ),
//             const Spacer(),
//             const Divider(),
//             _buildDrawerItem(
//               Icons.person_outline,
//               'Profile',
//                   () {
//                 Navigator.pop(context);
//                 changeTab(1);
//               },
//               color: AppTheme.primaryColor,
//             ),
//             _buildDrawerItem(
//               Icons.settings_outlined,
//               'Settings',
//                   () {
//                 Navigator.pop(context);
//                 changeTab(3);
//               },
//             ),
//             _buildDrawerItem(
//               Icons.logout,
//               'Logout',
//                   () {
//                 Navigator.pop(context);
//                 _logout();
//               },
//               color: AppTheme.errorColor,
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'Version 1.0.0',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade400,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: _isLoadingProfile
//           ? const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               color: AppTheme.primaryColor,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Loading profile...',
//               style: TextStyle(
//                 color: AppTheme.textSecondaryColor,
//               ),
//             ),
//           ],
//         ),
//       )
//           : _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           changeTab(index);
//         },
//         selectedItemColor: AppTheme.primaryColor,
//         unselectedItemColor: Colors.grey.shade600,
//         selectedLabelStyle: const TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//         ),
//         unselectedLabelStyle: const TextStyle(
//           fontSize: 12,
//         ),
//         type: BottomNavigationBarType.fixed,
//         elevation: 8,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             activeIcon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.event_note_outlined),
//             activeIcon: Icon(Icons.event_note),
//             label: 'Leave',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings_outlined),
//             activeIcon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDrawerItem(
//       IconData icon,
//       String title,
//       VoidCallback onTap, {
//         Color? color,
//       }) {
//     return ListTile(
//       leading: Icon(
//         icon,
//         color: color ?? Colors.grey.shade700,
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontSize: 15,
//           color: color ?? AppTheme.textPrimaryColor,
//           fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
//         ),
//       ),
//       onTap: onTap,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//     );
//   }
// }
//
// // ====================================================================
// // ========== HOME PAGE (Embedded) ==========
// // ====================================================================
// class HomePage extends StatefulWidget {
//   final User user;
//   final Future<void> Function() onRefresh;
//   final Future<void> Function(Location? selectedLocation) onCheckIn;
//   final VoidCallback onCheckOut;
//   final List<Location> locations;
//   final List<EmployeeLocation> employeeLocations;
//   final bool isCheckingIn;
//   final bool isCheckedIn;
//   final String timerText;
//   final bool hasPermission;
//   final Position? currentPosition;
//   final bool isWithinRadius;
//   final double distanceToLocation;
//   final String? attendanceCode;
//
//   const HomePage({
//     super.key,
//     required this.user,
//     required this.onRefresh,
//     required this.onCheckIn,
//     required this.onCheckOut,
//     required this.locations,
//     required this.employeeLocations,
//     required this.isCheckingIn,
//     required this.isCheckedIn,
//     required this.timerText,
//     required this.hasPermission,
//     this.currentPosition,
//     required this.isWithinRadius,
//     required this.distanceToLocation,
//     this.attendanceCode,
//   });
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   Location? _selectedLocation;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.locations.isNotEmpty) {
//       final primary = widget.employeeLocations.firstWhere(
//             (el) => el.isPrimary,
//         orElse: () => widget.employeeLocations.isNotEmpty
//             ? widget.employeeLocations.first
//             : EmployeeLocation(
//           id: 0,
//           employeeId: '',
//           locationId: widget.locations.first.id,
//           locationName: widget.locations.first.locationName,
//           isPrimary: true,
//         ),
//       );
//       final matchedLocation = widget.locations.firstWhere(
//             (loc) => loc.id == primary.locationId,
//         orElse: () => widget.locations.first,
//       );
//       setState(() {
//         _selectedLocation = matchedLocation;
//       });
//     }
//   }
//
//   void _toggleCheckIn() {
//     if (widget.isCheckedIn) {
//       widget.onCheckOut();
//       return;
//     }
//
//     if (_selectedLocation == null) {
//       AppSnackBar.warning(context, '⚠️ Please select a location first');
//       return;
//     }
//
//     if (!widget.hasPermission) {
//       AppSnackBar.error(context, '⚠️ Location permission is required to check in');
//       return;
//     }
//
//     if (widget.currentPosition == null) {
//       AppSnackBar.warning(context, '⚠️ Please enable GPS to check in');
//       return;
//     }
//
//     if (!widget.isWithinRadius) {
//       AppSnackBar.error(
//         context,
//         '❌ You are too far from ${_selectedLocation?.locationName ?? "the location"}',
//         subtitle: 'Distance: ${widget.distanceToLocation.toStringAsFixed(0)}m — move closer to check in',
//         duration: const Duration(seconds: 4),
//       );
//       return;
//     }
//
//     widget.onCheckIn(_selectedLocation);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: widget.onRefresh,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ========== COMPACT PROFILE SECTION ==========
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: InkWell(
//                 onTap: () {
//                   final parent = context.findAncestorStateOfType<DashboardScreenState>();
//                   if (parent != null) {
//                     parent.changeTab(1);
//                   }
//                 },
//                 borderRadius: BorderRadius.circular(16),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               AppTheme.primaryColor,
//                               AppTheme.primaryColor.withOpacity(0.6),
//                             ],
//                           ),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(
//                             widget.user.employeeName.isNotEmpty
//                                 ? widget.user.employeeName[0].toUpperCase()
//                                 : '?',
//                             style: const TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 14),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.user.employeeName,
//                               style: const TextStyle(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppTheme.textPrimaryColor,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               'ID: ${widget.user.employeeId}',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                             if (widget.user.designation.isNotEmpty) ...[
//                               const SizedBox(height: 2),
//                               Text(
//                                 widget.user.designation,
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: AppTheme.primaryColor,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                       Icon(
//                         Icons.chevron_right,
//                         color: Colors.grey.shade400,
//                         size: 28,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // Welcome Text
//             Text(
//               'Hello, ${widget.user.employeeName.split(' ')[0]}!',
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: AppTheme.textPrimaryColor,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '${DateTime.now().toString().substring(0, 10)}',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // Location Permission Status
//             if (!widget.hasPermission)
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: Colors.orange.withOpacity(0.3),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.location_off, color: Colors.orange),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: const Text(
//                         'Location permission is required to check in',
//                         style: TextStyle(
//                           color: Colors.orange,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         final parent = context.findAncestorStateOfType<DashboardScreenState>();
//                         if (parent != null) {
//                           parent._checkLocationPermission();
//                         }
//                       },
//                       child: const Text('Allow'),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 16),
//
//             // ========== CHECK-IN / TIMER SECTION ==========
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppTheme.primaryColor,
//                     AppTheme.primaryColor.withOpacity(0.8),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     'Current Session',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     widget.timerText,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 48,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   // ===== LOCATION DROPDOWN =====
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: DropdownButton<Location>(
//                       value: _selectedLocation,
//                       isExpanded: true,
//                       dropdownColor: Colors.white,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                       ),
//                       underline: const SizedBox(),
//                       hint: const Text(
//                         'Select Location',
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                       items: widget.locations.map((location) {
//                         final isEmployeeLocation = widget.employeeLocations.any(
//                               (el) => el.locationId == location.id,
//                         );
//                         return DropdownMenuItem<Location>(
//                           value: location,
//                           enabled: isEmployeeLocation,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 isEmployeeLocation ? Icons.location_on : Icons.location_off,
//                                 color: isEmployeeLocation ? Colors.white70 : Colors.white38,
//                                 size: 18,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   location.locationName,
//                                   style: TextStyle(
//                                     color: isEmployeeLocation
//                                         ? AppTheme.textPrimaryColor
//                                         : Colors.grey.shade500,
//                                   ),
//                                 ),
//                               ),
//                               if (widget.employeeLocations.any(
//                                     (el) => el.locationId == location.id && el.isPrimary,
//                               ))
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 6,
//                                     vertical: 2,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: const Text(
//                                     'Primary',
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       color: Colors.green,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               if (!isEmployeeLocation)
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 6,
//                                     vertical: 2,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: const Text(
//                                     'Not Assigned',
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       color: Colors.grey,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: widget.isCheckedIn
//                           ? null
//                           : (value) {
//                         setState(() {
//                           _selectedLocation = value;
//                           final parent = context.findAncestorStateOfType<DashboardScreenState>();
//                           if (parent != null) {
//                             parent._checkIfWithinRadius();
//                           }
//                         });
//                       },
//                     ),
//                   ),
//
//                   // ===== LOCATION STATUS - REMOVED =====
//                   // The "Within radius" text has been removed
//
//                   const SizedBox(height: 16),
//
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: widget.isCheckedIn ||
//                               widget.isCheckingIn ||
//                               !widget.isWithinRadius
//                               ? null
//                               : _toggleCheckIn,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 14,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             disabledBackgroundColor: Colors.green
//                                 .withOpacity(0.3),
//                           ),
//                           child: widget.isCheckingIn
//                               ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                               : Text(
//                             widget.isCheckedIn
//                                 ? 'Checked In ✓'
//                                 : !widget.isWithinRadius
//                                 ? 'Out of Range'
//                                 : 'Check In',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: widget.isCheckedIn && !widget.isCheckingIn
//                               ? _toggleCheckIn
//                               : null,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 14,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             disabledBackgroundColor:
//                             Colors.red.withOpacity(0.3),
//                           ),
//                           child: const Text(
//                             'Check Out',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   // Status text - only show "Currently Checked In" or nothing
//                   if (widget.isCheckedIn)
//                     Text(
//                       '🟢 Currently Checked In',
//                       style: TextStyle(
//                         color: Colors.green.shade100,
//                         fontSize: 13,
//                       ),
//                     ),
//                   // REMOVED: "Ready to check in" and "Out of range - move closer" text
//
//                   if (_selectedLocation != null && widget.isCheckedIn)
//                     Text(
//                       '📍 ${_selectedLocation!.locationName}',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.6),
//                         fontSize: 12,
//                       ),
//                     ),
//                   // ===== ATTENDANCE CODE DISPLAY =====
//                   if (widget.attendanceCode != null && widget.isCheckedIn)
//                     Container(
//                       margin: const EdgeInsets.only(top: 8),
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.qr_code,
//                             color: Colors.white70,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Code: ${widget.attendanceCode}',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 12,
//                               fontFamily: 'monospace',
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (widget.currentPosition != null && !widget.isCheckedIn)
//                     Text(
//                       '📡 GPS: ${widget.currentPosition!.latitude.toStringAsFixed(6)}, ${widget.currentPosition!.longitude.toStringAsFixed(6)}',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.4),
//                         fontSize: 10,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Quick Stats
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildStatCard(
//                     '📊',
//                     'Today',
//                     'Present',
//                     Colors.green,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     '📅',
//                     'This Week',
//                     '5 Days',
//                     Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     '🏆',
//                     'Month',
//                     '18 Days',
//                     Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatCard(String icon, String label, String value, Color color) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             Text(icon, style: const TextStyle(fontSize: 20)),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_bar_widget.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'leave_screen.dart';
import 'setting_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  bool _isCheckedIn = false;
  bool _isLoading = false;
  String _timerText = '00:00:00';
  int _seconds = 0;
  late User _userData;
  bool _isLoadingProfile = true;
  String _profileError = '';
  int _selectedIndex = 0;

  // Attendance tracking
  String? _attendanceCode;

  // Location related
  List<Location> _locations = [];
  List<EmployeeLocation> _employeeLocations = [];
  Location? _selectedLocation;
  bool _isLoadingLocations = false;
  bool _isCheckingIn = false;
  bool _hasLocationPermission = false;
  Position? _currentPosition;
  bool _isWithinRadius = false;
  double _distanceToLocation = 0;

  // List of pages for bottom navigation
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _userData = widget.user;
    print('🔍 Dashboard initialized with user: ${_userData.employeeId}');
    _fetchUserProfile();
    _fetchEmployeeLocations();
    _checkLocationPermission();

    // Initialize pages with user data
    _pages = [
      HomePage(
        user: _userData,
        onRefresh: _fetchUserProfile,
        onCheckIn: _handleCheckIn,
        onCheckOut: _handleCheckOut,
        locations: _locations,
        employeeLocations: _employeeLocations,
        isCheckingIn: _isCheckingIn,
        isCheckedIn: _isCheckedIn,
        timerText: _timerText,
        hasPermission: _hasLocationPermission,
        currentPosition: _currentPosition,
        isWithinRadius: _isWithinRadius,
        distanceToLocation: _distanceToLocation,
        attendanceCode: _attendanceCode,
      ),
      ProfileScreen(user: _userData),
      LeaveScreen(user: _userData),
      SettingsScreen(user: _userData),
    ];
  }

  // ========== GENERATE ATTENDANCE CODE ==========
  String _generateAttendanceCode() {
    final random = (10000 + (DateTime.now().millisecondsSinceEpoch % 90000)).toString();
    return 'ATD-${_userData.employeeId}-$random';
  }

  // ========== GET FORMATTED CHECK-IN TIME ==========
  String _getFormattedCheckInTime() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  // ========== GET FORMATTED CHECK-OUT TIME ==========
  String _getFormattedCheckOutTime() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  // ========== CHECK LOCATION PERMISSION ==========
  Future<void> _checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      print('📍 Location Permission Status: $status');

      if (status.isGranted) {
        setState(() {
          _hasLocationPermission = true;
        });
        await _getCurrentLocation();
      } else if (status.isDenied) {
        final result = await Permission.location.request();
        setState(() {
          _hasLocationPermission = result.isGranted;
        });
        if (result.isGranted) {
          await _getCurrentLocation();
        } else {
          if (mounted) {
            _showPermissionDialog();
          }
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          _showSettingsDialog();
        }
      }

      _updateHomePage();
    } catch (e) {
      print('🔴 Error checking location permission: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 50,
              color: Colors.orange,
            ),
            SizedBox(height: 12),
            Text(
              'This app needs location access to verify your attendance location.\n\n'
                  'Please allow location permission to check-in at your assigned location.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkLocationPermission();
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Permission.location.request();
              setState(() {
                _hasLocationPermission = result.isGranted;
              });
              if (result.isGranted) {
                await _getCurrentLocation();
              }
              _updateHomePage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Allow Location'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is permanently denied. Please enable it from app settings.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkLocationPermission();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Location services are disabled');
        if (mounted) {
          AppSnackBar.warning(context, '⚠️ Please enable GPS/location services');
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });
      print('📍 Current Location: ${position.latitude}, ${position.longitude}');

      _checkIfWithinRadius();
    } catch (e) {
      print('🔴 Error getting location: $e');
    }
  }

  // ========== CHECK IF USER IS WITHIN RADIUS ==========
  void _checkIfWithinRadius() {
    if (_selectedLocation == null || _currentPosition == null) {
      setState(() {
        _isWithinRadius = false;
        _distanceToLocation = 0;
      });
      return;
    }

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _selectedLocation!.latitude,
      _selectedLocation!.longitude,
    );

    setState(() {
      _distanceToLocation = distance;
      _isWithinRadius = distance <= _selectedLocation!.radius;
    });

    print('📍 Distance to ${_selectedLocation!.locationName}: ${distance.toStringAsFixed(2)}m');
    print('📍 Within radius: $_isWithinRadius (Radius: ${_selectedLocation!.radius}m)');

    _updateHomePage();
  }

  Future<void> _fetchEmployeeLocations() async {
    try {
      setState(() {
        _isLoadingLocations = true;
      });

      final locationResponse = await _apiService.getLocations();

      if (locationResponse.success && locationResponse.locations.isNotEmpty) {
        setState(() {
          _locations = locationResponse.locations;
        });
        print('✅ Loaded ${_locations.length} locations from API');
      } else {
        print('⚠️ No locations from API, using sample data');
        _addSampleLocations();
        setState(() {
          _isLoadingLocations = false;
        });
        _updateHomePage();
        return;
      }

      final employeeResponse = await _apiService.getEmployeeLocations(
        employeeId: _userData.employeeId,
      );

      if (employeeResponse.success && employeeResponse.employeeLocations.isNotEmpty) {
        setState(() {
          _employeeLocations = employeeResponse.employeeLocations;
          final primary = _employeeLocations.firstWhere(
                (el) => el.isPrimary,
            orElse: () => _employeeLocations.first,
          );
          final matchedLocation = _locations.firstWhere(
                (loc) => loc.id == primary.locationId,
            orElse: () => _locations.first,
          );
          _selectedLocation = matchedLocation;
          _isLoadingLocations = false;
        });
        print('✅ Loaded ${_employeeLocations.length} employee locations');
      } else {
        setState(() {
          _employeeLocations = _locations.map((loc) => EmployeeLocation(
            id: loc.id,
            employeeId: _userData.employeeId,
            locationId: loc.id,
            locationName: loc.locationName,
            isPrimary: loc.id == 1,
          )).toList();
          _selectedLocation = _locations.first;
          _isLoadingLocations = false;
        });
        print('⚠️ No employee locations, using all locations');
      }

      _checkIfWithinRadius();
      _updateHomePage();
    } catch (e) {
      print('🔴 Error fetching locations: $e');
      _addSampleLocations();
      _updateHomePage();
    }
  }

  void _addSampleLocations() {
    setState(() {
      _locations = [
        Location(
          id: 1,
          locationName: 'MetaXperts Office',
          latitude: 32.5011987,
          longitude: 74.4976395,
          radius: 100,
        ),
        Location(
          id: 2,
          locationName: 'Model Town, Sialkot',
          latitude: 32.5012163,
          longitude: 74.5214267,
          radius: 100,
        ),
        Location(
          id: 3,
          locationName: 'Sialkot Clock Tower',
          latitude: 32.5161556,
          longitude: 74.5564577,
          radius: 100,
        ),
      ];

      _employeeLocations = [
        EmployeeLocation(
          id: 1,
          employeeId: _userData.employeeId,
          locationId: 1,
          locationName: 'MetaXperts Office',
          isPrimary: true,
        ),
        EmployeeLocation(
          id: 2,
          employeeId: _userData.employeeId,
          locationId: 2,
          locationName: 'Model Town, Sialkot',
          isPrimary: false,
        ),
        EmployeeLocation(
          id: 3,
          employeeId: _userData.employeeId,
          locationId: 3,
          locationName: 'Sialkot Clock Tower',
          isPrimary: false,
        ),
      ];

      _selectedLocation = _locations.first;
      _isLoadingLocations = false;
      _checkIfWithinRadius();

      print('✅ Added sample locations for testing');
    });
  }

  void _updateHomePage() {
    _pages[0] = HomePage(
      user: _userData,
      onRefresh: _fetchUserProfile,
      onCheckIn: _handleCheckIn,
      onCheckOut: _handleCheckOut,
      locations: _locations,
      employeeLocations: _employeeLocations,
      isCheckingIn: _isCheckingIn,
      isCheckedIn: _isCheckedIn,
      timerText: _timerText,
      hasPermission: _hasLocationPermission,
      currentPosition: _currentPosition,
      isWithinRadius: _isWithinRadius,
      distanceToLocation: _distanceToLocation,
      attendanceCode: _attendanceCode,
    );
  }

  // ========== HANDLE CHECK-IN ==========
  Future<void> _handleCheckIn(Location? selectedLocation) async {
    if (selectedLocation == null) {
      AppSnackBar.warning(context, '⚠️ Please select a location first');
      return;
    }

    // ========== CHECK LOCATION PERMISSION ==========
    if (!_hasLocationPermission) {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        if (mounted) {
          AppSnackBar.error(context, '⚠️ Location permission is required to check in');
        }
        return;
      }
      setState(() {
        _hasLocationPermission = true;
      });
    }

    // ========== GET CURRENT LOCATION ==========
    final position = await _getCurrentPosition();
    if (position == null) {
      if (mounted) {
        AppSnackBar.warning(context, '⚠️ Unable to get your current location. Please enable GPS.');
      }
      return;
    }

    // ========== CHECK IF WITHIN RADIUS ==========
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      selectedLocation.latitude,
      selectedLocation.longitude,
    );

    print('📍 Distance to ${selectedLocation.locationName}: ${distance.toStringAsFixed(2)}m');

    setState(() {
      _currentPosition = position;
      _distanceToLocation = distance;
      _isWithinRadius = distance <= selectedLocation.radius;
    });

    if (distance > selectedLocation.radius) {
      if (mounted) {
        AppSnackBar.error(
          context,
          '❌ You are too far from ${selectedLocation.locationName}',
          subtitle: 'Distance: ${distance.toStringAsFixed(0)}m (Max: ${selectedLocation.radius.toStringAsFixed(0)}m) — check-in blocked',
          duration: const Duration(seconds: 4),
        );
      }
      _updateHomePage();
      return;
    }

    // ========== PROCEED WITH CHECK-IN ==========
    setState(() {
      _isCheckingIn = true;
    });

    try {
      final attendanceCode = _generateAttendanceCode();
      final checkInTime = _getFormattedCheckInTime();

      final response = await _apiService.checkIn(
        attendanceCode: attendanceCode,
        employeeId: _userData.employeeId,
        employeeName: _userData.employeeName,
        designation: _userData.designation,
        locationName: selectedLocation.locationName,
        checkInTime: checkInTime,
      );

      if (!mounted) return;

      if (response['success']) {
        final code = response['attendance_code'] ?? attendanceCode;

        setState(() {
          _isCheckingIn = false;
          _isCheckedIn = true;
          _selectedLocation = selectedLocation;
          _attendanceCode = code;
        });
        _startTimer();
        _updateHomePage();

        AppSnackBar.success(
          context,
          '✅ Checked In Successfully!',
          subtitle: '📋 $code · ⏰ $checkInTime',
        );
      } else {
        setState(() {
          _isCheckingIn = false;
        });
        AppSnackBar.error(
          context,
          '❌ Check-in failed',
          subtitle: response['message'] ?? 'Please try again',
        );
      }
    } catch (e) {
      setState(() {
        _isCheckingIn = false;
      });
      AppSnackBar.error(
        context,
        '❌ Check-in failed',
        subtitle: e.toString(),
      );
    }
  }

  // ========== HANDLE CHECK-OUT ==========
  Future<void> _handleCheckOut() async {
    if (_attendanceCode == null || _attendanceCode!.isEmpty) {
      AppSnackBar.error(context, '❌ No active check-in found');
      return;
    }

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final checkOutTime = _getFormattedCheckOutTime();

      final response = await _apiService.checkOut(
        attendanceCode: _attendanceCode!,
        checkOutTime: checkOutTime,
      );

      if (!mounted) return;

      if (response['success']) {
        final code = _attendanceCode;
        _stopTimer();
        setState(() {
          _isCheckingIn = false;
          _isCheckedIn = false;
          _attendanceCode = null;
          _seconds = 0;
          _timerText = '00:00:00';
          _checkIfWithinRadius();
        });
        _updateHomePage();

        AppSnackBar.success(
          context,
          '✅ Checked Out Successfully!',
          subtitle: '📋 $code · ⏰ $checkOutTime · Total: ${response['totalTime'] ?? 'N/A'}',
        );
      } else {
        setState(() {
          _isCheckingIn = false;
        });
        AppSnackBar.error(
          context,
          '❌ Check-out failed',
          subtitle: response['message'] ?? 'Please try again',
        );
      }
    } catch (e) {
      setState(() {
        _isCheckingIn = false;
      });
      AppSnackBar.error(
        context,
        '❌ Check-out failed',
        subtitle: e.toString(),
      );
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('🔴 Error getting location: $e');
      return null;
    }
  }

  void _startTimer() {
    _seconds = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isCheckedIn) return false;
      setState(() {
        _seconds++;
        _timerText = _formatTime(_seconds);
        _updateHomePage();
      });
      return true;
    });
  }

  void _stopTimer() {
    setState(() {
      _seconds = 0;
      _timerText = '00:00:00';
      _isCheckedIn = false;
    });
  }

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchUserProfile() async {
    try {
      setState(() {
        _isLoadingProfile = true;
        _profileError = '';
      });

      String employeeId = _userData.employeeId.trim();

      if (employeeId.isEmpty) {
        setState(() {
          _isLoadingProfile = false;
          _profileError = 'Employee ID is empty. Please login again.';
        });
        if (mounted) {
          AppSnackBar.error(context, '⚠️ Employee ID is empty. Please login again.');
        }
        return;
      }

      final response = await _apiService.getProfile(
        employeeId: employeeId,
      );

      if (response.success && response.user != null) {
        setState(() {
          _userData = User(
            id: _userData.id,
            employeeId: _userData.employeeId,
            employeeName: response.user!.employeeName.isNotEmpty
                ? response.user!.employeeName
                : _userData.employeeName,
            shiftStartTime: response.user!.shiftStartTime.isNotEmpty
                ? response.user!.shiftStartTime
                : _userData.shiftStartTime,
            shiftEndTime: response.user!.shiftEndTime.isNotEmpty
                ? response.user!.shiftEndTime
                : _userData.shiftEndTime,
            fatherName: response.user!.fatherName,
            designation: response.user!.designation,
            phoneNumber: response.user!.phoneNumber,
            email: response.user!.email,
          );
          _isLoadingProfile = false;

          _pages[0] = HomePage(
            user: _userData,
            onRefresh: _fetchUserProfile,
            onCheckIn: _handleCheckIn,
            onCheckOut: _handleCheckOut,
            locations: _locations,
            employeeLocations: _employeeLocations,
            isCheckingIn: _isCheckingIn,
            isCheckedIn: _isCheckedIn,
            timerText: _timerText,
            hasPermission: _hasLocationPermission,
            currentPosition: _currentPosition,
            isWithinRadius: _isWithinRadius,
            distanceToLocation: _distanceToLocation,
            attendanceCode: _attendanceCode,
          );
          _pages[1] = ProfileScreen(user: _userData);
          _pages[2] = LeaveScreen(user: _userData);
          _pages[3] = SettingsScreen(user: _userData);
        });

        if (mounted) {
          AppSnackBar.success(context, '✅ Profile loaded successfully!');
        }
      } else {
        setState(() {
          _isLoadingProfile = false;
          _profileError = 'Additional profile details not available.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
        _profileError = e.toString();
      });
      print('🔴 Profile Error: $e');
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await SessionService.clearSession();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Attendance Pro',
        onMenuPressed: () {
          Scaffold.of(context).openDrawer();
        },
        onNotificationsPressed: () {
          AppSnackBar.info(context, 'No new notifications');
        },
        onRefreshPressed: _fetchUserProfile,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _userData.employeeName.isNotEmpty
                            ? _userData.employeeName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userData.employeeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${_userData.employeeId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  if (_userData.designation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _userData.designation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '● Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildDrawerItem(
              Icons.home_outlined,
              'Home',
                  () {
                Navigator.pop(context);
                changeTab(0);
              },
            ),
            _buildDrawerItem(
              Icons.fingerprint_outlined,
              'Mark Attendance',
                  () {
                Navigator.pop(context);
                changeTab(0);
              },
            ),
            _buildDrawerItem(
              Icons.history_outlined,
              'History',
                  () {
                Navigator.pop(context);
                AppSnackBar.info(context, 'History coming soon');
              },
            ),
            const Spacer(),
            const Divider(),
            _buildDrawerItem(
              Icons.person_outline,
              'Profile',
                  () {
                Navigator.pop(context);
                changeTab(1);
              },
              color: AppTheme.primaryColor,
            ),
            _buildDrawerItem(
              Icons.settings_outlined,
              'Settings',
                  () {
                Navigator.pop(context);
                changeTab(3);
              },
            ),
            _buildDrawerItem(
              Icons.logout,
              'Logout',
                  () {
                Navigator.pop(context);
                _logout();
              },
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoadingProfile
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Loading profile...',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      )
          : _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          changeTab(index);
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
            label: 'Leave',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      IconData icon,
      String title,
      VoidCallback onTap, {
        Color? color,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: color ?? AppTheme.textPrimaryColor,
          fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// ====================================================================
// ========== HOME PAGE (Embedded) ==========
// ====================================================================
class HomePage extends StatefulWidget {
  final User user;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Location? selectedLocation) onCheckIn;
  final VoidCallback onCheckOut;
  final List<Location> locations;
  final List<EmployeeLocation> employeeLocations;
  final bool isCheckingIn;
  final bool isCheckedIn;
  final String timerText;
  final bool hasPermission;
  final Position? currentPosition;
  final bool isWithinRadius;
  final double distanceToLocation;
  final String? attendanceCode;

  const HomePage({
    super.key,
    required this.user,
    required this.onRefresh,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.locations,
    required this.employeeLocations,
    required this.isCheckingIn,
    required this.isCheckedIn,
    required this.timerText,
    required this.hasPermission,
    this.currentPosition,
    required this.isWithinRadius,
    required this.distanceToLocation,
    this.attendanceCode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Location? _selectedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.locations.isNotEmpty) {
      final primary = widget.employeeLocations.firstWhere(
            (el) => el.isPrimary,
        orElse: () => widget.employeeLocations.isNotEmpty
            ? widget.employeeLocations.first
            : EmployeeLocation(
          id: 0,
          employeeId: '',
          locationId: widget.locations.first.id,
          locationName: widget.locations.first.locationName,
          isPrimary: true,
        ),
      );
      final matchedLocation = widget.locations.firstWhere(
            (loc) => loc.id == primary.locationId,
        orElse: () => widget.locations.first,
      );
      setState(() {
        _selectedLocation = matchedLocation;
      });
    }
  }

  void _toggleCheckIn() {
    if (widget.isCheckedIn) {
      widget.onCheckOut();
      return;
    }

    if (_selectedLocation == null) {
      AppSnackBar.warning(context, '⚠️ Please select a location first');
      return;
    }

    if (!widget.hasPermission) {
      AppSnackBar.error(context, '⚠️ Location permission is required to check in');
      return;
    }

    if (widget.currentPosition == null) {
      AppSnackBar.warning(context, '⚠️ Please enable GPS to check in');
      return;
    }

    if (!widget.isWithinRadius) {
      AppSnackBar.error(
        context,
        '❌ You are too far from ${_selectedLocation?.locationName ?? "the location"}',
        subtitle: 'Distance: ${widget.distanceToLocation.toStringAsFixed(0)}m — move closer to check in',
        duration: const Duration(seconds: 4),
      );
      return;
    }

    widget.onCheckIn(_selectedLocation);
  }

  void _navigateToLeave() {
    final parent = context.findAncestorStateOfType<DashboardScreenState>();
    if (parent != null) {
      parent.changeTab(2); // Leave tab index
    }
  }

  void _navigateToTasks() {
    AppSnackBar.info(context, '📋 Tasks feature coming soon!');
  }

  void _navigateToComplaints() {
    AppSnackBar.info(context, '📝 Complaints feature coming soon!');
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== WELCOME TEXT ==========
            Text(
              'Hello, ${widget.user.employeeName.split(' ')[0]}!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Welcome to Attendance Pro',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // ========== COMPACT PROFILE SECTION ==========
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  final parent = context.findAncestorStateOfType<DashboardScreenState>();
                  if (parent != null) {
                    parent.changeTab(1);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Left side: Name, ID, Designation
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.employeeName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${widget.user.employeeId}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (widget.user.designation.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.user.designation,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Right side: Avatar with edit icon
                      Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryColor.withOpacity(0.6),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                widget.user.employeeName.isNotEmpty
                                    ? widget.user.employeeName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 12,
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
            const SizedBox(height: 20),

            // Location Permission Status
            if (!widget.hasPermission)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: const Text(
                        'Location permission is required to check in',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final parent = context.findAncestorStateOfType<DashboardScreenState>();
                        if (parent != null) {
                          parent._checkLocationPermission();
                        }
                      },
                      child: const Text('Allow'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // ========== CHECK-IN / TIMER SECTION ==========
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Current Session',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.timerText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== LOCATION DROPDOWN =====
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<Location>(
                      value: _selectedLocation,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      underline: const SizedBox(),
                      hint: const Text(
                        'Select Location',
                        style: TextStyle(color: Colors.white70),
                      ),
                      items: widget.locations.map((location) {
                        final isEmployeeLocation = widget.employeeLocations.any(
                              (el) => el.locationId == location.id,
                        );
                        return DropdownMenuItem<Location>(
                          value: location,
                          enabled: isEmployeeLocation,
                          child: Row(
                            children: [
                              Icon(
                                isEmployeeLocation ? Icons.location_on : Icons.location_off,
                                color: isEmployeeLocation ? Colors.white70 : Colors.white38,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  location.locationName,
                                  style: TextStyle(
                                    color: isEmployeeLocation
                                        ? AppTheme.textPrimaryColor
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ),
                              if (widget.employeeLocations.any(
                                    (el) => el.locationId == location.id && el.isPrimary,
                              ))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Primary',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (!isEmployeeLocation)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Not Assigned',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: widget.isCheckedIn
                          ? null
                          : (value) {
                        setState(() {
                          _selectedLocation = value;
                          final parent = context.findAncestorStateOfType<DashboardScreenState>();
                          if (parent != null) {
                            parent._checkIfWithinRadius();
                          }
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.isCheckedIn ||
                              widget.isCheckingIn ||
                              !widget.isWithinRadius
                              ? null
                              : _toggleCheckIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.green
                                .withOpacity(0.3),
                          ),
                          child: widget.isCheckingIn
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            widget.isCheckedIn
                                ? 'Checked In ✓'
                                : !widget.isWithinRadius
                                ? 'Out of Range'
                                : 'Check In',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.isCheckedIn && !widget.isCheckingIn
                              ? _toggleCheckIn
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor:
                            Colors.red.withOpacity(0.3),
                          ),
                          child: const Text(
                            'Check Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.isCheckedIn)
                    Text(
                      '🟢 Currently Checked In',
                      style: TextStyle(
                        color: Colors.green.shade100,
                        fontSize: 13,
                      ),
                    ),

                  if (_selectedLocation != null && widget.isCheckedIn)
                    Text(
                      '📍 ${_selectedLocation!.locationName}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  // ===== ATTENDANCE CODE DISPLAY =====
                  if (widget.attendanceCode != null && widget.isCheckedIn)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Code: ${widget.attendanceCode}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.currentPosition != null && !widget.isCheckedIn)
                    Text(
                      '📡 GPS: ${widget.currentPosition!.latitude.toStringAsFixed(6)}, ${widget.currentPosition!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ========== QUICK ACTIONS ==========
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.event_note_outlined,
                    label: 'Leave',
                    color: Colors.blue,
                    onTap: _navigateToLeave,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.task_outlined,
                    label: 'Tasks',
                    color: Colors.orange,
                    onTap: _navigateToTasks,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.feedback_outlined,
                    label: 'Complaints',
                    color: Colors.red,
                    onTap: _navigateToComplaints,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String icon, String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}