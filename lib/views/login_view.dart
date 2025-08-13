import 'package:flutter/material.dart';
import 'package:mosque_locator/providers/user_provider.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/widgets/custom_textfield.dart';
import 'package:mosque_locator/views/contributor_register_form.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await auth.loginContributor(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Logged in successfully!' : (auth.errorMessage ?? 'Login failed')),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      // Go to Home
      Navigator.pushReplacementNamed(context, '/Navigation');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: AppStyles.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextfield(
                    controller: _emailCtrl,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextfield(
                    controller: _passCtrl,
                    label: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: auth.isLoading ? null : () => _login(auth),
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Did not register yet?"),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ContributorRegisterForm(),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: AppStyles.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}