import 'package:flutter/material.dart';
import 'package:mosque_locator/providers/mosque_provider.dart';
import 'package:mosque_locator/providers/user_provider.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/utils/constant.dart';
import 'package:mosque_locator/views/contributor_register_form.dart';
import 'package:mosque_locator/views/home_view.dart';
import 'package:mosque_locator/views/login_view.dart';
import 'package:mosque_locator/views/profile_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     return 
    
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) =>MosqueProvider ()),
          ChangeNotifierProvider(create: (_) =>AuthProvider ()),
      ],
          child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: ThemeData(
          primaryColor: AppStyles.primaryGreen,
          scaffoldBackgroundColor: AppStyles.background,
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(seedColor: AppStyles.primaryGreen),
          useMaterial3: true,
        ),
        initialRoute: '/register',             // <-- first screen
  routes: {
    '/register': (_) => const ContributorRegisterForm(),
    '/login':    (_) => const LoginView(),
    '/home':     (_) => const HomeView(),   // your map screen
  },
        home:  ProfileView(),
      ),
    );
  }
}
