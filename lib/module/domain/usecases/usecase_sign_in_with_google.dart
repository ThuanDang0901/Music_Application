import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class SignInWithGoogleUseCase {
  final IAuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<AuthUser> execute() => repository.signInWithGoogle();
}
