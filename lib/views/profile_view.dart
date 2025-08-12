import 'package:flutter/material.dart';
import 'package:mosque_locator/providers/user_provider.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});



  @override
  Widget build(BuildContext context) {
      final auth= Provider.of<AuthProvider>(context);
      final user = auth.user;
    return  Scaffold(
         appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: AppStyles.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: user==null?const Center(child: CircularProgressIndicator()):
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [],
        ),
      )

    );
  }
}