import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'buyer_home.dart';
import 'buyer_chat.dart';
import 'buyer_cart.dart';
import 'buyer_profile.dart';

class NotificationBuyerPage extends StatefulWidget {
  final int userId;
  const NotificationBuyerPage({super.key, required this.userId});

  @override
  State<NotificationBuyerPage> createState() => _NotificationBuyerPageState();
}

class _NotificationBuyerPageState extends State<NotificationBuyerPage> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final url = Uri.parse(
      'http://192.168.68.116:5000/api/notifications/${widget.userId}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // ignore: avoid_print
        print("Notifications received: $decoded"); // Debug print
        setState(() {
          notifications = decoded;
          isLoading = false;
        });
      } else {
        // ignore: avoid_print
        print('Failed to load notifications');
        setState(() => isLoading = false);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching notifications: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF8B4513),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/Bookedia1.png',
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 25),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 20, left: 25, right: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 33, 19, 11),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : notifications.isEmpty
                      ? const Center(child: Text("No notifications found."))
                      : ListView.separated(
                        itemCount: notifications.length,
                        separatorBuilder:
                            (context, index) => Divider(
                              color: Colors.grey.shade300,
                              indent: 25,
                              endIndent: 25,
                              thickness: 1,
                            ),
                        itemBuilder: (context, index) {
                          final item = notifications[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      item['type'] == 'order'
                                          ? Colors.brown.shade200
                                          : Colors.brown.shade400,
                                  radius: 24,
                                  child: Icon(
                                    item['type'] == 'order'
                                        ? Icons.local_shipping
                                        : Icons.notifications,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['type'] == 'order'
                                            ? item['title'] ?? 'Order update'
                                            : item['sender'] ?? 'Message',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        item['message'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        item['time'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),

            // Bottom Navigation Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  navItem("lib/assets/chat.png", "Chat", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChatBuyerPage(userId: widget.userId),
                      ),
                    );
                  }),
                  navItem("lib/assets/notifications.png", "Notifications", () {
                    // Already on this page
                  }),
                  navItem("lib/assets/home.png", "Home", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => HomepageBuyer(userId: widget.userId),
                      ),
                    );
                  }),
                  navItem("lib/assets/cart.png", "Cart", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                AddtoCartBuyerPage(userId: widget.userId),
                      ),
                    );
                  }),
                  navItem("lib/assets/user.png", "Profile", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProfilepageBuyer(userId: widget.userId),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget navItem(String iconPath, String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, height: 30),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 67, 40, 24),
            ),
          ),
        ],
      ),
    );
  }
}
