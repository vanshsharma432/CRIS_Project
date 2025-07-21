//lib/widgets/login.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/API.dart';
import 'pnr.dart';
import '../constants/strings.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/filter_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < AppConstants.mobileWidthBreakpoint;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isMobile)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AColors.primary, AColors.paleCyan, AColors.white],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            )
          else
            Image.asset(AppConstants.backgroundImage, fit: BoxFit.cover),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Image.asset(
                      AppConstants.logoImage,
                      height: 90,
                      errorBuilder: (c, e, s) => const SizedBox(height: 90),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: const LoginBox(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginBox extends StatefulWidget {
  const LoginBox({super.key});
  @override
  State<LoginBox> createState() => _LoginBoxState();
}

class _LoginBoxState extends State<LoginBox> {
  final _idController = TextEditingController();
  final _captchaController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpDisabled = false;
  int _seconds = 0;
  Timer? _timer;
  Uint8List? _captchaImage;
  String _captchaUUID = '';
  bool isMobileLogin = true;

  String? _idError, _otpError, _captchaError;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadCaptcha();
  }

  Future<void> _loadCaptcha() async {
    try {
      final data = await AuthService.fetchCaptcha();
      setState(() {
        _captchaImage = data['captchaImage'];
        _captchaUUID = data['uuid'];
      });
    } catch (e) {
      _showError("Failed to load captcha: $e");
    }
  }

  void _startOtpTimer() {
    setState(() {
      _isOtpDisabled = true;
      _seconds = 10;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds <= 1) {
          _isOtpDisabled = false;
          timer.cancel();
        } else {
          _seconds--;
        }
      });
    });
  }

  Future<void> _getOtp() async {
    String userInput = _idController.text.trim();
    if (isMobileLogin) {
      if (userInput.length != 10) {
        setState(() => _idError = "Enter valid 10-digit mobile number");
        return;
      }
    } else {
      if (userInput.isEmpty) {
        setState(() => _idError = "Enter HRMS ID / User ID");
        return;
      }
    }
    try {
      final msg = await AuthService.requestOtp(
        username: userInput,
        uuid: _captchaUUID,
        captcha: _captchaController.text.trim(),
      );
      _showError(msg);
    } catch (e) {
      _showError("Error while fetching OTP: $e");
    }
  }

  void _showError(String msg) {
    final isWide =
        MediaQuery.of(context).size.width > AppConstants.mobileWidthBreakpoint;
    if (isWide && kIsWeb) {
      _showTopRightError(msg);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showTopRightError(String msg) {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40,
        right: 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AColors.error,
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
                const Icon(Icons.error, color: AColors.white),
                const SizedBox(width: 8),
                Text(
                  msg,
                  style: ATextStyles.bodyBold.copyWith(color: AColors.white),
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
    Future.delayed(const Duration(seconds: 4), _removeOverlay);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleLogin() {
    _validateOtpAndLogin();
  }

  Future<void> _validateOtpAndLogin() async {
    String username = _idController.text.trim();
    String otp = _otpController.text.trim();
    String captcha = _captchaController.text.trim();
    String uuid = _captchaUUID;

    setState(() {
      _idError = null;
      _otpError = null;
      _captchaError = null;
    });

    if (isMobileLogin) {
      if (username.length != 10) {
        setState(() => _idError = "Enter valid 10-digit mobile number");
        return;
      }
    } else {
      if (username.isEmpty) {
        setState(() => _idError = "Enter HRMS ID / User ID");
        return;
      }
    }
    if (captcha.isEmpty) {
      setState(() => _captchaError = "Enter captcha");
      return;
    }
    if (otp.isEmpty) {
      setState(() => _otpError = "Enter OTP");
      return;
    }
    try {
      final loginResponse = await AuthService.validateOtp(
      username: username,
      otp: otp,
      uuid: uuid,
      captcha: captcha,
    );

    // Save token
    final accessToken = loginResponse['data']['accessToken'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', accessToken);

    // Pass lists to the provider
    final provider = Provider.of<FilterProvider>(context, listen: false);
    provider.setZoneList(List<Map<String, dynamic>>.from(loginResponse['data']['zoneList']));
    provider.setDivisionList(List<Map<String, dynamic>>.from(loginResponse['data']['divisionList']));
    provider.setPriorityList(List<Map<String, dynamic>>.from(loginResponse['data']['priorityList']));


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _removeOverlay();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final isMobile =
      MediaQuery.of(context).size.width < AppConstants.mobileWidthBreakpoint;

  return Card(
    elevation: 10,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    // Toggle: Mobile vs HRMS ID
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text("Mobile"),
          selected: isMobileLogin,
          onSelected: (v) => setState(() => isMobileLogin = true),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text("HRMS ID"),
          selected: !isMobileLogin,
          onSelected: (v) => setState(() => isMobileLogin = false),
        ),
      ],
    ),
    const SizedBox(height: 20),

    // Mobile or HRMS field
    TextField(
      controller: _idController,
      keyboardType: isMobileLogin ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: isMobileLogin ? "Mobile Number" : "HRMS ID / User ID",
        errorText: _idError,
      ),
    ),
    const SizedBox(height: 16),

    // Captcha image
    if (_captchaImage != null)
      Image.memory(_captchaImage!, height: 50),
    const SizedBox(height: 8),

    // Captcha input
    TextField(
      controller: _captchaController,
      decoration: InputDecoration(
        labelText: "Captcha",
        errorText: _captchaError,
        suffixIcon: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadCaptcha,
        ),
      ),
    ),
    const SizedBox(height: 16),

    // OTP input
    TextField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "OTP",
        errorText: _otpError,
        suffixIcon: TextButton(
          onPressed: _isOtpDisabled ? null : () {
            _getOtp();
            _startOtpTimer();
          },
          child: Text(_isOtpDisabled ? 'Resend in $_seconds' : 'Get OTP'),
        ),
      ),
    ),
    const SizedBox(height: 24),

    // Login button
    ElevatedButton(
      onPressed: _handleLogin,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
      ),
      child: const Text("Login"),
    ),
  ],
)

        ],
      ),
    ),
  );
}
}