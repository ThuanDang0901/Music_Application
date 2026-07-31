import 'package:flutter/material.dart';
import 'package:flutter_application_1/module/data/repositories/auth_repository_impl.dart';
import 'package:flutter_application_1/module/data/repositories/music_repositories_impl.dart';
import 'package:flutter_application_1/module/data/services/auth_service.dart';
import 'package:flutter_application_1/module/data/services/jamendo_api_service.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_get_current_auth_user.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_get_music.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_observe_auth_state_changes.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_request_phone_sign_in_otp.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_request_phone_sign_up_otp.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_resend_phone_otp.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_reset_password.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_sign_in_with_email.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_sign_in_with_facebook.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_sign_in_with_google.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_sign_out.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_sign_up_with_email.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_verify_phone_sign_in_otp.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_verify_phone_sign_up_otp.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/home_music.dart';
import 'package:flutter_application_1/module/presentation/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MusicApplication extends StatelessWidget {
  const MusicApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _createMusicCubit()..loadMusicData()),
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => _createAuthCubit()),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDark) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Music App',
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: const Color(0xFF6C5CE7),
            ),
          ),
          theme: ThemeData.light().copyWith(
            colorScheme: ThemeData.light().colorScheme.copyWith(
              primary: const Color(0xFF6C5CE7),
            ),
          ),
          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.isAuthenticated) {
          return const HomeMusic();
        }
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFF6C5CE7),
                ),
              ),
            ),
          );
        }
        return const LoginPage();
      },
    );
  }
}

AuthCubit _createAuthCubit() {
  final repository = AuthRepositoryImpl(authService: AuthService());

  return AuthCubit(
    observeAuthStateChangesUseCase: ObserveAuthStateChangesUseCase(repository),
    getCurrentAuthUserUseCase: GetCurrentAuthUserUseCase(repository),
    signInWithEmailUseCase: SignInWithEmailUseCase(repository),
    signUpWithEmailUseCase: SignUpWithEmailUseCase(repository),
    signInWithGoogleUseCase: SignInWithGoogleUseCase(repository),
    signInWithFacebookUseCase: SignInWithFacebookUseCase(repository),
    requestPhoneSignInOtpUseCase: RequestPhoneSignInOtpUseCase(repository),
    requestPhoneSignUpOtpUseCase: RequestPhoneSignUpOtpUseCase(repository),
    verifyPhoneSignInOtpUseCase: VerifyPhoneSignInOtpUseCase(repository),
    verifyPhoneSignUpOtpUseCase: VerifyPhoneSignUpOtpUseCase(repository),
    resendPhoneOtpUseCase: ResendPhoneOtpUseCase(repository),
    signOutUseCase: SignOutUseCase(repository),
    resetPasswordUseCase: ResetPasswordUseCase(repository),
  );
}

MusicCubit _createMusicCubit() {
  final repository = MusicRepositoriesImpl(apiService: JamendoApiService());
  return MusicCubit(getMusicUseCase: GetMusicUseCase(repository));
}
