import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth state. Mock: any valid input logs in.
class AuthState {
  const AuthState({this.isLoggedIn = false, this.email});

  final bool isLoggedIn;
  final String? email;

  AuthState copyWith({bool? isLoggedIn, String? email}) => AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        email: email ?? this.email,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String emailOrId, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(isLoggedIn: true, email: emailOrId);
  }

  void logout() => state = const AuthState();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
