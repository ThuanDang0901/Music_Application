import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/module/data/repositories/music_repositories_impl.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_get_music.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/home_music.dart';
import 'package:flutter_application_1/module/presentation/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[main] Firebase.initializeApp SUCCESS');
  } catch (e) {
    debugPrint('[main] Firebase init warning (using placeholder config): $e');
  }

  await _initWebAuthProviders();

  final repository = MusicRepositoriesImpl();
  final getMusicUseCase = GetMusicUseCase(repository);

  runApp(
    ToastificationWrapper(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                MusicCubit(getMusicUseCase: getMusicUseCase)..loadMusicData(),
          ),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(create: (context) => AuthCubit()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

/// Khởi tạo Web-Specific Auth (Google/Facebook). Trên native không làm gì.
Future<void> _initWebAuthProviders() async {
  if (!kIsWeb) return;

  // --- Facebook Auth Web init (BẮT BUỘC theo flutter_facebook_auth docs) ---
  try {
    debugPrint('[main] FacebookAuth webInitialize start (isWeb=$kIsWeb)');
    final fbAuth = FacebookAuth.instance as dynamic;
    // Try both known signatures: webInitialize (old <7) & webAndDesktopInitialize (7.x+)
    bool initOk = false;
    try {
      await fbAuth.webInitialize(
        appId: '1058757830434791',
        cookie: true,
        xfbml: true,
        version: 'v20.0',
      );
      initOk = true;
    } on NoSuchMethodError catch (_) {
      // ignore: empty_catches
    }
    if (!initOk) {
      try {
        await fbAuth.webAndDesktopInitialize(
          appId: '1058757830434791',
          cookie: true,
          xfbml: true,
          version: 'v20.0',
        );
        initOk = true;
      } on NoSuchMethodError catch (_) {
        // ignore: empty_catches
      }
    }
    debugPrint('[main] FacebookAuth webInitialize DONE (attempts applied, SDK script loaded from index.html is primary)');
  } catch (e, stack) {
    debugPrint('[main] FacebookAuth webInitialize warning: $e\nStack: $stack');
  }

  // --- Google Sign In Web ---
  try {
    debugPrint('[main] GoogleSignIn (Web) pre-config OK (GIS loaded via index.html)');
  } catch (e) {
    debugPrint('[main] GoogleSignIn (Web) pre-config non-critical: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        if (state is AuthAuthenticated) {
          return const HomeMusic();
        }
        if (state is AuthLoading) {
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
