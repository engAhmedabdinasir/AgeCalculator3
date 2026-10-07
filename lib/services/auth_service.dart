import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service handling sign up, sign in, and sign out with Supabase Auth.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  SupabaseClient get _client => Supabase.instance.client;

  /// Currently logged in user, or null.
  User? get currentUser => _client.auth.currentUser;

  /// Current session, or null.
  Session? get currentSession => _client.auth.currentSession;

  /// Stream of auth state changes.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Resend the confirmation email for an unverified account.
  Future<void> resendConfirmation({required String email}) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
    );
  }
}
