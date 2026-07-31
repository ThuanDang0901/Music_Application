import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';
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
import 'package:flutter_application_1/module/presentation/cubit/auth_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/login_page.dart';

void main() {
  testWidgets('App loads and shows LoginPage when not authenticated', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(
      ToastificationWrapper(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthCubit(
                observeAuthStateChangesUseCase: ObserveAuthStateChangesUseCase(
                  repository,
                ),
                getCurrentAuthUserUseCase: GetCurrentAuthUserUseCase(
                  repository,
                ),
                signInWithEmailUseCase: SignInWithEmailUseCase(repository),
                signUpWithEmailUseCase: SignUpWithEmailUseCase(repository),
                signInWithGoogleUseCase: SignInWithGoogleUseCase(repository),
                signInWithFacebookUseCase: SignInWithFacebookUseCase(
                  repository,
                ),
                requestPhoneSignInOtpUseCase: RequestPhoneSignInOtpUseCase(
                  repository,
                ),
                requestPhoneSignUpOtpUseCase: RequestPhoneSignUpOtpUseCase(
                  repository,
                ),
                verifyPhoneSignInOtpUseCase: VerifyPhoneSignInOtpUseCase(
                  repository,
                ),
                verifyPhoneSignUpOtpUseCase: VerifyPhoneSignUpOtpUseCase(
                  repository,
                ),
                resendPhoneOtpUseCase: ResendPhoneOtpUseCase(repository),
                signOutUseCase: SignOutUseCase(repository),
                resetPasswordUseCase: ResetPasswordUseCase(repository),
              ),
            ),
            BlocProvider(create: (context) => ThemeCubit()),
          ],
          child: const MaterialApp(home: LoginPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsAtLeastNWidgets(1));
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}

class _FakeAuthRepository implements IAuthRepository {
  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  AuthUser? get currentUser => null;

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInWithFacebook() {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInWithPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) {
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signUpWithPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String displayName,
  }) {
    throw UnimplementedError();
  }
}
