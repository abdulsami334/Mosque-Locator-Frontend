import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosque_locator/models/user_model.dart';
import 'package:mosque_locator/providers/user_provider.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/views/contributor_register_form.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // ❌ Removed unused File? _imageFile;

  Future<void> _pickImage(AuthProvider auth) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final success = await auth.updateProfilePicture(pickedFile.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Profile updated" : "Update failed"),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: AppStyles.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: user == null ? _guestUI(context) : _userUI(user, auth),
    );
  }

  Widget _guestUI(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.account_circle,
                  size: 100, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Guest User',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unlock full features by becoming a contributor.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add, size: 20),
                label: const Text('Become a Contributor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ContributorRegisterForm()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userUI(UserModel user, AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
          backgroundImage: auth.user?.imageUrl != null
    ? (auth.user!.imageUrl!.startsWith('http')
        ? NetworkImage(auth.user!.imageUrl!)
        : FileImage(File(auth.user!.imageUrl!)) as ImageProvider)
    : const AssetImage('assets/images/default_picture.png') as ImageProvider,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: auth.isLoading ? null : () => _pickImage(auth),
            icon: const Icon(Icons.edit),
            label: const Text("Edit Picture"),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Chip(
            label: const Text('Contributor'),
            backgroundColor: Colors.green[100],
            labelStyle:
                const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            side: BorderSide.none,
          ),
          const SizedBox(height: 32),
          _infoTile(Icons.phone, 'Phone', user.phone),
          _infoTile(Icons.location_city, 'City', user.city),
          _infoTile(Icons.my_location, 'Area', user.area),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppStyles.primaryGreen),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}