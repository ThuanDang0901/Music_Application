import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/module/domain/entities/phone_verification_session.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/login_page.dart';
import 'package:flutter_application_1/module/presentation/pages/home_music.dart';
import 'package:flutter_application_1/module/presentation/pages/otp_verification_page.dart';
import 'package:flutter_application_1/module/presentation/widget/toast_helper.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

enum RegisterMethod { email, phone, google }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  RegisterMethod _currentMethod = RegisterMethod.email;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _phoneNumber = '';
  String _phoneCountryCode = '+84';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ToastHelper.showWarning(
        context: context,
        message: 'Vui lòng đồng ý với điều khoản sử dụng để tiếp tục.',
      );
      return;
    }

    if (_currentMethod == RegisterMethod.email) {
      await _registerWithEmail();
    } else if (_currentMethod == RegisterMethod.phone) {
      await _registerWithPhone();
    }
  }

  Future<void> _registerWithEmail() async {
    await context.read<AuthCubit>().signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      displayName: _nameController.text,
    );
  }

  Future<void> _registerWithPhone() async {
    await context.read<AuthCubit>().requestPhoneSignUpOtp(
      dialCode: _phoneCountryCode,
      phoneNumber: _phoneNumber,
      displayName: _nameController.text,
    );
  }

  Future<void> _registerWithGoogle() async {
    await context.read<AuthCubit>().signInWithGoogle();
  }

  void _navigateToOtp(PhoneVerificationSession session) {
    ToastHelper.showInfo(
      context: context,
      message: 'Mã xác thực OTP đã được gửi đến số điện thoại ${session.phoneNumber}',
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
          message: state.message ?? 'Đăng ký thất bại. Vui lòng thử lại.',
        );
        break;
      case AuthStatus.otpCodeSent:
        final session = state.phoneVerificationSession;
        if (state.action == AuthAction.requestPhoneSignUpOtp && session != null) {
          _navigateToOtp(session);
        }
        break;
      case AuthStatus.authenticated:
        if (state.action == AuthAction.signUpWithEmail) {
          ToastHelper.showSuccess(
            context: context,
            message:
                'Đăng ký tài khoản thành công! Chào mừng bạn đến với Music App.',
          );
        } else if (state.action == AuthAction.requestPhoneSignUpOtp) {
          ToastHelper.showSuccess(
            context: context,
            message: 'Đăng ký thành công!',
          );
        } else if (state.action == AuthAction.signInWithGoogle) {
          ToastHelper.showSuccess(
            context: context,
            message: 'Tiếp tục với Google thành công!',
          );
        }

        if (state.action == AuthAction.signUpWithEmail ||
            state.action == AuthAction.requestPhoneSignUpOtp ||
            state.action == AuthAction.signInWithGoogle) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeMusic()),
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
                    Icon(
                      Icons.music_note_rounded,
                      size: 64,
                      color: accentColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Music App',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tạo tài khoản để bắt đầu hành trình âm nhạc',
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
                      isSelected: _currentMethod == RegisterMethod.email,
                      onTap: () => setState(() => _currentMethod = RegisterMethod.email),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _methodTab(
                      label: 'Điện thoại',
                      icon: Icons.phone_android_outlined,
                      isSelected: _currentMethod == RegisterMethod.phone,
                      onTap: () => setState(() => _currentMethod = RegisterMethod.phone),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: textColor, fontSize: 15),
                      decoration: _inputDecoration(
                        label: 'Họ và tên',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Vui lòng nhập họ và tên';
                        }
                        if ((value?.trim().length ?? 0) < 2) {
                          return 'Tên phải có ít nhất 2 ký tự';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    if (_currentMethod == RegisterMethod.email) ...[
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
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: TextStyle(color: textColor, fontSize: 15),
                        obscureText: _obscureConfirmPassword,
                        decoration: _inputDecoration(
                          label: 'Xác nhận mật khẩu',
                          icon: Icons.lock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: isDark ? Colors.white54 : Colors.black45,
                              size: 22,
                            ),
                            onPressed: () => setState(
                                () => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Vui lòng xác nhận mật khẩu';
                          }
                          if (value != _passwordController.text) {
                            return 'Mật khẩu xác nhận không khớp';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitForm(),
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
                                'Chúng tôi sẽ gửi mã OTP đến số điện thoại của bạn để xác thực.',
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: isLoading
                              ? null
                              : (v) => setState(() => _agreeToTerms = v ?? false),
                          activeColor: accentColor,
                          checkColor: Colors.white,
                          side: BorderSide(
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Tôi đã đọc và đồng ý với ',
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Điều khoản dịch vụ ',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: 'và '),
                                TextSpan(
                                  text: 'Chính sách bảo mật',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
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
                                'Đăng ký',
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
              const SizedBox(height: 24),
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
                      'Hoặc đăng ký với',
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
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _registerWithGoogle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF1A1A2E)
                        : Colors.white,
                  ),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 24,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  label: const Text(
                    'Tiếp tục với Google',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã có tài khoản? ',
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
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                    child: Text(
                      'Đăng nhập',
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
