// import 'package:flutter/material.dart';
// import 'package:mosque_locator/models/user_model.dart';
// import 'package:mosque_locator/providers/mosque_provider.dart';
// import 'package:mosque_locator/providers/user_provider.dart';
// import 'package:mosque_locator/utils/app_assets.dart';
// import 'package:mosque_locator/utils/app_styles.dart';
// import 'package:mosque_locator/widgets/custom_textfield.dart';
// import 'package:provider/provider.dart';

// class AuthView extends StatefulWidget {
//   const AuthView({Key? key}) : super(key: key);

//   @override
//   State<AuthView> createState() => _AuthViewState();
// }

// class _AuthViewState extends State<AuthView> {
//   bool isLogin = true; // toggle between login and signup

//   // Login controllers
//   final _loginEmailCtrl = TextEditingController();
//   final _loginPassCtrl = TextEditingController();

//   // Signup controllers
//   final _nameCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _cityCtrl = TextEditingController();
//   final _areaCtrl = TextEditingController();
//   final _reasonCtrl = TextEditingController();

//   final _loginFormKey = GlobalKey<FormState>();
//   final _signupFormKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _loginEmailCtrl.dispose();
//     _loginPassCtrl.dispose();
//     _nameCtrl.dispose();
//     _emailCtrl.dispose();
//     _passCtrl.dispose();
//     _phoneCtrl.dispose();
//     _cityCtrl.dispose();
//     _areaCtrl.dispose();
//     _reasonCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _login(AuthProvider userProvider, MosqueProvider mosqueProvider) async {
//     if (!_loginFormKey.currentState!.validate()) return;

//     final success = await userProvider.loginContributor(
//       _loginEmailCtrl.text.trim(),
//       _loginPassCtrl.text.trim(),
//     );

//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(success ? 'Logged in successfully!' : (userProvider.errorMessage ?? 'Login failed')),
//         backgroundColor: success ? Colors.green : Colors.red,
//       ),
//     );

//     if (success) {
//       mosqueProvider.setToken(userProvider.token!);
//       Navigator.pushReplacementNamed(context, '/Navigation');
//     }
//   }

//   Future<void> _signup(AuthProvider userProvider) async {
//     if (!_signupFormKey.currentState!.validate()) return;

//     final user = UserModel(
//       id: '',
//       name: _nameCtrl.text.trim(),
//       email: _emailCtrl.text.trim(),
//       password: _passCtrl.text.trim(),
//       phone: _phoneCtrl.text.trim(),
//       city: _cityCtrl.text.trim(),
//       area: _areaCtrl.text.trim(),
//       reason: _reasonCtrl.text.trim(),
//     );

//     final ok = await userProvider.registerContributor(user);

//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(ok ? 'Registration Successful!' : 'Registration Failed'),
//         backgroundColor: ok ? Colors.green : Colors.red,
//       ),
//     );

//     if (ok) {
//       setState(() {
//         isLogin = true; // registration ke baad login form show karein
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<AuthProvider>(context);
//     final mosqueProvider = Provider.of<MosqueProvider>(context, listen: false);
//     return Container(
//       decoration: BoxDecoration(
//          image: DecorationImage(image: AssetImage(AppAssets.background),fit: BoxFit.cover)
//           ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(32),
//           child: Center(
//             child: Stack(
//               // mainAxisAlignment: MainAxisAlignment.center,
//               //crossAxisAlignment: CrossAxisAlignment.center,
//             //  mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Title
//                 Text(
//                   isLogin ? 'Login' : 'Sign Up',
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: AppStyles.primaryGreen,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
                
//                 // Toggle forms
//                 isLogin 
//                   ? _buildLoginForm(userProvider, mosqueProvider) 
//                   : _buildSignupForm(userProvider),
                
//                 const SizedBox(height: 24),
                
