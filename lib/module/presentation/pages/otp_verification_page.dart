import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/module/domain/entities/phone_verification_session.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/home_music.dart';
import 'package:flutter_application_1/module/presentation/widget/toast_helper.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationPage extends StatefulWidget {
  final PhoneVerificationSession session;

  const OtpVerificationPage({
    super.key,
    required this.session,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();

  int _countdown = 60;
  Timer? _timer;
  late PhoneVerificationSession _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        if (mounted) {
          setState(() => _countdown--);
        }
      } else {
        timer.cancel();
      }
    });
  }

  String get _maskedPhone {
    final number = _session.phoneNumber;
    if (number.length <= 4) return number;
    return number.replaceRange(4, number.length - 3, '***');
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      ToastHelper.showWarning(
        context: context,
        message: 'Vui lòng nhập đủ 6 ký tự mã OTP.',
      );
      return;
    }

    await context.read<AuthCubit>().verifyPhoneOtp(
      verificationId: _session.verificationId,
      smsCode: code,
      isSignUp: _session.isSignUp,
      displayName: _session.displayName,
    );
  }

  Future<void> _resendCode() async {
    if (_countdown > 0) return;
    await context.read<AuthCubit>().resendOtp(_session);
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    switch (state.status) {
      case AuthStatus.failure:
        ToastHelper.showError(
          context: context,
          message: state.message ?? 'Xác thực thất bại. Vui lòng thử lại.',
        );
        break;
      case AuthStatus.otpCodeSent:
        final session = state.phoneVerificationSession;
        if (state.action == AuthAction.resendPhoneOtp && session != null) {
          setState(() {
            _session = session;
          });
          _startCountdown();
          ToastHelper.showInfo(
            context: context,
            message: 'Mã OTP mới đã được gửi đến $_maskedPhone',
          );
        }
        break;
      case AuthStatus.authenticated:
        if (state.action == AuthAction.verifyPhoneSignUpOtp) {
          ToastHelper.showSuccess(
            context: context,
            message: 'Đăng ký và xác thực thành công!',
          );
        } else if (state.action == AuthAction.verifyPhoneSignInOtp ||
            state.action == AuthAction.resendPhoneOtp) {
          ToastHelper.showSuccess(
            context: context,
            message: 'Đăng nhập thành công!',
          );
        }

        if (state.action == AuthAction.verifyPhoneSignUpOtp ||
            state.action == AuthAction.verifyPhoneSignInOtp ||
            state.action == AuthAction.resendPhoneOtp) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeMusic()),
            (route) => false,
          );
        }
        break;
      case AuthStatus.initial:
      case AuthStatus.loading:
      case AuthStatus.passwordResetEmailSent:
      case AuthStatus.unauthenticated:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final isLoading =
        authState.isLoading &&
        (authState.action == AuthAction.verifyPhoneSignInOtp ||
            authState.action == AuthAction.verifyPhoneSignUpOtp);
    final isResending =
        authState.isLoading && authState.action == AuthAction.resendPhoneOtp;
    final bgColor = isDark ? const Color(0xFF091227) : const Color(0xFFEAF0FF);
    final textColor = isDark ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF6C5CE7);

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black26,
          width: 1.2,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: accentColor, width: 2),
      color: accentColor.withValues(alpha: 0.05),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: accentColor.withValues(alpha: 0.1),
        border: Border.all(color: accentColor, width: 1.5),
      ),
    );

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous != current,
      listener: _handleAuthState,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: textColor,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 18),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.verified_user_outlined,
                      size: 40,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Xác thực mã OTP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withValues(alpha: 0.65),
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'Chúng tôi đã gửi mã xác thực gồm 6 chữ số đến số điện thoại ',
                      ),
                      TextSpan(
                        text: _maskedPhone,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '. Vui lòng nhập mã bên dưới.'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  onSubmitted: (_) => _verifyOtp(),
                  showCursor: true,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  keyboardType: TextInputType.number,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  animationCurve: Curves.easeOut,
                  animationDuration: const Duration(milliseconds: 250),
                  preFilledWidget: Text(
                    '-',
                    style: TextStyle(
                      color: isDark ? Colors.white24 : Colors.black12,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      disabledBackgroundColor:
                          accentColor.withValues(alpha: 0.5),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Xác thực',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Không nhận được mã? ',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    _countdown > 0 || isResending
                        ? Text(
                            'Gửi lại sau ${_countdown}s',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : GestureDetector(
                            onTap: isResending ? null : _resendCode,
                            child: Text(
                              isResending ? 'Đang gửi...' : 'Gửi lại mã',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      _otpController.text = '123456';
                    },
                    icon: Icon(
                      Icons.bug_report_outlined,
                      size: 18,
                      color: textColor.withValues(alpha: 0.4),
                    ),
                    label: Text(
                      'Test: Điền mã demo (123456)',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.4),
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
