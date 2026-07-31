import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class SignInWithEmailUseCase {
  final IAuthRepository repository;

  SignInWithEmailUseCase(this.repository);

  Future<AuthUser> execute({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
