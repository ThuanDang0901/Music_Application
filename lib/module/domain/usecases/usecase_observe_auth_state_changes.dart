import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class ObserveAuthStateChangesUseCase {
  final IAuthRepository repository;

  ObserveAuthStateChangesUseCase(this.repository);

  Stream<AuthUser?> execute() => repository.authStateChanges();
}
