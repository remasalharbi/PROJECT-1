import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsSetting extends StatefulWidget {
  const NotificationsSetting({super.key});

  @override
  State<NotificationsSetting> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsSetting> {
  final supabase = Supabase.instance.client;
  final user = Supabase.instance.client.auth.currentUser;

  final List<String> settingKeys = [
    'Special Offers',
    'Sound',
    'Vibrate',
    'General Notification',
    'Promo & Discount',
    'Payment Options',
    'App Update',
    'New Service Available',
    'New Tips Available',
  ];

  Map<String, bool> _switchValues = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    if (user == null) {
      debugPrint('User not logged in.');
      return;
    }

    try {
      final response = await supabase
          .from('notification_settings')
          .select('setting_name, is_enabled')
          .eq('user_id', user!.id);

      final List data = response as List;

      Map<String, bool> loaded = {
        for (var key in settingKeys) key: true,
      };

      for (var item in data) {
        loaded[item['setting_name']] = item['is_enabled'] as bool;
      }

      setState(() {
        _switchValues = loaded;
        _loading = false;
      });
    } catch (e) {
       setState(() => _loading = false);
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    setState(() {
      _switchValues[key] = value;
    });

    try {
      await supabase.from('notification_settings').upsert({
        'user_id': user!.id,
        'setting_name': key,
        'is_enabled': value,
      },   onConflict: 'user_id,setting_name',
      );
    } catch (e) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('حدث خطأ أثناء تحديث الإعداد: $e')),
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    const navyColor = Color(0xFF2A2575);
    const backgroundColor = Color(0xFFF5F9FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: BackButton(color: navyColor),
        title: const Text('Notification', style: TextStyle(color: navyColor)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: _switchValues.entries.map((entry) {
                return SwitchListTile(
                  title: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: entry.value,
                  onChanged: (val) => _updateSetting(entry.key, val),
                  activeColor: navyColor,
                );
              }).toList(),
            ),
    );
  }
}
