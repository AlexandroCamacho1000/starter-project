// lib/presentation/pages/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          _showErrorDialog(state.message);
          setState(() => _isLoading = false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  
                  // Logo & Welcome
                  _buildHeader(),
                  const SizedBox(height: 48),
                  
                  // Login Form
                  _buildLoginForm(),
                  const SizedBox(height: 32),
                  
                  // Login Button
                  _buildLoginButton(),
                  const SizedBox(height: 24),
                  
                  // Divider
                  _buildDivider(),
                  const SizedBox(height: 24),
                  
                  // Google Sign In
                  _buildGoogleSignInButton(),
                  const SizedBox(height: 32),
                  
                  // Register Link
                  _buildRegisterLink(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppThemes.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.article_rounded,
            size: 40,
            color: AppThemes.primaryBlue,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppThemes.textBlack,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your journalism journey',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppThemes.textGray,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              labelStyle: GoogleFonts.inter(color: AppThemes.textGray),
              prefixIcon: Icon(Icons.email_outlined, color: AppThemes.textGray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppThemes.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppThemes.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppThemes.primaryBlue, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: GoogleFonts.inter(color: AppThemes.textBlack),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: GoogleFonts.inter(color: AppThemes.textGray),
              prefixIcon: Icon(Icons.lock_outline, color: AppThemes.textGray),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppThemes.textGray,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppThemes.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppThemes.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppThemes.primaryBlue, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: GoogleFonts.inter(color: AppThemes.textBlack),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          
          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.inter(
                  color: AppThemes.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemes.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              'Sign In',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppThemes.borderLight,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: GoogleFonts.inter(
              color: AppThemes.textGray,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppThemes.borderLight,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return OutlinedButton(
      onPressed: _isLoading ? null : _signInWithGoogle,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppThemes.borderLight, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/google_logo.png', // Necesitas añadir este asset
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Sign in with Google',
            style: GoogleFonts.inter(
              color: AppThemes.textBlack,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.inter(
            color: AppThemes.textGray,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: _isLoading ? null : _goToRegister,
          child: Text(
            'Sign up',
            style: GoogleFonts.inter(
              color: AppThemes.primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _signInWithGoogle() {
    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }

  void _goToRegister() {
    // Navegar a pantalla de registro
    // Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  void _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      _showErrorDialog('Please enter your email first');
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Sending reset email...'),
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Please wait'),
          ],
        ),
      ),
    );
    
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      
      Navigator.pop(context); // Cerrar loading
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Email Sent',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Check your email for password reset instructions.',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GoogleFonts.inter(color: AppThemes.primaryBlue)),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      _showErrorDialog('Failed to send reset email: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppThemes.textBlack,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(color: AppThemes.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(color: AppThemes.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}