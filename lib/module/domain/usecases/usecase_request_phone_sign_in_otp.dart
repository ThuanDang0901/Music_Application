import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class RequestPhoneSignInOtpUseCase {
  final IAuthRepository repository;

  RequestPhoneSignInOtpUseCase(this.repository);

  Future<void> execute({
    required String phoneNumber,
    required AuthCompletedCallback onVerificationCompleted,
    required AuthFailureCallback onVerificationFailed,
    required PhoneCodeSentCallback onCodeSent,
    required PhoneTimeoutCallback onCodeAutoRetrievalTimeout,
    int? resendToken,
  }) {
    return repository.requestPhoneSignInOtp(
      phoneNumber: phoneNumber,
      onVerificationCompleted: onVerificationCompleted,
      onVerificationFailed: onVerificationFailed,
      onCodeSent: onCodeSent,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      resendToken: resendToken,
    );
  }
}
