import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class ResetPasswordUseCase {
  final IAuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute(String email) => repository.sendPasswordResetEmail(email);
}
