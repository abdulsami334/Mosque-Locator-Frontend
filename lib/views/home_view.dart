import 'package:flutter/material.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/views/addMosque_view.dart';
import 'package:mosque_locator/views/map_view.dart';
import 'package:mosque_locator/views/my_mosque_view.dart';
import 'package:mosque_locator/widgets/Navigation/main_navigation.dart';

class ContributorHomeView extends StatelessWidget {
  const ContributorHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contributor Dashboard"),
        backgroundColor: AppStyles.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _optionCard(
              context,
              title: "Add Mosque",
              icon: Icons.add_location_alt,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMosqueView()),
              ),
            ),
            const SizedBox(height: 24),
            _optionCard(
              context,
              title: "View Mosques",
              icon: Icons.map,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MosqueView()),
              ),
            ),
            const SizedBox(height: 24),
              _optionCard(
              context,
              title: "My Mosques",
              icon: Icons.map,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyMosqueView()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
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
              child: Icon(icon, color: AppStyles.primaryGreen, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
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
}