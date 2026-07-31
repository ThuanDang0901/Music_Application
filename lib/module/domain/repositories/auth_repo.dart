import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/entities/phone_verification_session.dart';

typedef AuthCompletedCallback = Future<void> Function(AuthUser user);
typedef AuthFailureCallback = void Function(String message);
typedef PhoneCodeSentCallback = void Function(
  PhoneVerificationSession session,
);
typedef PhoneTimeoutCallback = void Function(String verificationId);

abstract class IAuthRepository {
  AuthUser? get currentUser;

  Stream<AuthUser?> authStateChanges();

  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> signInWithFacebook();

  Future<void> requestPhoneSignInOtp({
    required String phoneNumber,
    required AuthCompletedCallback onVerificationCompleted,
    required AuthFailureCallback onVerificationFailed,
    required PhoneCodeSentCallback onCodeSent,
    required PhoneTimeoutCallback onCodeAutoRetrievalTimeout,
    int? resendToken,
  });

  Future<void> requestPhoneSignUpOtp({
    required String phoneNumber,
    required String displayName,
    required AuthCompletedCallback onVerificationCompleted,
    required AuthFailureCallback onVerificationFailed,
    required PhoneCodeSentCallback onCodeSent,
    required PhoneTimeoutCallback onCodeAutoRetrievalTimeout,
    int? resendToken,
  });

  Future<AuthUser> signInWithPhoneOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<AuthUser> signUpWithPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String displayName,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}
