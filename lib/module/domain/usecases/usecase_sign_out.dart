import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class SignOutUseCase {
  final IAuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> execute() => repository.signOut();
}
