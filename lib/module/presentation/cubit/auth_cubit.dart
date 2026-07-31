import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/module/data/utils/auth_error_handler.dart';
import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/entities/phone_verification_session.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_get_current_auth_user.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_observe_auth_state_changes.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_request_phone_sign_in_otp.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_request_phone_sign_up_otp.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_resend_phone_otp.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_reset_password.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_sign_in_with_email.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_sign_in_with_facebook.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_sign_in_with_google.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_sign_out.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_sign_up_with_email.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_verify_phone_sign_in_otp.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_verify_phone_sign_up_otp.dart';
import 'package:flutter_application_1/module/domain/utils/phone_number_formatter.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ObserveAuthStateChangesUseCase _observeAuthStateChangesUseCase;
  final GetCurrentAuthUserUseCase _getCurrentAuthUserUseCase;
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithFacebookUseCase _signInWithFacebookUseCase;
  final RequestPhoneSignInOtpUseCase _requestPhoneSignInOtpUseCase;
  final RequestPhoneSignUpOtpUseCase _requestPhoneSignUpOtpUseCase;
  final VerifyPhoneSignInOtpUseCase _verifyPhoneSignInOtpUseCase;
  final VerifyPhoneSignUpOtpUseCase _verifyPhoneSignUpOtpUseCase;
  final ResendPhoneOtpUseCase _resendPhoneOtpUseCase;
  final SignOutUseCase _signOutUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  StreamSubscription<AuthUser?>? _authSubscription;
  AuthAction? _pendingAction;

  AuthCubit({
    required ObserveAuthStateChangesUseCase observeAuthStateChangesUseCase,
    required GetCurrentAuthUserUseCase getCurrentAuthUserUseCase,
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithFacebookUseCase signInWithFacebookUseCase,
    required RequestPhoneSignInOtpUseCase requestPhoneSignInOtpUseCase,
    required RequestPhoneSignUpOtpUseCase requestPhoneSignUpOtpUseCase,
    required VerifyPhoneSignInOtpUseCase verifyPhoneSignInOtpUseCase,
    required VerifyPhoneSignUpOtpUseCase verifyPhoneSignUpOtpUseCase,
    required ResendPhoneOtpUseCase resendPhoneOtpUseCase,
    required SignOutUseCase signOutUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  })  : _observeAuthStateChangesUseCase = observeAuthStateChangesUseCase,
        _getCurrentAuthUserUseCase = getCurrentAuthUserUseCase,
        _signInWithEmailUseCase = signInWithEmailUseCase,
        _signUpWithEmailUseCase = signUpWithEmailUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signInWithFacebookUseCase = signInWithFacebookUseCase,
        _requestPhoneSignInOtpUseCase = requestPhoneSignInOtpUseCase,
        _requestPhoneSignUpOtpUseCase = requestPhoneSignUpOtpUseCase,
        _verifyPhoneSignInOtpUseCase = verifyPhoneSignInOtpUseCase,
        _verifyPhoneSignUpOtpUseCase = verifyPhoneSignUpOtpUseCase,
        _resendPhoneOtpUseCase = resendPhoneOtpUseCase,
        _signOutUseCase = signOutUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        super(const AuthState.initial()) {
    _initAuth();
  }

  void _initAuth() {
    _emitSnapshot(_getCurrentAuthUserUseCase.execute());

    _authSubscription = _observeAuthStateChangesUseCase.execute().listen(
      _emitSnapshot,
    );
  }

  void _emitSnapshot(AuthUser? user) {
    final action = _pendingAction ?? AuthAction.observeAuthState;
    if (user != null) {
      emit(AuthState.authenticated(user, action: action));
    } else {
      emit(AuthState.unauthenticated(action: action));
    }
    if (_pendingAction != null) {
      _pendingAction = null;
    }
  }

  void consumeTransientState() {
    _emitSnapshot(_getCurrentAuthUserUseCase.execute());
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _pendingAction = AuthAction.signInWithEmail;
    emit(AuthState.loading(action: AuthAction.signInWithEmail, user: state.user));
    try {
      await _signInWithEmailUseCase.execute(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _emitFailure(AuthAction.signInWithEmail, AuthErrorHandler.getErrorMessage(e));
    } catch (_) {
      _emitFailure(AuthAction.signInWithEmail, 'Đăng nhập thất bại. Vui lòng thử lại.');
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _pendingAction = AuthAction.signUpWithEmail;
    emit(AuthState.loading(action: AuthAction.signUpWithEmail, user: state.user));
    try {
      await _signUpWithEmailUseCase.execute(
        email: email,
        password: password,
        displayName: displayName,
      );
    } on FirebaseAuthException catch (e) {
      _emitFailure(AuthAction.signUpWithEmail, AuthErrorHandler.getErrorMessage(e));
    } catch (_) {
      _emitFailure(AuthAction.signUpWithEmail, 'Đăng ký thất bại. Vui lòng thử lại.');
    }
  }

  Future<void> signInWithGoogle() async {
    _pendingAction = AuthAction.signInWithGoogle;
    emit(AuthState.loading(action: AuthAction.signInWithGoogle, user: state.user));
    try {
      await _signInWithGoogleUseCase.execute();
    } on FirebaseAuthException catch (e) {
      _emitFailure(AuthAction.signInWithGoogle, AuthErrorHandler.getErrorMessage(e));
    } catch (_) {
      _emitFailure(
        AuthAction.signInWithGoogle,
        'Đăng nhập Google thất bại. Vui lòng thử lại.',
      );
    }
  }

  Future<void> signInWithFacebook() async {
    _pendingAction = AuthAction.signInWithFacebook;
    emit(
      AuthState.loading(action: AuthAction.signInWithFacebook, user: state.user),
    );
    try {
      await _signInWithFacebookUseCase.execute();
    } on FirebaseAuthException catch (e) {
      _emitFailure(
        AuthAction.signInWithFacebook,
        AuthErrorHandler.getErrorMessage(e),
      );
    } catch (_) {
      _emitFailure(
        AuthAction.signInWithFacebook,
        'Đăng nhập Facebook thất bại. Vui lòng thử lại.',
      );
    }
  }

  Future<void> requestPhoneSignInOtp({
    required String dialCode,
    required String phoneNumber,
  }) async {
    final normalizedPhone = PhoneNumberFormatter.normalize(
      dialCode: dialCode,
      rawNumber: phoneNumber,
    );

    if (!PhoneNumberFormatter.isValidInternationalPhone(normalizedPhone)) {
      emit(
        AuthState.failure(
          action: AuthAction.requestPhoneSignInOtp,
          message:
              'Số điện thoại không hợp lệ (định dạng: +84xxxxxxxx, dài 9-15 ký tự).',
          user: state.user,
        ),
      );
      return;
    }

    _pendingAction = AuthAction.requestPhoneSignInOtp;
    emit(
      AuthState.loading(
        action: AuthAction.requestPhoneSignInOtp,
        user: state.user,
      ),
    );

    try {
      await _requestPhoneSignInOtpUseCase.execute(
        phoneNumber: normalizedPhone,
        onVerificationCompleted: (user) async {
          emit(
            AuthState.authenticated(
              user,
              action: AuthAction.requestPhoneSignInOtp,
            ),
          );
          _pendingAction = null;
        },
        onVerificationFailed: (message) {
          _emitFailure(AuthAction.requestPhoneSignInOtp, message);
        },
        onCodeSent: (session) {
          emit(
            AuthState.otpCodeSent(
              session: session,
              action: AuthAction.requestPhoneSignInOtp,
              user: state.user,
            ),
          );
        },
        onCodeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      _emitFailure(
        AuthAction.requestPhoneSignInOtp,
        AuthErrorHandler.getErrorMessage(e),
      );
    } catch (_) {
      _emitFailure(
        AuthAction.requestPhoneSignInOtp,
        'Gửi mã OTP thất bại. Vui lòng thử lại.',
      );
    }
  }

  Future<void> requestPhoneSignUpOtp({
    required String dialCode,
    required String phoneNumber,
    required String displayName,
  }) async {
    final normalizedPhone = PhoneNumberFormatter.normalize(
      dialCode: dialCode,
      rawNumber: phoneNumber,
    );

    if (!PhoneNumberFormatter.isValidInternationalPhone(normalizedPhone)) {
      emit(
        AuthState.failure(
          action: AuthAction.requestPhoneSignUpOtp,
          message:
              'Số điện thoại không hợp lệ (định dạng: +84xxxxxxxx, dài 9-15 ký tự).',
          user: state.user,
        ),
      );
      return;
    }

    _pendingAction = AuthAction.requestPhoneSignUpOtp;
    emit(
      AuthState.loading(
        action: AuthAction.requestPhoneSignUpOtp,
        user: state.user,
      ),
    );

    try {
      await _requestPhoneSignUpOtpUseCase.execute(
        phoneNumber: normalizedPhone,
        displayName: displayName,
        onVerificationCompleted: (user) async {
          emit(
            AuthState.authenticated(
              user,
              action: AuthAction.requestPhoneSignUpOtp,
            ),
          );
          _pendingAction = null;
        },
        onVerificationFailed: (message) {
          _emitFailure(AuthAction.requestPhoneSignUpOtp, message);
        },
        onCodeSent: (session) {
          emit(
            AuthState.otpCodeSent(
              session: session,
              action: AuthAction.requestPhoneSignUpOtp,
              user: state.user,
            ),
          );
        },
        onCodeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      _emitFailure(
        AuthAction.requestPhoneSignUpOtp,
        AuthErrorHandler.getErrorMessage(e),
      );
    } catch (_) {
      _emitFailure(
        AuthAction.requestPhoneSignUpOtp,
        'Gửi mã OTP đăng ký thất bại. Vui lòng thử lại.',
      );
    }
  }

  Future<void> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    required bool isSignUp,
    String? displayName,
  }) async {
    final action = isSignUp
        ? AuthAction.verifyPhoneSignUpOtp
        : AuthAction.verifyPhoneSignInOtp;

    _pendingAction = action;
    emit(AuthState.loading(action: action, user: state.user));

    try {
      if (isSignUp) {
        await _verifyPhoneSignUpOtpUseCase.execute(
          verificationId: verificationId,
          smsCode: smsCode,
          displayName: displayName ?? '',
        );
      } else {
        await _verifyPhoneSignInOtpUseCase.execute(
          verificationId: verificationId,
          smsCode: smsCode,
        );
      }
    } on FirebaseAuthException catch (e) {
      _emitFailure(action, AuthErrorHandler.getErrorMessage(e));
    } catch (_) {
      _emitFailure(action, 'Xác thực OTP thất bại. Vui lòng thử lại.');
    }
  }

  Future<void> resendOtp(PhoneVerificationSession session) async {
    _pendingAction = AuthAction.resendPhoneOtp;
    emit(AuthState.loading(action: AuthAction.resendPhoneOtp, user: state.user));

    try {
      await _resendPhoneOtpUseCase.execute(
        session: session,
        onVerificationCompleted: (user) async {
          emit(AuthState.authenticated(user, action: AuthAction.resendPhoneOtp));
          _pendingAction = null;
        },
        onVerificationFailed: (message) {
          _emitFailure(AuthAction.resendPhoneOtp, message, session: session);
        },
        onCodeSent: (newSession) {
          emit(
            AuthState.otpCodeSent(
              session: newSession,
              action: AuthAction.resendPhoneOtp,
              user: state.user,
            ),
          );
        },
        onCodeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      _emitFailure(
        AuthAction.resendPhoneOtp,
        AuthErrorHandler.getErrorMessage(e),
        session: session,
      );
    } catch (_) {
      _emitFailure(
        AuthAction.resendPhoneOtp,
        'Gửi lại mã OTP thất bại. Vui lòng thử lại.',
        session: session,
      );
    }
  }

  Future<void> signOut() async {
    _pendingAction = AuthAction.signOut;
    emit(AuthState.loading(action: AuthAction.signOut, user: state.user));
    try {
      await _signOutUseCase.execute();
    } on FirebaseAuthException catch (e) {
      _emitFailure(AuthAction.signOut, AuthErrorHandler.getErrorMessage(e));
    } catch (_) {
      _emitFailure(AuthAction.signOut, 'Đăng xuất thất bại. Vui lòng thử lại.');
    }
  }

  Future<void> resetPassword(String email) async {
    _pendingAction = AuthAction.resetPassword;
    emit(AuthState.loading(action: AuthAction.resetPassword, user: state.user));
    try {
      await _resetPasswordUseCase.execute(email.trim());
      emit(
        AuthState.passwordResetEmailSent(
          email: email.trim(),
          user: state.user,
        ),
      );
      _pendingAction = null;
    } on FirebaseAuthException catch (e) {
      _emitFailure(AuthAction.resetPassword, AuthErrorHandler.getErrorMessage(e));
    } catch (_) {
      _emitFailure(
        AuthAction.resetPassword,
        'Gửi email đặt lại mật khẩu thất bại. Vui lòng thử lại.',
      );
    }
  }

  void _emitFailure(
    AuthAction action,
    String message, {
    PhoneVerificationSession? session,
  }) {
    emit(
      AuthState.failure(
        action: action,
        message: message,
        user: state.user,
        phoneVerificationSession: session,
      ),
    );
    _pendingAction = null;
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
