import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notification_viewmodel.dart';

class ExpiringNotificationsPage extends StatefulWidget {
  const ExpiringNotificationsPage({super.key});

  @override
  State<ExpiringNotificationsPage> createState() =>
      _ExpiringNotificationsPageState();
}

class _ExpiringNotificationsPageState
    extends State<ExpiringNotificationsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final vm = Provider.of<NotificationViewModel>(context, listen: false);
    await vm.loadStoredNotifications();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationVM = Provider.of<NotificationViewModel>(context);
    final notifications = notificationVM.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expiring Notifications'),
        actions: [
          if (!_isLoading && notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All Notifications',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Clear'),
                    content:
                    const Text('Are you sure you want to clear all notifications?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Clear')),
                    ],
                  ),
                );

                if (confirm == true) {
                  await notificationVM.clearAllNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications cleared')),
                  );
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text('No expiring items within 5 days.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Dismissible(
            key: ValueKey(n.message),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              await notificationVM.removeNotification(index);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification removed')),
              );
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: n.image.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    n.image,
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.warning),
                title: Text(
                  n.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.message),
                    const SizedBox(height: 4),
                    Text(
                      'Expiry Date: ${n.expiryDate.toLocal()}'.split(' ')[0],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      )
    );
  }
}
