import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snackbar.dart';

class LeaveScreen extends StatefulWidget {
  final User user;

  const LeaveScreen({super.key, required this.user});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String _selectedLeaveType = 'Annual Leave';
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedEndDate;

  final List<String> _leaveTypes = [
    'Annual Leave',
    'Sick Leave',
    'Casual Leave',
    'Emergency Leave',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leave Application',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== HEADER ==========
              const Text(
                'Apply for Leave',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Submit your leave request',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // ========== EMPLOYEE INFO CARD ==========
              _buildSectionCard(
                title: 'Employee Information',
                icon: Icons.person_outline,
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.badge_outlined,
                      label: 'Employee Name',
                      value: widget.user.employeeName,
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Employee ID',
                      value: widget.user.employeeId,
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.work_outline,
                      label: 'Designation',
                      value: widget.user.designation.isNotEmpty
                          ? widget.user.designation
                          : 'Not Available',
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.access_time_outlined,
                      label: 'Shift Timing',
                      value: widget.user.shiftStartTime.isNotEmpty &&
                          widget.user.shiftEndTime.isNotEmpty
                          ? '${widget.user.shiftStartTime} - ${widget.user.shiftEndTime}'
                          : 'Not Available',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ========== LEAVE BALANCE CARD ==========
              _buildSectionCard(
                title: 'Leave Balance',
                icon: Icons.event_note_outlined,
                child: Row(
                  children: [
                    _buildBalanceItem(
                      icon: Icons.beach_access,
                      label: 'Annual',
                      value: '12',
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildBalanceItem(
                      icon: Icons.health_and_safety,
                      label: 'Sick',
                      value: '8',
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildBalanceItem(
                      icon: Icons.celebration,
                      label: 'Casual',
                      value: '5',
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildBalanceItem(
                      icon: Icons.warning_amber,
                      label: 'Emergency',
                      value: '3',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ========== LEAVE APPLICATION FORM ==========
              _buildSectionCard(
                title: 'Leave Request Form',
                icon: Icons.edit_note_outlined,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Leave Type
                      DropdownButtonFormField<String>(
                        value: _selectedLeaveType,
                        decoration: InputDecoration(
                          labelText: 'Leave Type',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                        ),
                        items: _leaveTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLeaveType = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select leave type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Start Date
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            prefixIcon: Icon(
                              Icons.calendar_today_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                          ),
                          child: Text(
                            '${_selectedDate.toString().substring(0, 10)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // End Date
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedEndDate ?? _selectedDate.add(
                              const Duration(days: 1),
                            ),
                            firstDate: _selectedDate,
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedEndDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            prefixIcon: Icon(
                              Icons.calendar_today_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                          ),
                          child: Text(
                            _selectedEndDate != null
                                ? '${_selectedEndDate!.toString().substring(0, 10)}'
                                : 'Select end date',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedEndDate != null
                                  ? AppTheme.textPrimaryColor
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reason
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Reason',
                          hintText: 'Enter reason for leave...',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(
                            Icons.description_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a reason';
                          }
                          if (value.length < 5) {
                            return 'Reason must be at least 5 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _submitLeave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'Submit Leave Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ========== VERSION ==========
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ========== SECTION CARD WIDGET ==========
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  // ========== INFO TILE WIDGET ==========
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: value != 'Not Available'
                    ? AppTheme.textPrimaryColor
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== DIVIDER WIDGET ==========
  Widget _buildDivider() {
    return Divider(
      height: 2,
      color: Colors.grey.shade200,
    );
  }

  // ========== BALANCE ITEM WIDGET ==========
  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitLeave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedEndDate == null) {
        AppSnackBar.warning(context, '⚠️ Please select an end date');
        return;
      }

      if (_selectedEndDate!.isBefore(_selectedDate)) {
        AppSnackBar.error(context, '❌ End date must be after start date');
        return;
      }

      // Calculate number of days
      final days = _selectedEndDate!.difference(_selectedDate).inDays + 1;

      AppSnackBar.success(
        context,
        '✅ Leave request submitted successfully!',
        subtitle: '📋 $_selectedLeaveType · $days day(s)',
      );
      _reasonController.clear();
      _selectedEndDate = null;
      setState(() {});
    }
  }
}