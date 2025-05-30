import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'courier_home.dart';
import 'courier_topickup.dart';
import 'courier_pending.dart';
import 'courier_delivered.dart';
import 'courier_settings.dart';

// Custom BottomNavItem Widget
class BottomNavItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon, width: 30, height: 30, color: Colors.white),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class NotificationPage extends StatefulWidget {
  final int userId;
  const NotificationPage({super.key, required this.userId});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.68.116:5000/api/courier_notification'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          notifications = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF884B25),
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CourierHomePage(userId: widget.userId),
              ),
            );
          },
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? const Center(child: Text('No notifications available.'))
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif['activity_type'] ?? 'Notification',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4E342E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notif['message'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFF884B25),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomNavItem(
              icon: 'lib/assets/home_icon.png',
              label: 'Home',
              onTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourierHomePage(userId: widget.userId),
                    ),
                  ),
            ),
            BottomNavItem(
              icon: 'lib/assets/toPickup_icon.png',
              label: 'To Pick-Up',
              onTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ToPickUpPage(userId: widget.userId),
                    ),
                  ),
            ),
            BottomNavItem(
              icon: 'lib/assets/pending_icon.png',
              label: 'Pending',
              onTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PendingPage(userId: widget.userId),
                    ),
                  ),
            ),
            BottomNavItem(
              icon: 'lib/assets/delivered_icon.png',
              label: 'Delivered',
              onTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeliveredPage(userId: widget.userId),
                    ),
                  ),
            ),
            BottomNavItem(
              icon: 'lib/assets/settings_icon.png',
              label: 'Settings',
              onTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsPage(userId: widget.userId),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
