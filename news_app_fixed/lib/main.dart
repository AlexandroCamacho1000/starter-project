import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

// ============================================================================
// TODO EN UNO - VERSIÓN COMPATIBLE
// ============================================================================

abstract class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email, password;
  LoginRequested({required this.email, required this.password});
}
class GoogleSignInRequested extends AuthEvent {}
class LogoutRequested extends AuthEvent {}

abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String userId;
  AuthAuthenticated(this.userId);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
class AuthUnAuthenticated extends AuthState {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ✅ PARA google_sign_in 6.1.5
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(email: event.email, password: event.password);
      emit(AuthAuthenticated(_auth.currentUser!.uid));
    } catch (e) {
      emit(AuthError('Error: $e'));
    }
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // ✅ FUNCIONA CON 6.1.5
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        emit(AuthUnAuthenticated());
        return;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      await _auth.signInWithCredential(credential);
      emit(AuthAuthenticated(_auth.currentUser!.uid));
    } catch (e) {
      emit(AuthError('Error Google: $e'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    emit(AuthUnAuthenticated());
  }
}

class ArticleBloc extends Bloc<dynamic, dynamic> {
  ArticleBloc() : super(null);
}

// ============================================================================
// PANTALLAS SIMPLIFICADAS (SIN Google Fonts por ahora)
// ============================================================================

class LoginScreen extends StatelessWidget {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _email,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_email.text.isEmpty || _password.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Llena los campos')),
                    );
                    return;
                  }
                  context.read<AuthBloc>().add(
                    LoginRequested(email: _email.text, password: _password.text),
                  );
                },
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<AuthBloc>().add(GoogleSignInRequested()),
                child: Text('Login con Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¡Bienvenido!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Usuario: ${FirebaseAuth.instance.currentUser?.email ?? "No email"}'),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// APP PRINCIPAL SIMPLIFICADA
// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('✅ Firebase OK');
  } catch (e) {
    print('❌ Firebase error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<ArticleBloc>(create: (context) => ArticleBloc()),
      ],
      child: MaterialApp(
        title: 'News App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snapshot.hasData ? HomePage() : LoginScreen();
          },
        ),
      ),
    );
  }
}