//                 // Switch button
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       isLogin ? "Don't have an account?" : "Already have an account?",
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         setState(() {
//                           isLogin = !isLogin;
//                         });
//                       },
//                       child: Text(
//                         isLogin ? "Sign up" : "Sign in",
//                         style: const TextStyle(
//                           color: AppStyles.primaryGreen,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoginForm(AuthProvider userProvider, MosqueProvider mosqueProvider) {
//     return Form(
//       key: _loginFormKey,
//       child: Column(
//         children: [
//           CustomTextfield(
//             controller: _loginEmailCtrl,
//             label: 'Email',
//             keyboardType: TextInputType.emailAddress,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your email';
//               }
//               if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                 return 'Please enter a valid email';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           CustomTextfield(
//             controller: _loginPassCtrl,
//             label: 'Password',
//             obscureText: true,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your password';
//               }
//               if (value.length < 6) {
//                 return 'Password must be at least 6 characters';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppStyles.primaryGreen,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: userProvider.isLoading ? null : () => _login(userProvider, mosqueProvider),
//               child: userProvider.isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text('Sign in', style: TextStyle(color: Colors.white, fontSize: 16)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSignupForm(AuthProvider userProvider) {
//     return Form(
//       key: _signupFormKey,
//       child: Column(
//         children: [
//           CustomTextfield(
//             controller: _nameCtrl,
//             label: 'Name',
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your name';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           CustomTextfield(
//             controller: _emailCtrl,
//             label: 'Email',
//             keyboardType: TextInputType.emailAddress,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your email';
//               }
//               if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                 return 'Please enter a valid email';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           CustomTextfield(
//             controller: _passCtrl,
//             label: 'Password',
//             obscureText: true,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter a password';
//               }
//               if (value.length < 6) {
//                 return 'Password must be at least 6 characters';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           CustomTextfield(
//             controller: _cityCtrl,
//             label: 'City',
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your city';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           CustomTextfield(
//             controller: _areaCtrl,
//             label: 'Area',
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your area';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           CustomTextfield(
//             controller: _reasonCtrl,
//             label: 'Reason for joining',
//             maxLines: 2,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please tell us why you want to join';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppStyles.primaryGreen,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: userProvider.isLoading ? null : () => _signup(userProvider),
//               child: userProvider.isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text('Sign up', style: TextStyle(color: Colors.white, fontSize: 16)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mosque_locator/models/user_model.dart';
import 'package:mosque_locator/providers/mosque_provider.dart';
import 'package:mosque_locator/providers/user_provider.dart';
import 'package:mosque_locator/utils/app_assets.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:provider/provider.dart';

class AuthView extends StatefulWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with SingleTickerProviderStateMixin {
  bool isLogin = true;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (ok) {
      setState(() {
        isLogin = true;
      });
      _animationController?.reset();
      _animationController?.forward();
    }
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
    _animationController?.reset();
    _animationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<AuthProvider>(context);
    final mosqueProvider = Provider.of<MosqueProvider>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage(AppAssets.background),fit: BoxFit.cover)
        ),
      
      child: Scaffold(
        backgroundColor: Colors.transparent,
         body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: _fadeAnimation != null
                ? FadeTransition(
                    opacity: _fadeAnimation!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
            
                        // Header
                        Text(
                          isLogin ? 'Sign in' : 'Sign up',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                isLogin
                                    ? "Don't have an account?"
                                    : "Already have an account?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: _toggleAuthMode,
                                child: Text(
                                  isLogin ? "Sign up" : "Sign in",
                                  style: const TextStyle(
                                      color:AppStyles.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
            
                        // Form Container
                        Container(
                          padding: const EdgeInsets.all(24),
                          // decoration: BoxDecoration(
                          //   color: Colors.white,
                          //   borderRadius: BorderRadius.circular(16),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black.withOpacity(0.1),
                            //     blurRadius: 20,
                            //     offset: const Offset(0, 10),
                            //   ),
                            // ],
                        //  ),
                          child: isLogin
                              ? _buildLoginForm(userProvider, mosqueProvider)
                              : _buildSignupForm(userProvider),
                        ),
            
                      
                      ],
                    ),
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );
  }

  // -------- Forms ----------
  Widget _buildLoginForm(AuthProvider userProvider, MosqueProvider mosqueProvider) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _buildStyledTextField(
            controller: _loginEmailCtrl,
            label: 'Email',
            icon: Icons.email_outlined,
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
          const SizedBox(height: 20),
          _buildStyledTextField(
            controller: _loginPassCtrl,
            label: 'Password',
            icon: Icons.lock_outline,
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
          const SizedBox(height: 32),
          _buildStyledButton(
            text: 'Sign in',
            isLoading: userProvider.isLoading,
            onPressed: () => _login(userProvider, mosqueProvider),
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
          _buildStyledTextField(
            controller: _nameCtrl,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildStyledTextField(
            controller: _emailCtrl,
            label: 'Email',
            icon: Icons.email_outlined,
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
          const SizedBox(height: 20),
          _buildStyledTextField(
            controller: _passCtrl,
            label: 'Password',
            icon: Icons.lock_outline,
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
          const SizedBox(height: 20),
          _buildStyledTextField(
            controller: _phoneCtrl,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildStyledTextField(
            controller: _cityCtrl,
            label: 'City',
            icon: Icons.location_city_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your city';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildStyledTextField(
            controller: _areaCtrl,
            label: 'Area',
            icon: Icons.place_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your area';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildStyledTextField(
            controller: _reasonCtrl,
            label: 'Reason for joining',
            icon: Icons.edit_note_outlined,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please tell us why you want to join';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          _buildStyledButton(
            text: 'Sign up',
            isLoading: userProvider.isLoading,
            onPressed: () => _signup(userProvider),
          ),
        ],
      ),
    );
  }

  // -------- Custom Widgets ----------
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            //color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppStyles.primaryGreen,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 8,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }

  Widget _buildStyledButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppStyles.primaryGreen, Color(0xFF44A08D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppStyles.primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}