import 'package:flutter_application_1/module/domain/entities/auth_user.dart';
import 'package:flutter_application_1/module/domain/repositories/auth_repo.dart';

class GetCurrentAuthUserUseCase {
  final IAuthRepository repository;

  GetCurrentAuthUserUseCase(this.repository);

  AuthUser? execute() => repository.currentUser;
}
