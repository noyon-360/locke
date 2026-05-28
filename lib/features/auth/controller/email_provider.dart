import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailVerifyState {
  final String email;
  final bool isLoading;
  final bool isEmailSent;
  final bool isVerified;
  final String? error;

  EmailVerifyState({
    required this.email,
    required this.isLoading,
    required this.isEmailSent,
    required this.isVerified,
    this.error,
  });

  // Copywith method for immutability
  EmailVerifyState copyWith({
    String? email,
    bool? isLoading,
    bool? isEmailSent,
    bool? isVerified,
    String? error,
  }) => EmailVerifyState(
    email: email ?? this.email,
    isLoading: isLoading ?? this.isLoading,
    isEmailSent: isEmailSent ?? this.isEmailSent,
    isVerified: isVerified ?? this.isVerified,
    error: error ?? this.error,
  );
}

class EmailVerifyNotifier extends Notifier<EmailVerifyState> {
  @override
  EmailVerifyState build() => EmailVerifyState(
    email: '',
    isLoading: false,
    isEmailSent: false,
    isVerified: false,
    error: null,
  );

  void emailChanged(String email) {
    state = state.copyWith(email: email, error: null);
    debugPrint('Email updated: $email');
  }


}
