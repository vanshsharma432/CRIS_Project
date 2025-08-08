import 'package:dashboard_final/widgets/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/API.dart';
import '../constants/strings.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class QuotaCheckPage extends StatefulWidget {
  final String accessToken;
  const QuotaCheckPage({required this.accessToken, super.key});

  @override
  State<QuotaCheckPage> createState() => _QuotaCheckPageState();
}

class _QuotaCheckPageState extends State<QuotaCheckPage> {
  String? pnrErrorMessage;
  final TextEditingController _pnrController = TextEditingController();
  Map<int, String?> passengerNameErrors = {};
  bool showQuotaReport = false;
  bool showError = false;
  bool isLoading = false;
  int? selectedPriority;
  Map<int, String?> passengerRelationships = {};
  Map<int, TextEditingController> passengerNameControllers = {};

  Map<String, dynamic>? currentPNRData;
  OverlayEntry? _overlayEntry;
  bool _hasAnyInvalidPassengerName() {
    bool hasError = false;
    if (currentPNRData == null) return false;

    final passengers = currentPNRData!['passengers'] as List;

    for (int i = 0; i < passengers.length; i++) {
      final expected = passengers[i]['name'].toString().trim().toLowerCase();
      final entered =
          passengerNameControllers[i]?.text.trim().toLowerCase() ?? '';

      if (entered.isEmpty || entered != expected) {
        passengerNameErrors[i] = 'Name does not match with PNR';
        hasError = true;
      } else {
        passengerNameErrors.remove(i); // Clear if corrected
      }
    }

    setState(() {}); // Update error messages in UI
    return hasError;
  }

