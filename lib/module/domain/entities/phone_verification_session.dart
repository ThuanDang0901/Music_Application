import 'package:equatable/equatable.dart';

class PhoneVerificationSession extends Equatable {
  final String verificationId;
  final String phoneNumber;
  final bool isSignUp;
  final String? displayName;
  final int? resendToken;

  const PhoneVerificationSession({
    required this.verificationId,
    required this.phoneNumber,
    required this.isSignUp,
    this.displayName,
    this.resendToken,
  });

  PhoneVerificationSession copyWith({
    String? verificationId,
    String? phoneNumber,
    bool? isSignUp,
    String? displayName,
    int? resendToken,
  }) {
    return PhoneVerificationSession(
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSignUp: isSignUp ?? this.isSignUp,
      displayName: displayName ?? this.displayName,
      resendToken: resendToken ?? this.resendToken,
    );
  }

  @override
  List<Object?> get props => [
        verificationId,
        phoneNumber,
        isSignUp,
        displayName,
        resendToken,
      ];
}
