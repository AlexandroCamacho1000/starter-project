import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthBloc({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard(),
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<Authenticated>(_onAuthenticated);
    on<UnAuthenticated>(_onUnAuthenticated);
    
    // Escuchar cambios de autenticación de Firebase
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        add(Authenticated(user.uid));
      } else {
        add(UnAuthenticated());
      }
    });
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      // El listener authStateChanges manejará el cambio de estado
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Error de autenticación'));
    } catch (e) {
      emit(AuthError('Error desconocido: $e'));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(AuthUnAuthenticated());
        return;
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      // El listener authStateChanges manejará el cambio de estado
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Error con Google Sign-In'));
    } catch (e) {
      emit(AuthError('Error desconocido: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    emit(AuthUnAuthenticated());
  }

  void _onAuthenticated(
    Authenticated event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthAuthenticated(event.userId));
  }

  void _onUnAuthenticated(
    UnAuthenticated event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthUnAuthenticated());
  }
}