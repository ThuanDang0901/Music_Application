import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class SignUpWithEmailUseCase {
  final IAuthRepository repository;

  SignUpWithEmailUseCase(this.repository);

  Future<AuthUser> execute({
    required String email,
    required String password,
    required String displayName,
  }) {
    return repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
