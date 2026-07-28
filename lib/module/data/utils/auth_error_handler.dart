import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorHandler {
  static String getErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'email-already-in-use':
        return 'Email này đã được sử dụng cho tài khoản khác. Vui lòng sử dụng email khác hoặc đăng nhập bằng email này.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ. Vui lòng kiểm tra lại.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được kích hoạt. Vui lòng liên hệ quản trị viên.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Mật khẩu cần có ít nhất 6 ký tự.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa. Vui lòng liên hệ hỗ trợ.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này. Vui lòng kiểm tra lại hoặc đăng ký tài khoản mới.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác. Vui lòng thử lại hoặc nhấp "Quên mật khẩu".';
      case 'invalid-credential':
        return 'Thông tin xác thực không hợp lệ. Vui lòng kiểm tra lại.';
      case 'invalid-verification-code':
        return 'Mã xác thực OTP không chính xác. Vui lòng kiểm tra lại tin nhắn.';
      case 'invalid-verification-id':
        return 'Phiên xác thực đã hết hạn. Vui lòng yêu cầu gửi lại mã OTP.';
      case 'phone-number-already-exists':
        return 'Số điện thoại này đã được đăng ký cho tài khoản khác.';
      case 'quota-exceeded':
        return 'Vượt quá giới hạn số lần gửi SMS. Vui lòng thử lại sau vài phút.';
      case 'session-expired':
        return 'Phiên làm việc đã hết hạn. Vui lòng thực hiện lại.';
      case 'timeout':
        return 'Thời gian chờ đã hết. Vui lòng kiểm tra kết nối mạng và thử lại.';
      case 'too-many-requests':
        return 'Bạn đã thực hiện quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet.';
      case 'captcha-check-failed':
        return 'Xác thực Captcha thất bại. Vui lòng thử lại.';
      case 'app-not-authorized':
        return 'Ứng dụng không được phép xác thực. Vui lòng liên hệ quản trị viên.';
      case 'invalid-app-credential':
        return 'Thông tin xác thực ứng dụng không hợp lệ.';
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã tồn tại với phương thức đăng nhập khác. Vui lòng sử dụng phương thức đăng nhập tương ứng.';
      case 'credential-already-in-use':
        return 'Thông tin xác thực này đã được sử dụng cho tài khoản khác.';
      case 'provider-already-linked':
        return 'Tài khoản này đã được liên kết với nhà cung cấp này.';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để thực hiện thao tác này.';
      case 'user-mismatch':
        return 'Thông tin người dùng không khớp với phiên đăng nhập hiện tại.';
      case 'aborted-by-user':
        return exception.message ?? 'Đăng nhập đã bị hủy bởi người dùng.';
      case 'google-sign-in-failed':
        return exception.message ?? 'Đăng nhập Google thất bại. Vui lòng thử lại.';
      case 'facebook-sign-in-failed':
        return exception.message ?? 'Đăng nhập Facebook thất bại. Vui lòng thử lại.';
      case 'phone-verification-error':
        return exception.message ?? 'Xác thực số điện thoại thất bại. Vui lòng thử lại.';
      case 'phone-sign-in-failed':
        return exception.message ?? 'Đăng nhập bằng số điện thoại thất bại.';
      case 'phone-sign-up-failed':
        return exception.message ?? 'Đăng ký bằng số điện thoại thất bại.';
      case 'password-reset-failed':
        return exception.message ?? 'Gửi email đặt lại mật khẩu thất bại.';
      case 'gsi-invalid-client':
      case 'invalid-oauth-client':
        return '🔧 Lỗi cấu hình Google Sign In (401 invalid_client).'
            '\n👉 Cách sửa (CHỈ NHẤT 1 TRONG 2 CÁCH):'
            '\nA) Khuyến nghị: Mở Terminal, chạy: dart pub global activate flutterfire_cli ; flutterfire configure'
            '\nB) Manual: Firebase Console → Authentication → Sign-in method → Google → Web SDK configuration → Copy "Web client ID" có dạng xxx.apps.googleusercontent.com →'
            '\n   - Web: dán vào google_sign_in() constructor qua GoogleSignIn(clientId: "...")'
            '\n   - VÀ kiểm tra Google Cloud → APIs & Services → Credentials → Web Client → Authorized JavaScript origins: THÊM http://localhost:<CỔNG_DEV> (vd http://localhost:64552) và domain thật.'
            '\n   - VÀ Authorized redirect URIs phải chứa Firebase Auth callback URI.';
      case 'popup-closed-by-user':
      case 'gsi-popup-closed':
        return 'Bạn đã đóng cửa sổ đăng nhập Google trước khi hoàn tất. Vui lòng nhấn lại nút Google và chọn tài khoản.';
      case 'fb-sdk-not-loaded':
        return '🔧 Facebook SDK không tải được (window.FB is undefined).'
            '\n👉 Cách sửa, làm theo thứ tự:'
            '\n1) TẮT Edge Tracking Prevention (hoặc "Allow site"): Nhấn hình lá chắn 🛡️ bên trái address bar Edge → Tracking Prevention → OFF (hoặc tạo Exception Allow cho localhost)'
            '\n2) Kiểm tra tường lửa/Proxy cho phép truy cập connect.facebook.net (F12 Network Tab xem sdk.js có 200 OK không?)'
            '\n3) Kiểm tra App ID: developers.facebook.com → Your App → Basic Settings → App ID → dán vào 2 nơi:'
            '\n   - web/index.html: URL sdk.js?appId=YOUR_APP_ID'
            '\n   - lib/main.dart hàm _initWebAuthProviders(): FacebookAuth.instance.webInitialize(appId: "YOUR_APP_ID")'
            '\n4) Facebook App → Settings → Basic → Add Platform Web với Site URL http://localhost:<cổng> và domain thật'
            '\n5) Facebook App → Products → Facebook Login → Settings → Valid OAuth Redirect URIs: thêm URI từ Firebase Auth SignIn method Facebook.';
      case 'third-party-cookies-blocked':
        return '🛡️ Trình duyệt đang CHẶN cookie/bộ nhớ của bên thứ ba (3rd-party cookies / storage):'
            '\n- Edge: Bấm hình lá chắn 🛡️ ở thanh địa chỉ → Turn off Tracking Prevention for this site'
            '\n- Chrome: Thanh địa chỉ → biểu tượng mắt 🚫 → Cookies cho trang này → Always allow → reload'
            '\nSau đó tải lại trang (Ctrl+R).';
      case 'unknown-error':
      default:
        return exception.message ?? 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.';
    }
  }

  static bool isNetworkError(FirebaseAuthException exception) {
    return exception.code == 'network-request-failed' ||
        exception.code == 'timeout';
  }
}
