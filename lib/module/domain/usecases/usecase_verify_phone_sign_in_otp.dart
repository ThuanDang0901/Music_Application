import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class VerifyPhoneSignInOtpUseCase {
  final IAuthRepository repository;

  VerifyPhoneSignInOtpUseCase(this.repository);

  Future<AuthUser> execute({
    required String verificationId,
    required String smsCode,
  }) {
    return repository.signInWithPhoneOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
