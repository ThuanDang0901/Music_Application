import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/module/data/services/auth_service.dart';
import 'package:flutter_application_1/module/data/utils/auth_error_handler.dart';
import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/entities/phone_verification_session.dart';
import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthService authService;

  AuthRepositoryImpl({required this.authService});

  @override
  AuthUser? get currentUser => _mapUser(authService.currentUser);

  @override
  Stream<AuthUser?> authStateChanges() {
    return authService.authStateChanges.map(_mapUser);
  }

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _requireUser(credential.user);
  }

  @override
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    return _requireUser(credential.user ?? authService.currentUser);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    final credential = await authService.signInWithGoogle();
    return _requireUser(credential.user ?? authService.currentUser);
  }

  @override
  Future<AuthUser> signInWithFacebook() async {
    final credential = await authService.signInWithFacebook();
    return _requireUser(credential.user ?? authService.currentUser);
  }

  @override
  Future<void> requestPhoneSignInOtp({
    required String phoneNumber,
    required AuthCompletedCallback onVerificationCompleted,
    required AuthFailureCallback onVerificationFailed,
    required PhoneCodeSentCallback onCodeSent,
    required PhoneTimeoutCallback onCodeAutoRetrievalTimeout,
    int? resendToken,
  }) {
    return authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        try {
          final result = await authService.signInWithPhoneCredentialObject(
            credential: credential,
          );
          await onVerificationCompleted(
            _requireUser(result.user ?? authService.currentUser),
          );
        } on FirebaseAuthException catch (e) {
          onVerificationFailed(AuthErrorHandler.getErrorMessage(e));
        } catch (_) {
          onVerificationFailed('Đăng nhập bằng số điện thoại thất bại.');
        }
      },
      verificationFailed: (exception) {
        onVerificationFailed(AuthErrorHandler.getErrorMessage(exception));
      },
      codeSent: (verificationId, token) {
        onCodeSent(
          PhoneVerificationSession(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
            isSignUp: false,
            resendToken: token,
          ),
        );
      },
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      resendToken: resendToken,
    );
  }

  @override
  Future<void> requestPhoneSignUpOtp({
    required String phoneNumber,
    required String displayName,
    required AuthCompletedCallback onVerificationCompleted,
    required AuthFailureCallback onVerificationFailed,
    required PhoneCodeSentCallback onCodeSent,
    required PhoneTimeoutCallback onCodeAutoRetrievalTimeout,
    int? resendToken,
  }) {
    return authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        try {
          final result = await authService.signUpWithPhoneCredentialObject(
            credential: credential,
            displayName: displayName,
          );
          await onVerificationCompleted(
            _requireUser(result.user ?? authService.currentUser),
          );
        } on FirebaseAuthException catch (e) {
          onVerificationFailed(AuthErrorHandler.getErrorMessage(e));
        } catch (_) {
          onVerificationFailed('Đăng ký bằng số điện thoại thất bại.');
        }
      },
      verificationFailed: (exception) {
        onVerificationFailed(AuthErrorHandler.getErrorMessage(exception));
      },
      codeSent: (verificationId, token) {
        onCodeSent(
          PhoneVerificationSession(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
            isSignUp: true,
            displayName: displayName,
            resendToken: token,
          ),
        );
      },
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      resendToken: resendToken,
    );
  }

  @override
  Future<AuthUser> signInWithPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = await authService.signInWithPhoneCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _requireUser(credential.user ?? authService.currentUser);
  }

  @override
  Future<AuthUser> signUpWithPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String displayName,
  }) async {
    final credential = await authService.signUpWithPhone(
      verificationId: verificationId,
      smsCode: smsCode,
      displayName: displayName,
    );
    return _requireUser(credential.user ?? authService.currentUser);
  }

  @override
  Future<void> signOut() => authService.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return authService.sendPasswordResetEmail(email);
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }

  AuthUser _requireUser(User? user) {
    final mapped = _mapUser(user);
    if (mapped == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Không thể lấy thông tin tài khoản sau khi xác thực.',
      );
    }
    return mapped;
  }
}
