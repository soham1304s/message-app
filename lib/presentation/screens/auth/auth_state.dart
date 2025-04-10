import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({required this.status, this.user, this.error});

  AuthState copyWith({AuthStatus? status, User? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, user, error];
}