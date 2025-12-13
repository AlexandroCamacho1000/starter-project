// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart'; // SOLO este import

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navegar a Home
            Navigator.pushReplacementNamed(context, '/home');
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    
                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Por favor completa todos los campos')),
                      );
                      return;
                    }
                    
                    context.read<AuthBloc>().add(LoginRequested(
                      email: email,
                      password: password,
                    ));
                  },
                  child: Text('Login'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 20),
                // Botón de Google Sign-In
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(GoogleSignInRequested());
                  },
                  icon: Icon(Icons.g_mobiledata),
                  label: Text('Sign in with Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 20),
                // Enlace a registro
                TextButton(
                  onPressed: () {
                    // Navegar a pantalla de registro
                    // Navigator.pushNamed(context, '/register');
                  },
                  child: Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}