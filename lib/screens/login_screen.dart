import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Autenticación biométrica
        //final biometricAuth = await _authService.authenticateWithBiometrics();
       // if (!biometricAuth) {
       //   throw 'La autenticación biométrica es requerida';
       // }

        await _authService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog(e.toString());
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text;
    if (email.isEmpty) {
      _showErrorDialog('Por favor ingresa tu correo electrónico');
      return;
    }

    try {
      await _authService.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha enviado un enlace a tu correo'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                  ),
                ).animate()
                 .fadeIn(duration: 800.ms)
                 .scale(delay: 400.ms),
                
                const SizedBox(height: 40),              
                                
                Text(
                  'Inicia sesión para comenzar a entregar',
                  style: AppTheme.subtitle1,
                ).animate()
                 .fadeIn(delay: 600.ms)
                 .slideX(begin: -0.2),
                
                const SizedBox(height: 32),
                
                CustomTextField(
                  label: 'Correo electrónico',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo';
                    }
                    return null;
                  },
                ).animate()
                 .fadeIn(delay: 700.ms)
                 .slideY(begin: 0.2),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  controller: _passwordController,
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    return null;
                  },
                ).animate()
                 .fadeIn(delay: 800.ms)
                 .slideY(begin: 0.2),
                
                const SizedBox(height: 16),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate()
                 .fadeIn(delay: 900.ms),
                
                const SizedBox(height: 24),
                
                CustomButton(
                  text: 'Iniciar Sesión',
                  onPressed: _login,
                  isLoading: _isLoading,
                ).animate()
                 .fadeIn(delay: 1000.ms)
                 .slideY(begin: 0.2),
                
                const SizedBox(height: 24),
                
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: '¿Necesitas ayuda? ',
                      style: AppTheme.subtitle1,
                      children: const [
                        TextSpan(
                          text: 'Contáctanos',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate()
                 .fadeIn(delay: 1100.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}