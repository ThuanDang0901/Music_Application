import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class RequestPhoneSignUpOtpUseCase {
  final IAuthRepository repository;

  RequestPhoneSignUpOtpUseCase(this.repository);

  Future<void> execute({
    required String phoneNumber,
    required String displayName,
    required AuthCompletedCallback onVerificationCompleted,
    required AuthFailureCallback onVerificationFailed,
    required PhoneCodeSentCallback onCodeSent,
    required PhoneTimeoutCallback onCodeAutoRetrievalTimeout,
    int? resendToken,
  }) {
    return repository.requestPhoneSignUpOtp(
      phoneNumber: phoneNumber,
      displayName: displayName,
      onVerificationCompleted: onVerificationCompleted,
      onVerificationFailed: onVerificationFailed,
      onCodeSent: onCodeSent,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      resendToken: resendToken,
    );
  }
}