  Future<void> checkPNR() async {
    String pnr = _pnrController.text.trim();
    if (pnr.isEmpty) {
      setState(() {
        pnrErrorMessage = 'Please enter a PNR number';
        showError = true;
        isLoading = false;
        showQuotaReport = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      showQuotaReport = false;
      showError = false;
      pnrErrorMessage = null;
      currentPNRData = null;
    });

    try {
      final pnrData = await QuotaService.fetchPNRStatus(
        accessToken: widget.accessToken,
        pnrNumber: pnr,
      );

      if (pnrData == null || pnrData['pnrNumber'] == null) {
        setState(() {
          pnrErrorMessage = 'PNR not found';
          showError = true;
          showQuotaReport = false;
          isLoading = false;
        });
        return;
      }

      // Check for CAN status
      bool isCancelled = (pnrData['passengerList'] as List).any(
        (passenger) =>
            (passenger['currentStatus'] ?? '').toString().toUpperCase() ==
            'CAN',
      );

      if (isCancelled) {
        setState(() {
          pnrErrorMessage = 'Your PNR request has been cancelled';
          showError = true;
          showQuotaReport = false;
          isLoading = false;
        });
        return;
      }
      setState(() {
        currentPNRData = {
          'pnr': pnrData['pnrNumber'] ?? '',
          'trainName': pnrData['trainName'] ?? '',
          'trainNumber': pnrData['trainNumber'] ?? '',
          'dateOfJourney': pnrData['dateOfJourney'] ?? '',
          'passengers': (pnrData['passengerList'] as List)
              .map(
                (passenger) => {
                  'sNo': passenger['passengerSerialNumber'],
                  'name': passenger['passengerName'],
                  'age': passenger['passengerAge'],
                  'gender': passenger['passengerGender'],
                  'bookingStatus': passenger['bookingStatusDetails'],
                  'currentStatus': passenger['currentStatusDetails'],
                },
              )
              .toList(),
        };
        showQuotaReport = true;
        showError = false;
        isLoading = false;
        passengerRelationships.clear();
        passengerNameControllers.clear();
        passengerNameErrors.clear();
        for (int i = 0; i < currentPNRData!['passengers'].length; i++) {
          passengerRelationships[i] = null;
          passengerNameControllers[i] = TextEditingController();
        }
      });

      _showErrorMessage('PNR details fetched successfully!', success: true);
    } catch (e) {
      setState(() {
        showError = true;
        pnrErrorMessage = 'Something went wrong: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message, {bool success = false}) {
    final isMobile =
        MediaQuery.of(context).size.width < AppConstants.mobileWidthBreakpoint;
    if (isMobile) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? AColors.success : AColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _showTopRightError(message, success: success);
    }
  }

  void _showTopRightError(String msg, {bool success = false}) {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40,
        right: 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: success ? AColors.success : AColors.error,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AColors.shadow,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: AColors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    msg,
                    style: ATextStyles.bodyBold.copyWith(color: AColors.white),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _removeOverlay,
                  child: const Icon(
                    Icons.close,
                    color: AColors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 5), _removeOverlay);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> submitQuotaRequest() async {
    if (currentPNRData == null) return;
    final List<Map<String, dynamic>> passengerList = [];
    final passengers = currentPNRData!['passengers'] as List;
    for (int i = 0; i < passengers.length; i++) {
      passengerList.add({
        "passengerSerialNumber": passengers[i]['sNo'],
        "relation": passengerRelationships[i] ?? "",
        "name": passengerNameControllers[i]?.text ?? "",
      });
    }
    try {
      final msg = await QuotaService.submitQuotaRequest(
        accessToken: widget.accessToken,
        pnr: currentPNRData!['pnr'],
        priority: selectedPriority,
        passengerList: passengerList,
      );
      _showErrorMessage(msg, success: true);
      _resetForm();
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

  void applyQuota() {
    if (currentPNRData == null || showError) return;

    if (_hasAnyInvalidPassengerName()) {
      _showTopRightError("Incorrect passenger name");
      return;
    }

    bool allRelationshipsSelected = true;
    for (int i = 0; i < currentPNRData!['passengers'].length; i++) {
      if (passengerRelationships[i] == null) {
        allRelationshipsSelected = false;
        break;
      }
    }

    if (!allRelationshipsSelected || selectedPriority == null) {
      _showErrorMessage(
        'Please select relationship for all passengers and priority',
      );
      return;
    }

    submitQuotaRequest();
  }

  void _resetForm() {
    setState(() {
      _pnrController.clear();
      showQuotaReport = false;
      showError = false;
      isLoading = false;
      selectedPriority = null;
      passengerRelationships.clear();
      passengerNameControllers.clear();
      currentPNRData = null;
    });
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      DateTime dt = DateTime.parse(date);
      return DateFormat('dd MMM yyyy, h:mm a').format(dt);
    } catch (e) {
      return date;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width > AppConstants.wideWidthBreakpoint;

    return Scaffold(
      backgroundColor: AColors.betterLightBlue,
      appBar: AppBar(
        title: Text('PNR Status', style: ATextStyles.headingMedium),
        centerTitle: true,
        backgroundColor: AColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AColors.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Clear saved token (if using SharedPreferences)
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');

              // Navigate to LoginScreen, replacing entire stack
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 900 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.all(isWide ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPNRInputCard(),
                  if (isLoading) ...[
                    const SizedBox(height: 24),
                    _buildLoadingCard(),
                  ],
                  if (showQuotaReport &&
                      currentPNRData != null &&
                      !showError) ...[
                    const SizedBox(height: 24),
                    _buildMainContentCard(isWide),
                  ],
                  if (showError && !isLoading) ...[
                    const SizedBox(height: 24),
                    _buildErrorCard(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AColors.primary),
          ),
          const SizedBox(height: 16),
          Text('Fetching PNR Details...', style: ATextStyles.bodyText),
          const SizedBox(height: 8),
          Text(
            'Please wait while we retrieve your ticket information',
            textAlign: TextAlign.center,
            style: ATextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPNRInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PNR Number', style: ATextStyles.headingMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _pnrController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'Enter 10 digit PNR',
                    counterText: '',
                    prefixIcon: Icon(
                      Icons.confirmation_number,
                      color: AColors.primary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ), // ✅ Added
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AColors.white,
                  ),

                  style: ATextStyles.bodyText,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isLoading ? null : checkPNR,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AColors.primary,
                  foregroundColor: AColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  textStyle: ATextStyles.buttonText,
                ),
                child: Text(
                  isLoading ? 'Checking...' : 'Check PNR',
                  style: ATextStyles.buttonText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AColors.error, size: 60),
          const SizedBox(height: 16),
          Text(
            pnrErrorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: ATextStyles.headingMedium.copyWith(color: AColors.error),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showError = false;
                pnrErrorMessage = null;
                _pnrController.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AColors.primary,
              foregroundColor: AColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: ATextStyles.buttonText,
            ),
            child: const Text('Try Again', style: ATextStyles.buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentCard(bool isWide) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuotaReportSection(isWide),
          const SizedBox(height: 32),
          _buildPassengerDetailsSection(isWide),
          const SizedBox(height: 32),
          _buildRequestDetailsSection(isWide),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedBox(width: 220, child: _buildApplyButton())],
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaReportSection(bool isWide) {
    if (currentPNRData == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AColors.betterLightBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AColors.borderLight),
                ),
                child: Row(
                  children: [
                    Icon(Icons.train, color: AColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Train Name", style: ATextStyles.labelText),
                          Text(
                            currentPNRData!['trainName'],
                            style: ATextStyles.cardTitle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.numbers, color: AColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Train Number", style: ATextStyles.labelText),
                        Text(
                          currentPNRData!['trainNumber'],
                          style: ATextStyles.cardTitle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AColors.betterLightBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AColors.borderLight),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date of Journey", style: ATextStyles.labelText),
                        Text(
                          _formatDate(currentPNRData!['dateOfJourney']),
                          style: ATextStyles.cardTitle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _validatePassengerName(int index) {
    if (currentPNRData == null) return;

    final expectedName = currentPNRData!['passengers'][index]['name']
        .toString()
        .trim()
        .toLowerCase();

    final controller = passengerNameControllers[index];
    if (controller == null) return;

    final enteredName = controller.text.trim().toLowerCase();

    setState(() {
      if (enteredName.isEmpty || enteredName == expectedName) {
        passengerNameErrors[index] = null;
      } else {
        passengerNameErrors[index] = 'Name does not match with PNR';
      }
    });
  }

  Widget _buildPassengerDetailsSection(bool isWide) {
    if (currentPNRData == null) return const SizedBox();
    final passengers = currentPNRData!['passengers'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people, color: AColors.primary, size: 24),
            const SizedBox(width: 12),
            Text('Passenger Details', style: ATextStyles.headingMedium),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(passengers.length, (i) {
          final passenger = passengers[i];
          if (passengerNameControllers[i] != null &&
              !passengerNameControllers[i]!.hasListeners) {
            passengerNameControllers[i]!.addListener(() {
              _validatePassengerName(i);
            });
          }
          return Card(
            color: AColors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: passengerNameControllers[i],
                          onChanged: (_) => _validatePassengerName(i),
                          decoration: InputDecoration(
                            hintText: "Enter Passenger Name",
                            border: const UnderlineInputBorder(),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: AColors.primary),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            fillColor: AColors.white,
                            filled: true,
                            errorText: passengerNameErrors[i],
                          ),
                          style: ATextStyles.passengerValue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        " (${passenger['age']} ${passenger['gender']})",
                        style: ATextStyles.passengerLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      value: passengerRelationships[i],
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AColors.primary),
                        ),
                      ),
                      hint: const Text('Relationship'),
                      items: AppConstants.relationshipOptions
                          .map(
                            (rel) => DropdownMenuItem(
                              value: rel,
                              child: Text(rel, style: ATextStyles.bodyText),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          passengerRelationships[i] = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRequestDetailsSection(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.priority_high, color: AColors.primary, size: 24),
            const SizedBox(width: 12),
            Text('Request Details', style: ATextStyles.headingMedium),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: selectedPriority,
          hint: const Text('Select Priority'),
          items: AppConstants.priorityOptions
              .map(
                (option) => DropdownMenuItem<int>(
                  value: option['value'],
                  child: Text(option['label'], style: ATextStyles.bodyText),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedPriority = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return ElevatedButton(
      onPressed: (currentPNRData == null || showError) ? null : applyQuota,
      style: ElevatedButton.styleFrom(
        backgroundColor: AColors.primary,
        foregroundColor: AColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: ATextStyles.buttonText,
      ),
      child: const Text('Apply Quota', style: ATextStyles.buttonText),
    );
  }
}
