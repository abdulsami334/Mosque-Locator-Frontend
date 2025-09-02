import 'package:flutter/material.dart';
import 'package:mosque_locator/providers/notification_provider.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:provider/provider.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }
  @override
  Widget build(BuildContext context) {
     final provider = Provider.of<NotificationProvider>(context);

    return  Scaffold(

        appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: AppStyles.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
  onRefresh: () async {
    await provider.fetchNotifications();
  },
  child: provider.notifications.isEmpty
      ? Center(child: Text(provider.errorMessage ?? "No notifications"))
      : ListView.builder(
          itemCount: provider.notifications.length,
          itemBuilder: (context, index) {
            final n = provider.notifications[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Icon(
                  n.status == "unread"
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: AppStyles.primaryGreen,
                ),
                title: Text(n.message),
                subtitle: Text(
                  n.createdAt.toLocal().toString().split(".")[0],
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: n.status == "unread"
                    ? const Icon(Icons.circle, color: Colors.red, size: 12)
                    : null,
              ),
            );
          },
        ),
)

    );
  }
}