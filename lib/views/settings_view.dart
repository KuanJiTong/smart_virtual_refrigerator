import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _notificationsEnabled = true; // reset toggle to default
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All preferences cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive push notifications for expiring items'),
            value: _notificationsEnabled,
            onChanged: _toggleNotification,
            activeColor: Colors.white,
          ),
          ListTile(
            title: const Text('Clear Preferences'),
            subtitle: const Text('Reset all saved settings and notifications'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_forever, color: const Color(0xFFE85C5C)),
              onPressed: _clearPreferences,
              tooltip: 'Clear all shared preferences',
            ),
          ),
        ],
      ),
    );
  }
}
