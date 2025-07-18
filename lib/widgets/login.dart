import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'services.dart';
import 'pnr.dart';
import 'constants.dart';
import 'colors.dart';
import 'text_styles.dart';

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
    // For mobile: must be 10 digits. For HRMS: cannot be empty
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
      final accessToken = await AuthService.validateOtp(
        username: username,
        otp: otp,
        uuid: uuid,
        captcha: captcha,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuotaCheckPage(accessToken: accessToken),
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
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMobileLogin
                            ? AColors.primary
                            : Colors.grey.shade100,
                        foregroundColor: isMobileLogin
                            ? Colors.white
                            : Colors.black87,
                        elevation: isMobileLogin ? 3 : 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (!isMobileLogin) {
                          setState(() {
                            isMobileLogin = true;
                            _idError = null;
                            _otpError = null;
                            _captchaError = null;
                            _idController.clear();
                            _otpController.clear();
                            _captchaController.clear();
                          });
                        }
                      },
                      child: const Text('Login via Mobile'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isMobileLogin
                            ? AColors.primary
                            : Colors.grey.shade100,
                        foregroundColor: !isMobileLogin
                            ? Colors.white
                            : Colors.black87,
                        elevation: !isMobileLogin ? 3 : 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (isMobileLogin) {
                          setState(() {
                            isMobileLogin = false;
                            _idError = null;
                            _otpError = null;
                            _captchaError = null;
                            _idController.clear();
                            _otpController.clear();
                            _captchaController.clear();
                          });
                        }
                      },
                      child: const Text('Login via HRMS ID'),
                    ),
                  ),
                ],
              ),
            ),
            Text('Sign In', style: ATextStyles.headingLarge),
            const SizedBox(height: 20),
            TextField(
              controller: _idController,
              keyboardType: isMobileLogin
                  ? TextInputType.number
                  : TextInputType.text,
              maxLength: isMobileLogin ? 10 : null,
              decoration: InputDecoration(
                labelText: isMobileLogin
                    ? 'Mobile Number'
                    : 'HRMS ID / User ID',
                prefixIcon: Icon(
                  isMobileLogin ? Icons.phone : Icons.person,
                  color: AColors.primary,
                ),
                counterText: '',
                errorText: _idError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AColors.white,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (_captchaImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(_captchaImage!, width: 100, height: 40),
                  )
                else
                  const Text('Loading CAPTCHA...'),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AColors.primary),
                  onPressed: _loadCaptcha,
                  tooltip: "Regenerate Captcha",
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _captchaController,
              decoration: InputDecoration(
                labelText: 'Enter Captcha',
                prefixIcon: const Icon(Icons.shield, color: AColors.primary),
                errorText: _captchaError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AColors.white,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'OTP',
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: AColors.primary,
                      ),
                      errorText: _otpError,
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isOtpDisabled
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        child: Text(
                          '$_seconds s',
                          style: ATextStyles.bodySmall,
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          _getOtp();
                          _startOtpTimer();
                        },
                        child: const Text(
                          'Get OTP',
                          style: ATextStyles.buttonText,
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: ATextStyles.buttonText,
                ),
                child: const Text('Login', style: ATextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
