import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class VerifyPhoneSignUpOtpUseCase {
  final IAuthRepository repository;

  VerifyPhoneSignUpOtpUseCase(this.repository);

  Future<AuthUser> execute({
    required String verificationId,
    required String smsCode,
    required String displayName,
  }) {
    return repository.signUpWithPhoneOtp(
      verificationId: verificationId,
      smsCode: smsCode,
      displayName: displayName,
    );
  }
}
