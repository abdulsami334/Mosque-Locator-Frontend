import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mosque_locator/providers/mosque_provider.dart';
import 'package:mosque_locator/providers/user_provider.dart';
import 'package:mosque_locator/utils/app_assets.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/views/addMosque_view.dart';
import 'package:mosque_locator/views/contributor_register_form.dart';
import 'package:mosque_locator/views/login_view.dart';
import 'package:mosque_locator/views/map_view.dart';
import 'package:mosque_locator/views/my_mosque_view.dart';
import 'package:provider/provider.dart';

class ContributorHomeView extends StatefulWidget {
  const ContributorHomeView({Key? key}) : super(key: key);

  @override
  State<ContributorHomeView> createState() => _ContributorHomeViewState();
}

class _ContributorHomeViewState extends State<ContributorHomeView> {
  void _showMessage(String msg, {bool dialog = false}) {
    if (dialog) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Notice'),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthView())),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mosqueProvider = Provider.of<MosqueProvider>(context);
    final nearbyCount = mosqueProvider.nearbyMosqueCount;
    int myMosqueCount = mosqueProvider.myMosques.length;
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: (authProvider.user?.imageUrl != null && authProvider.user!.imageUrl!.isNotEmpty)
                ? (authProvider.user!.imageUrl!.startsWith('http')
                    ? NetworkImage(authProvider.user!.imageUrl!) as ImageProvider
                    : FileImage(File(authProvider.user!.imageUrl!)))
                : const AssetImage('assets/images/default_picture.png'),
          ),
        ),
        title: Text(authProvider.token != null ? user!.name : "Guest user"),
        backgroundColor: AppStyles.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Mosque counter cards in a row
              Row(
                children: [
                  Expanded(
                    child: _buildMosqueCard(
                      // ignore: unrelated_type_equality_checks
                      count: myMosqueCount.toString()=='0'?"Locked":myMosqueCount.toString(),
                      title: 'My Mosques',
                      icon: AppAssets.mosqueIcon,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMosqueCard(
                      count: nearbyCount.toString(),
                      title: 'Nearby Mosques',
                      icon: AppAssets.Nearbyicon,
                    ),
                  ),
                ],
              ),
    
              const SizedBox(height: 30),
              
              // Menu options - Removed Expanded widget
              Column(
                children: [
                  _buildOptionCard(
                    title: "Add Mosque",
                    icon: Icons.add_location_alt,
                    onTap: () {
                      if (authProvider.token == null) {
                        _showMessage('Please log in first', dialog: true);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddMosqueView()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    title: "View Mosques",
                    icon: Icons.map,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MosqueView()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    title: "My Mosques",
                    icon: Icons.mosque,
                    onTap: () {
                      if (authProvider.token == null) {
                        _showMessage('Please log in first', dialog: true);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyMosqueView()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppStyles.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppStyles.primaryGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildMosqueCard({
    required String count,
    required String title,
    required String icon,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 200, // Fixed height for consistent card size
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            if (icon.isNotEmpty)
              Image.asset(
                icon,
                height: 60, // Consistent image size
                width: 60,  // Consistent image size
              ),
            if (icon.isNotEmpty) const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}