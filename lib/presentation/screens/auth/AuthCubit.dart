import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState(status: AuthStatus.initial)) {
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: userCredential.user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  Future<void> signUp({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(fullName);
      // Optionally save additional user data (username, phone) to Firestore
      emit(state.copyWith(status: AuthStatus.authenticated, user: userCredential.user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    emit(const AuthState(status: AuthStatus.initial));
  }
}