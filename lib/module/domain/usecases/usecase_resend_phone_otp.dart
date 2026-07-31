import 'package:flutter_application_1/module/domain/entities/phone_verification_session.dart';
import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class ResendPhoneOtpUseCase {
  final IAuthRepository repository;

  ResendPhoneOtpUseCase(this.repository);

  Future<void> execute({
    required PhoneVerificationSession session,
    required AuthCompletedCallback onVerificationCompleted,
    required AuthFailureCallback onVerificationFailed,
    required PhoneCodeSentCallback onCodeSent,
    required PhoneTimeoutCallback onCodeAutoRetrievalTimeout,
  }) {
    if (session.isSignUp) {
      return repository.requestPhoneSignUpOtp(
        phoneNumber: session.phoneNumber,
        displayName: session.displayName ?? '',
        onVerificationCompleted: onVerificationCompleted,
        onVerificationFailed: onVerificationFailed,
        onCodeSent: onCodeSent,
        onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
        resendToken: session.resendToken,
      );
    }

    return repository.requestPhoneSignInOtp(
      phoneNumber: session.phoneNumber,
      onVerificationCompleted: onVerificationCompleted,
      onVerificationFailed: onVerificationFailed,
      onCodeSent: onCodeSent,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      resendToken: session.resendToken,
    );
  }
}
