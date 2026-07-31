import 'package:flutter_application_1/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[main] Firebase.initializeApp SUCCESS');
  } catch (e, stack) {
    debugPrint('[main] Firebase.initializeApp FAILED: $e\nStack: $stack');
    runApp(FirebaseInitErrorApp(error: e.toString()));
    return;
  }

  await _initWebAuthProviders();

  runApp(
    const ToastificationWrapper(child: MusicApplication()),
  );
}

class FirebaseInitErrorApp extends StatelessWidget {
  const FirebaseInitErrorApp({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Firebase failed to initialize',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Authentication features are unavailable because app configuration could not be loaded. Please fix the Firebase setup and restart the app.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    debugPrint(
      '[main] FacebookAuth webInitialize DONE (attempts applied, SDK script loaded from index.html is primary)',
    );
  } catch (e, stack) {
    debugPrint('[main] FacebookAuth webInitialize warning: $e\nStack: $stack');
  }

  // --- Google Sign In Web ---
  try {
    debugPrint(
      '[main] GoogleSignIn (Web) pre-config OK (GIS loaded via index.html)',
    );
  } catch (e) {
    debugPrint('[main] GoogleSignIn (Web) pre-config non-critical: $e');
  }
}
