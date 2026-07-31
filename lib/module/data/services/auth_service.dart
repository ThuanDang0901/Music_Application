import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  static bool get isWeb => kIsWeb;

  static void _log(String tag, String message) {
    debugPrint('[AuthService][$tag] $message');
  }

  static String normalizePhoneNumber({
    required String dialCode,
    required String rawNumber,
  }) {
    String number = rawNumber.trim();
    String code = dialCode.trim();

    if (!code.startsWith('+')) code = '+$code';

    number = number.replaceAll(RegExp(r'\D'), '');

    if (number.startsWith('0')) {
      if (number.length > 1) {
        number = number.substring(1);
      } else {
        number = '';
      }
    }

    String full = '$code$number';
    _log(
      'normalizePhone',
      'Input: dial=$dialCode, raw=$rawNumber → Output: $full',
    );
    return full;
  }

  static bool isValidVietnamesePhone(String fullPhone) {
    final regex = RegExp(r'^\+84(9\d{8}|3\d{8}|5\d{8}|7\d{8}|8\d{8}|2\d{8})$');
    return regex.hasMatch(fullPhone);
  }

  static bool isValidInternationalPhone(String fullPhone) {
    final regex = RegExp(r'^\+[1-9]\d{7,14}$');
    return regex.hasMatch(fullPhone);
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _log('EmailSignIn', 'Attempt for email=${email.trim()}');
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _log(
        'EmailSignIn',
        'SUCCESS. uid=${result.user?.uid}, email=${result.user?.email}',
      );
      return result;
    } on FirebaseAuthException catch (e) {
      _log('EmailSignIn', 'ERROR code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e) {
      _log('EmailSignIn', 'Unknown error: $e');
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.',
      );
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _log('EmailSignUp', 'Attempt email=${email.trim()}, name=$displayName');
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName.trim().isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName.trim());
        await userCredential.user?.reload();
      }
      final updatedUser = _firebaseAuth.currentUser;
      _log(
        'EmailSignUp',
        'SUCCESS. uid=${updatedUser?.uid}, name=${updatedUser?.displayName}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _log('EmailSignUp', 'ERROR code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e) {
      _log('EmailSignUp', 'Unknown error: $e');
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.',
      );
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    _log(
      'GoogleSignIn',
      'Starting. platform=$isWeb (${isWeb ? 'WEB - GIS client from google_sign_in_web via firebase_options.dart' : 'native'})',
    );
    try {
      final GoogleSignIn googleSignIn = isWeb
          ? GoogleSignIn(
              clientId:
                  '918063011490-5m0hvn0u8sklq72b1f3mkgead26vf1pm.apps.googleusercontent.com',
            )
          : GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _log('GoogleSignIn', 'Cancelled by user (null account returned)');
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Đăng nhập Google đã bị hủy.',
        );
      }
      _log(
        'GoogleSignIn',
        'Account selected: ${googleUser.email}, id=${googleUser.id}',
      );

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if ((googleAuth.idToken == null || googleAuth.idToken!.isEmpty) &&
          isWeb) {
        _log(
          'GoogleSignIn',
          '⚠️ WEB: idToken is EMPTY. Almost certainly placeholder Google Web Client ID OR Authorized JavaScript origins missing.',
        );
        throw FirebaseAuthException(
          code: 'gsi-invalid-client',
          message:
              'Google Web Client ID đang là placeholder. Xem hướng dẫn chi tiết ở ô hướng dẫn.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      _log(
        'GoogleSignIn',
        'SUCCESS. uid=${result.user?.uid}, displayName=${result.user?.displayName}, providerId=${result.additionalUserInfo?.providerId}',
      );
      return result;
    } on FirebaseAuthException catch (e) {
      // Rethrow specific codes we intentionally threw
      if (e.code == 'aborted-by-user' ||
          e.code == 'gsi-invalid-client' ||
          e.code == 'gsi-popup-closed') {
        rethrow;
      }
      // Detect error messages from google_sign_in_web that say "popup_closed" (gis_client.dart)
      if (e.message != null &&
          (e.message!.toLowerCase().contains('popup_closed') ||
              e.message!.toLowerCase().contains('popup closed'))) {
        throw FirebaseAuthException(
          code: 'popup-closed-by-user',
          message: 'Bạn đã đóng popup đăng nhập Google.',
        );
      }
      // Detect 401 invalid_client via code/message
      if ((e.code == 'invalid-credential' ||
              e.code == 'unknown-error' ||
              e.code == 'google-sign-in-failed') &&
          (e.message ?? '').toLowerCase().contains('invalid_client')) {
        throw FirebaseAuthException(
          code: 'gsi-invalid-client',
          message: 'Google OAuth trả về 401 invalid_client.',
        );
      }
      _log('GoogleSignIn', 'ERROR code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e, stack) {
      _log('GoogleSignIn', 'Unknown error: $e, stack=$stack');
      final es = e.toString().toLowerCase();
      if (es.contains('popup_closed') || es.contains('popup closed')) {
        throw FirebaseAuthException(
          code: 'popup-closed-by-user',
          message: 'Bạn đã đóng cửa sổ đăng nhập Google.',
        );
      }
      if (es.contains('invalid_client') ||
          es.contains('401') ||
          es.contains('oauth client was not found')) {
        throw FirebaseAuthException(
          code: 'gsi-invalid-client',
          message:
              'Google Sign In Web Client ID bị lỗi (placeholder / origins chưa đúng).',
        );
      }
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message:
            'Đăng nhập Google thất bại. Chi tiết: $e. Vui lòng kiểm tra cấu hình Google trên Firebase Console.',
      );
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    _log(
      'FacebookSignIn',
      'Starting. platform=$isWeb (${isWeb ? 'WEB - needs App ID + webInitialize (main.dart) + SDK script (index.html) + Tracking Prevention OFF' : 'native'})',
    );
    try {
      if (isWeb) {
        // Safety check: ensure webInitialize was really called. If not, retry.
        try {
          final access = await FacebookAuth.instance.accessToken;
          _log('FacebookSignIn', 'Pre-check accessToken: $access');
        } catch (e) {
          _log(
            'FacebookSignIn',
            '⚠️ Web access token pre-check failed = SDK not initialized, trying manual webInitialize: $e',
          );
          try {
            final fbAuth = FacebookAuth.instance as dynamic;
            try {
              await fbAuth.webInitialize(
                appId: '1058757830434791',
                cookie: true,
                xfbml: true,
                version: 'v20.0',
              );
            } on NoSuchMethodError catch (_) {
              await fbAuth.webAndDesktopInitialize(
                appId: '1058757830434791',
                cookie: true,
                xfbml: true,
                version: 'v20.0',
              );
            }
          } catch (_) {}
        }
      }

      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      _log(
        'FacebookSignIn',
        'LoginResult status=${loginResult.status}, message=${loginResult.message}',
      );

      if (loginResult.status == LoginStatus.cancelled) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Đăng nhập Facebook đã bị hủy.',
        );
      }

      if (loginResult.status != LoginStatus.success) {
        final msg = loginResult.message ?? '';
        if (msg.toLowerCase().contains('window.fb is undefined') ||
            msg.toLowerCase().contains('fb is not defined') ||
            msg.toLowerCase().contains('sdk not loaded')) {
          throw FirebaseAuthException(code: 'fb-sdk-not-loaded', message: msg);
        }
        if (msg.toLowerCase().contains('tracking prevention') ||
            msg.toLowerCase().contains('storage for') ||
            msg.toLowerCase().contains('blocked access to storage')) {
          throw FirebaseAuthException(
            code: 'third-party-cookies-blocked',
            message: msg,
          );
        }
        throw FirebaseAuthException(
          code: 'facebook-sign-in-failed',
          message: loginResult.message ?? 'Đăng nhập Facebook thất bại.',
        );
      }

      if (loginResult.accessToken == null) {
        throw FirebaseAuthException(
          code: 'fb-sdk-not-loaded',
          message:
              'Facebook access token null. Kiểm tra App ID cấu hình và Tracking Prevention Edge.',
        );
      }

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      final result = await _firebaseAuth.signInWithCredential(
        facebookAuthCredential,
      );
      _log(
        'FacebookSignIn',
        'SUCCESS. uid=${result.user?.uid}, name=${result.user?.displayName}',
      );
      return result;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'aborted-by-user' ||
          e.code == 'fb-sdk-not-loaded' ||
          e.code == 'third-party-cookies-blocked') {
        rethrow;
      }
      // Detect "window.FB is undefined" from message (plugin returns this in message)
      final msg = e.message ?? '';
      if (msg.toLowerCase().contains('window.fb is undefined') ||
          msg.toLowerCase().contains('fb is not defined')) {
        throw FirebaseAuthException(code: 'fb-sdk-not-loaded', message: msg);
      }
      if (msg.toLowerCase().contains('tracking prevention') ||
          msg.toLowerCase().contains('blocked access to storage')) {
        throw FirebaseAuthException(
          code: 'third-party-cookies-blocked',
          message: msg,
        );
      }
      _log('FacebookSignIn', 'ERROR code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e, stack) {
      _log('FacebookSignIn', 'Unknown error: $e, stack=$stack');
      final es = e.toString().toLowerCase();
      if (es.contains('window.fb is undefined') ||
          es.contains('fb is not defined') ||
          es.contains('no firebase app') && es.contains('facebook')) {
        throw FirebaseAuthException(
          code: 'fb-sdk-not-loaded',
          message: e.toString(),
        );
      }
      if (es.contains('tracking prevention') ||
          es.contains('storage for') ||
          es.contains('blocked access to storage')) {
        throw FirebaseAuthException(
          code: 'third-party-cookies-blocked',
          message: e.toString(),
        );
      }
      if (e is FirebaseAuthException) rethrow;
      throw FirebaseAuthException(
        code: 'facebook-sign-in-failed',
        message:
            'Đăng nhập Facebook thất bại (Chi tiết: $e). Vui lòng kiểm tra App ID và Facebook Developers console.',
      );
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
    int? resendToken,
  }) async {
    _log(
      'PhoneVerify',
      'Starting. phone=$phoneNumber, platform=$isWeb (${isWeb ? 'WEB - requires reCAPTCHA + Whitelist domain in Firebase console' : 'native - requires SHA-1/SHA-256 in Firebase project settings'})',
    );

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: timeout,
        forceResendingToken: resendToken,
      );
      _log(
        'PhoneVerify',
        'verifyPhoneNumber() call completed. Awaiting callback (codeSent/verificationFailed/...)',
      );
    } on FirebaseAuthException catch (e) {
      _log('PhoneVerify', 'ERROR code=${e.code}, message=${e.message}');
      if (isWeb &&
          (e.code == 'web-context-cancelled' ||
              e.code == 'captcha-check-failed')) {
        throw FirebaseAuthException(
          code: 'captcha-check-failed',
          message:
              'Bạn chưa hoàn thành xác minh reCAPTCHA. Vui lòng bật popup và làm theo hướng dẫn. Hoặc kiểm tra tên miền của bạn đã được thêm vào Firebase Console → Authentication → Settings → Authorized domains chưa.',
        );
      }
      rethrow;
    } catch (e) {
      _log('PhoneVerify', 'Unknown error: $e');
      throw FirebaseAuthException(
        code: 'phone-verification-error',
        message:
            'Xác thực số điện thoại thất bại. Vui lòng kiểm tra định dạng (+84xxx) và thử lại. Chi tiết: $e',
      );
    }
  }

  Future<UserCredential> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    _log(
      'PhoneSignIn',
      'Attempt. verificationId length=${verificationId.length}, smsCode length=${smsCode.length}',
    );
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _firebaseAuth.signInWithCredential(credential);
      _log(
        'PhoneSignIn',
        'SUCCESS. uid=${result.user?.uid}, phone=${result.user?.phoneNumber}',
      );
      return result;
    } on FirebaseAuthException catch (e) {
      _log('PhoneSignIn', 'ERROR code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e) {
      _log('PhoneSignIn', 'Unknown error: $e');
      throw FirebaseAuthException(
        code: 'phone-sign-in-failed',
        message: 'Xác thực OTP thất bại. Vui lòng thử lại.',
      );
    }
  }

  Future<UserCredential> signInWithPhoneCredentialObject({
    required PhoneAuthCredential credential,
  }) async {
    _log(
      'PhoneSignIn',
      'Attempt with auto credential. verificationId=${credential.verificationId}',
    );
    try {
      final result = await _firebaseAuth.signInWithCredential(credential);
      _log(
        'PhoneSignIn',
        'SUCCESS(auto). uid=${result.user?.uid}, phone=${result.user?.phoneNumber}',
      );
      return result;
    } on FirebaseAuthException catch (e) {
      _log('PhoneSignIn', 'AUTO ERROR code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e) {
      _log('PhoneSignIn', 'Unknown auto sign-in error: $e');
      throw FirebaseAuthException(
        code: 'phone-sign-in-failed',
        message: 'Xác thực OTP tự động thất bại. Vui lòng thử lại.',
      );
    }
  }

  Future<UserCredential> signUpWithPhone({
    required String verificationId,
    required String smsCode,
    required String displayName,
  }) async {
    _log(
      'PhoneSignUp',
      'Attempt with displayName=$displayName, code length=${smsCode.length}',
    );
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (displayName.trim().isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName.trim());
        await userCredential.user?.reload();
      }

      final u = _firebaseAuth.currentUser;
      _log(
        'PhoneSignUp',
        'SUCCESS. uid=${u?.uid}, name=${u?.displayName}, phone=${u?.phoneNumber}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _log('PhoneSignUp', 'ERROR code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e) {
      _log('PhoneSignUp', 'Unknown error: $e');
      throw FirebaseAuthException(
        code: 'phone-sign-up-failed',
        message: 'Đăng ký bằng số điện thoại thất bại. Vui lòng thử lại.',
      );
    }
  }

  Future<UserCredential> signUpWithPhoneCredentialObject({
    required PhoneAuthCredential credential,
    required String displayName,
  }) async {
    _log(
      'PhoneSignUp',
      'Attempt auto sign-up with displayName=$displayName, verificationId=${credential.verificationId}',
    );
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (displayName.trim().isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName.trim());
        await userCredential.user?.reload();
      }

      final u = _firebaseAuth.currentUser;
      _log(
        'PhoneSignUp',
        'SUCCESS(auto). uid=${u?.uid}, name=${u?.displayName}, phone=${u?.phoneNumber}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _log('PhoneSignUp', 'AUTO ERROR code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e) {
      _log('PhoneSignUp', 'Unknown auto sign-up error: $e');
      throw FirebaseAuthException(
        code: 'phone-sign-up-failed',
        message: 'Đăng ký tự động bằng số điện thoại thất bại.',
      );
    }
  }

  Future<void> signOut() async {
    _log('SignOut', 'Starting...');
    try {
      await _firebaseAuth.signOut();
      try {
        await GoogleSignIn().signOut();
      } catch (ge) {
        _log('SignOut', 'Google signOut skip: $ge');
      }
      try {
        if (!kIsWeb) {
          await FacebookAuth.instance.logOut();
        }
      } catch (fe) {
        _log('SignOut', 'Facebook logOut skip: $fe');
      }
      _log('SignOut', 'SUCCESS. currentUser=${_firebaseAuth.currentUser}');
    } on FirebaseAuthException catch (e) {
      _log('SignOut', 'ERROR code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e) {
      _log('SignOut', 'Unknown error: $e');
      throw FirebaseAuthException(
        code: 'sign-out-failed',
        message: 'Đăng xuất thất bại. Vui lòng thử lại.',
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _log('PasswordReset', 'Request for email=${email.trim()}');
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      _log('PasswordReset', 'SUCCESS - email sent to ${email.trim()}');
    } on FirebaseAuthException catch (e) {
      _log('PasswordReset', 'ERROR code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e) {
      _log('PasswordReset', 'Unknown error: $e');
      throw FirebaseAuthException(
        code: 'password-reset-failed',
        message: 'Gửi email đặt lại mật khẩu thất bại.',
      );
    }
  }
}
