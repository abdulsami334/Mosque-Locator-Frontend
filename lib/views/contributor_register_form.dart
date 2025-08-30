import 'package:flutter/material.dart';
import 'package:mosque_locator/models/user_model.dart';
import 'package:mosque_locator/providers/mosque_provider.dart';
import 'package:mosque_locator/providers/user_provider.dart';
import 'package:mosque_locator/utils/app_assets.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class AuthView extends StatefulWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool isLogin = true; // toggle between login and signup

  // Login controllers
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Signup controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _areaCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _login(AuthProvider userProvider, MosqueProvider mosqueProvider) async {
    if (!_loginFormKey.currentState!.validate()) return;

    final success = await userProvider.loginContributor(
      _loginEmailCtrl.text.trim(),
      _loginPassCtrl.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Logged in successfully!' : (userProvider.errorMessage ?? 'Login failed')),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      mosqueProvider.setToken(userProvider.token!);
      Navigator.pushReplacementNamed(context, '/Navigation');
    }
  }

  Future<void> _signup(AuthProvider userProvider) async {
    if (!_signupFormKey.currentState!.validate()) return;

    final user = UserModel(
      id: '',
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      reason: _reasonCtrl.text.trim(),
    );

    final ok = await userProvider.registerContributor(user);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Registration Successful!' : 'Registration Failed'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) {
      setState(() {
        isLogin = true; // registration ke baad login form show karein
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<AuthProvider>(context);
    final mosqueProvider = Provider.of<MosqueProvider>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
         image: DecorationImage(image: AssetImage(AppAssets.background),fit: BoxFit.cover)
          ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  isLogin ? 'Login' : 'Sign Up',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Toggle forms
                isLogin 
                  ? _buildLoginForm(userProvider, mosqueProvider) 
                  : _buildSignupForm(userProvider),
                
                const SizedBox(height: 24),
                
                // Switch button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin ? "Don't have an account?" : "Already have an account?",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(
                        isLogin ? "Sign up" : "Sign in",
                        style: const TextStyle(
                          color: AppStyles.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider userProvider, MosqueProvider mosqueProvider) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          CustomTextfield(
            controller: _loginEmailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextfield(
            controller: _loginPassCtrl,
            label: 'Password',
            obscureText: true,
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: userProvider.isLoading ? null : () => _login(userProvider, mosqueProvider),
              child: userProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Sign in', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm(AuthProvider userProvider) {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          CustomTextfield(
            controller: _nameCtrl,
            label: 'Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextfield(
            controller: _emailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextfield(
            controller: _passCtrl,
            label: 'Password',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextfield(
            controller: _cityCtrl,
            label: 'City',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your city';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextfield(
            controller: _areaCtrl,
            label: 'Area',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your area';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextfield(
            controller: _reasonCtrl,
            label: 'Reason for joining',
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please tell us why you want to join';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: userProvider.isLoading ? null : () => _signup(userProvider),
              child: userProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Sign up', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
