import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/entities/phone_verification_session.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  otpCodeSent,
  passwordResetEmailSent,
  failure,
}

enum AuthAction {
  observeAuthState,
  signInWithEmail,
  signUpWithEmail,
  signInWithGoogle,
  signInWithFacebook,
  requestPhoneSignInOtp,
  requestPhoneSignUpOtp,
  verifyPhoneSignInOtp,
  verifyPhoneSignUpOtp,
  resendPhoneOtp,
  signOut,
  resetPassword,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthAction? action;
  final AuthUser? user;
  final String? message;
  final PhoneVerificationSession? phoneVerificationSession;
  final String? resetPasswordEmail;

  const AuthState({
    required this.status,
    this.action,
    this.user,
    this.message,
    this.phoneVerificationSession,
    this.resetPasswordEmail,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        action = null,
        user = null,
        message = null,
        phoneVerificationSession = null,
        resetPasswordEmail = null;

  factory AuthState.loading({
    required AuthAction action,
    AuthUser? user,
  }) {
    return AuthState(
      status: AuthStatus.loading,
      action: action,
      user: user,
    );
  }

  factory AuthState.authenticated(
    AuthUser user, {
    AuthAction? action,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      action: action,
      user: user,
    );
  }

  factory AuthState.unauthenticated({
    AuthAction? action,
  }) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      action: action,
    );
  }

  factory AuthState.otpCodeSent({
    required PhoneVerificationSession session,
    required AuthAction action,
    AuthUser? user,
  }) {
    return AuthState(
      status: AuthStatus.otpCodeSent,
      action: action,
      user: user,
      phoneVerificationSession: session,
    );
  }

  factory AuthState.passwordResetEmailSent({
    required String email,
    AuthUser? user,
  }) {
    return AuthState(
      status: AuthStatus.passwordResetEmailSent,
      action: AuthAction.resetPassword,
      user: user,
      resetPasswordEmail: email,
    );
  }

  factory AuthState.failure({
    required String message,
    required AuthAction action,
    AuthUser? user,
    PhoneVerificationSession? phoneVerificationSession,
  }) {
    return AuthState(
      status: AuthStatus.failure,
      action: action,
      user: user,
      message: message,
      phoneVerificationSession: phoneVerificationSession,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [
        status,
        action,
        user,
        message,
        phoneVerificationSession,
        resetPasswordEmail,
      ];
}
