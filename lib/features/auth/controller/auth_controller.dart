import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final int masterPassword;

  AuthState({required this.masterPassword});
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState(masterPassword: 0);
  }

  void setMasterPassword(int password) {
    state = AuthState(masterPassword: password);
  }
  
}