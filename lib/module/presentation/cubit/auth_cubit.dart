import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit() : super(AuthInitial()) {
    _initAuth();
  }

  void _initAuth() {
    _authSubscription = _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Auth state will be updated by authStateChanges listener
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Đăng nhập thất bại'));
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi không xác định'));
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(AuthLoading());
    try {
      await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      // Auth state will be updated by authStateChanges listener
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Đăng ký thất bại'));
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi không xác định'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      await _authService.signInWithGoogle();
      // Auth state will be updated by authStateChanges listener
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Đăng nhập Google thất bại'));
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi không xác định'));
    }
  }

  Future<void> signInWithFacebook() async {
    emit(AuthLoading());
    try {
      await _authService.signInWithFacebook();
      // Auth state will be updated by authStateChanges listener
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Đăng nhập Facebook thất bại'));
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi không xác định'));
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) async {
    emit(AuthLoading());
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Xác thực số điện thoại thất bại'));
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi không xác định'));
    }
  }

  Future<void> signInWithPhone({
    required String verificationId,
    required String smsCode,
  }) async {
    emit(AuthLoading());
    try {
      await _authService.signInWithPhoneCredential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      // Auth state will be updated by authStateChanges listener
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Xác thực OTP thất bại'));
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi không xác định'));
    }
  }

  Future<void> signUpWithPhone({
    required String verificationId,
    required String smsCode,
    required String displayName,
  }) async {
    emit(AuthLoading());
    try {
      await _authService.signUpWithPhone(
        verificationId: verificationId,
        smsCode: smsCode,
        displayName: displayName,
      );
      // Auth state will be updated by authStateChanges listener
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Đăng ký bằng số điện thoại thất bại'));
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi không xác định'));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      // Auth state will be updated by authStateChanges listener
    } catch (e) {
      emit(AuthError('Đăng xuất thất bại'));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _authService.sendPasswordResetEmail(email);
      emit(AuthPasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Gửi email đặt lại mật khẩu thất bại'));
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi không xác định'));
    }
  }
}
