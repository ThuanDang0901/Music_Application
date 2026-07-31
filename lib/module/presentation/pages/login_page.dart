import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/module/domain/entities/phone_verification_session.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/home_music.dart';
import 'package:flutter_application_1/module/presentation/pages/otp_verification_page.dart';
import 'package:flutter_application_1/module/presentation/pages/register_page.dart';
import 'package:flutter_application_1/module/presentation/widget/toast_helper.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

enum LoginMethod { email, phone, google, facebook }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  LoginMethod _currentMethod = LoginMethod.email;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String _phoneCountryCode = '+84';
  String _phoneNumber = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotEmailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentMethod == LoginMethod.email) {
      await _loginWithEmail();
    } else if (_currentMethod == LoginMethod.phone) {
      await _loginWithPhone();
    }
  }

  Future<void> _loginWithEmail() async {
    await context.read<AuthCubit>().signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _loginWithPhone() async {
    await context.read<AuthCubit>().requestPhoneSignInOtp(
      dialCode: _phoneCountryCode,
      phoneNumber: _phoneNumber,
    );
  }

  Future<void> _loginWithGoogle() async {
    await context.read<AuthCubit>().signInWithGoogle();
  }

  Future<void> _loginWithFacebook() async {
    await context.read<AuthCubit>().signInWithFacebook();
  }

  Future<void> _showForgotPasswordDialog() async {
    final isDark = context.read<ThemeCubit>().state;
    final textColor = isDark ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF6C5CE7);
    final bgColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor = isDark ? Colors.white24 : Colors.black26;
    final labelColor = isDark ? Colors.white60 : Colors.black54;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Quên mật khẩu',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nhập email của bạn, chúng tôi sẽ gửi liên kết đặt lại mật khẩu đến hộp thư của bạn.',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _forgotEmailController,
                style: TextStyle(color: textColor, fontSize: 15),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: labelColor, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final email = _forgotEmailController.text.trim();
                if (email.isEmpty) {
                  ToastHelper.showWarning(
                    context: dialogContext,
                    message: 'Vui lòng nhập địa chỉ email.',
                  );
                  return;
                }
                final regex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );
                if (!regex.hasMatch(email)) {
                  ToastHelper.showWarning(
                    context: dialogContext,
                    message: 'Email không hợp lệ.',
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                context.read<AuthCubit>().resetPassword(email);
                _forgotEmailController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Gửi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToOtp(PhoneVerificationSession session) {
    ToastHelper.showInfo(
      context: context,
      message: 'Mã OTP đã được gửi đến ${session.phoneNumber}',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationPage(session: session),
      ),
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    switch (state.status) {
      case AuthStatus.failure:
        ToastHelper.showError(
          context: context,
          message: state.message ?? 'Đăng nhập thất bại. Vui lòng thử lại.',
        );
        break;
      case AuthStatus.otpCodeSent:
        final session = state.phoneVerificationSession;
        if (state.action == AuthAction.requestPhoneSignInOtp && session != null) {
          _navigateToOtp(session);
        }
        break;
      case AuthStatus.authenticated:
        final user = state.user;
        final name = user?.displayName ?? user?.email ?? user?.phoneNumber ?? 'bạn';
        if (state.action == AuthAction.signInWithEmail) {
          ToastHelper.showSuccess(
            context: context,
            message: 'Chào mừng $name trở lại!',
          );
        } else if (state.action == AuthAction.signInWithGoogle) {
          ToastHelper.showSuccess(
            context: context,
            message: 'Chào mừng $name! Đăng nhập Google thành công.',
          );
        } else if (state.action == AuthAction.signInWithFacebook) {
          ToastHelper.showSuccess(
            context: context,
            message: 'Chào mừng $name! Đăng nhập Facebook thành công.',
          );
        } else if (state.action == AuthAction.requestPhoneSignInOtp) {
          ToastHelper.showSuccess(
            context: context,
            message: 'Đăng nhập thành công!',
          );
        }

        if (state.action == AuthAction.signInWithEmail ||
            state.action == AuthAction.signInWithGoogle ||
            state.action == AuthAction.signInWithFacebook ||
            state.action == AuthAction.requestPhoneSignInOtp) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeMusic()),
          );
        }
        break;
      case AuthStatus.passwordResetEmailSent:
        ToastHelper.showSuccess(
          context: context,
          message:
              'Liên kết đặt lại mật khẩu đã được gửi. Vui lòng kiểm tra hộp thư email của bạn.',
        );
        break;
      case AuthStatus.initial:
      case AuthStatus.loading:
      case AuthStatus.unauthenticated:
        break;
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final isDark = context.watch<ThemeCubit>().state;
    final borderColor = isDark ? Colors.white38 : Colors.black26;
    final labelColor = isDark ? Colors.white60 : Colors.black54;
    final fillColor = isDark
        ? const Color(0xFF1A1A2E)
        : Colors.grey.shade100;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: labelColor, fontSize: 14),
      prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.black45, size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final isLoading = authState.isLoading;
    final bgColor = isDark ? const Color(0xFF091227) : const Color(0xFFEAF0FF);
    final textColor = isDark ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF6C5CE7);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous != current,
      listener: _handleAuthState,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, const Color(0xFFA29BFE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chào mừng trở lại, vui lòng đăng nhập để tiếp tục',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _methodTab(
                      label: 'Email',
                      icon: Icons.email_outlined,
                      isSelected: _currentMethod == LoginMethod.email,
                      onTap: () => setState(() => _currentMethod = LoginMethod.email),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _methodTab(
                      label: 'Điện thoại',
                      icon: Icons.phone_android_outlined,
                      isSelected: _currentMethod == LoginMethod.phone,
                      onTap: () => setState(() => _currentMethod = LoginMethod.phone),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_currentMethod == LoginMethod.email) ...[
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: textColor, fontSize: 15),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          label: 'Địa chỉ email',
                          icon: Icons.email_outlined,
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Vui lòng nhập email';
                          }
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value!.trim())) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        style: TextStyle(color: textColor, fontSize: 15),
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          label: 'Mật khẩu',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: isDark ? Colors.white54 : Colors.black45,
                              size: 22,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if ((value?.length ?? 0) < 6) {
                            return 'Mật khẩu tối thiểu 6 ký tự';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitLogin(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: isLoading
                                    ? null
                                    : (v) =>
                                        setState(() => _rememberMe = v ?? false),
                                activeColor: accentColor,
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: isDark ? Colors.white38 : Colors.black26,
                                ),
                              ),
                              Text(
                                'Ghi nhớ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: isLoading ? null : _showForgotPasswordDialog,
                            child: Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                fontSize: 13,
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      IntlPhoneField(
                        decoration: _inputDecoration(
                          label: 'Số điện thoại',
                          icon: Icons.phone_outlined,
                        ).copyWith(
                          prefixIcon: null,
                        ),
                        initialCountryCode: 'VN',
                        languageCode: 'vi',
                        style: TextStyle(color: textColor, fontSize: 15),
                        dropdownTextStyle: TextStyle(color: textColor, fontSize: 14),
                        disableLengthCheck: true,
                        autovalidateMode: AutovalidateMode.disabled,
                        onCountryChanged: (country) {
                          _phoneCountryCode = '+${country.dialCode}';
                        },
                        onChanged: (phone) {
                          _phoneNumber = phone.number;
                        },
                        validator: (phone) {
                          if (phone == null || phone.number.isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: accentColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Chúng tôi sẽ gửi mã OTP đến số điện thoại để xác thực đăng nhập.',
                                style: TextStyle(
                                  color: textColor.withValues(alpha: 0.8),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          disabledBackgroundColor: accentColor.withValues(alpha: 0.5),
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
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.white24 : Colors.black26,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Hoặc đăng nhập với',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.white24 : Colors.black26,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : _loginWithGoogle,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textColor,
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor:
                              isDark ? const Color(0xFF1A1A2E) : Colors.white,
                        ),
                        icon: isLoading
                            ? const SizedBox.shrink()
                            : Icon(
                                Icons.g_mobiledata_outlined,
                                size: 26,
                                color: Colors.redAccent.shade700,
                              ),
                        label: Text(
                          'Google',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : _loginWithFacebook,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textColor,
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor:
                              isDark ? const Color(0xFF1A1A2E) : Colors.white,
                        ),
                        icon: isLoading
                            ? const SizedBox.shrink()
                            : const Icon(
                                Icons.facebook_rounded,
                                size: 24,
                                color: Color(0xFF1877F2),
                              ),
                        label: Text(
                          'Facebook',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản? ',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                    child: Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _methodTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = context.watch<ThemeCubit>().state;
    final accentColor = const Color(0xFF6C5CE7);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? Colors.white24 : Colors.black26),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? accentColor
                  : (isDark ? Colors.white54 : Colors.black45),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? accentColor
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
