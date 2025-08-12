import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosque_locator/models/user_model.dart';
import 'package:mosque_locator/providers/user_provider.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/widgets/custom_textfield.dart';
import 'package:mosque_locator/views/login_view.dart';
import 'package:provider/provider.dart';

class ContributorRegisterForm extends StatefulWidget {
  const ContributorRegisterForm({Key? key}) : super(key: key);

  @override
  State<ContributorRegisterForm> createState() =>
      _ContributorRegisterFormState();
}

class _ContributorRegisterFormState extends State<ContributorRegisterForm> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _cityCtrl   = TextEditingController();
  final _areaCtrl   = TextEditingController();
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _areaCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    final user = UserModel(
      name   : _nameCtrl.text.trim(),
      email  : _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      phone  : _phoneCtrl.text.trim(),
      city   : _cityCtrl.text.trim(),
      area   : _areaCtrl.text.trim(),
      reason : _reasonCtrl.text.trim(),
    );

    final ok = await auth.registerContributor(user);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Registration Successful!' : 'Registration Failed'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
    if (ok) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const LoginView()));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Contributor'),
        centerTitle: true,
        backgroundColor: AppStyles.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextfield(controller: _nameCtrl, label: 'Full Name'),
              const SizedBox(height: 16),
              CustomTextfield(controller: _emailCtrl, label: 'Email',keyboardType: TextInputType.emailAddress,),
              const SizedBox(height: 16),
              CustomTextfield(
                controller: _passCtrl,
                label: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              CustomTextfield(controller: _phoneCtrl, label: 'Phone',keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              CustomTextfield(controller: _cityCtrl, label: 'City'),
              const SizedBox(height: 16),
              CustomTextfield(controller: _areaCtrl, label: 'Area'),
              const SizedBox(height: 16),
              CustomTextfield(
                controller: _reasonCtrl,
                label: 'Reason for Joining',
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: auth.isLoading ? null : () => _submit(auth),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
               const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginView(),
                      ),
                    ),
                    child: const Text('Login', style: TextStyle(color: AppStyles.primaryGreen, fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}