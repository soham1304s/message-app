import 'package:chatting_app/core/common/custom_button.dart';
import 'package:chatting_app/core/common/custom_text_field.dart';
import 'package:chatting_app/core/utils/ui_utils.dart';
import 'package:chatting_app/data/services/service_locator.dart';
import 'package:chatting_app/logic/cubits/auth/auth_cubit.dart';
import 'package:chatting_app/logic/cubits/auth/auth_state.dart';
import 'package:chatting_app/presentation/home/home_screen.dart';
import 'package:chatting_app/presentation/screens/auth/signup_screen.dart';
import 'package:chatting_app/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleSignIn() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      await getIt<AuthCubit>().signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          getIt<AppRouter>().pushAndRemoveUntil(const HomeScreen());
        } else if (state.status == AuthStatus.error && state.error != null) {
          UiUtils.showSnackBar(context, message: state.error!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "Welcome Back",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sign in to continue",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: emailController,
                      hintText: "Email",
                      validator: _validateEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: passwordController,
                      hintText: "Password",
                      validator: _validatePassword,
                      obscureText: !_isPasswordVisible,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        },
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      onPressed: handleSignIn,
                      child: state.status == AuthStatus.loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Login", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: "Sign up",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  getIt<AppRouter>().push(const SignupScreen());
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
