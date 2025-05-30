import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'courier_topickup.dart';
import 'courier_pending.dart';
import 'courier_delivered.dart';
import 'courier_settings.dart';
import 'courier_notification.dart';
import 'main.dart';
import 'courier_outfordelivery.dart';

class CourierHomePage extends StatefulWidget {
  final int userId;
  const CourierHomePage({super.key, required this.userId});

  @override
  State<CourierHomePage> createState() => _CourierHomePageState();
}

class _CourierHomePageState extends State<CourierHomePage> {
  int totalOrders = 0;
  int toPickup = 0;
  int pendingOrders = 0;
  int completedOrders = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.68.116:5000/api/courier_home'),
      );

      // ignore: avoid_print
      print('Response status: ${response.statusCode}');
      // ignore: avoid_print
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalOrders = data['total_orders'];
          toPickup = data['to_pickup'];
          pendingOrders = data['pending_orders'];
          completedOrders = data['completed_orders'];
          isLoading = false;
        });
      } else {
        // ignore: avoid_print
        print('Failed to load data');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching dashboard data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // TOP BAR
                  Stack(
                    children: [
                      Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Color(0xFF884B25),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(40),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 55,
                        left: 28,
                        right: 28,
                        child: Row(
                          children: [
                            Container(
                              width: 90,
                              height: 30,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('lib/assets/Bookedia1.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 190,
                            ), // Adjusted spacing for the logout button
                            // Notification Bell
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => NotificationPage(
                                          userId: widget.userId,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('lib/assets/Bell.png'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),

                            // Logout Button
                            IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Implement your logout logic here
                                // For example, navigate to the login page or clear user data
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            LoginPage(), // Change to your login page
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // DASHBOARD TITLE
                  const Padding(
                    padding: EdgeInsets.only(top: 24.0, bottom: 8),
                    child: Center(
                      child: Text(
                        'Dashboard',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF884B25),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  // DASHBOARD CARDS
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: [
                        DashboardCard(
                          title: 'TOTAL SHIPMENTS',
                          count: totalOrders,
                          countColor: const Color(0xFF2196F3),
                          image: 'lib/assets/total_shipments_image.png',
                        ),
                        const SizedBox(height: 16),
                        DashboardCard(
                          title: 'TO PICK UP',
                          count: toPickup,
                          countColor: const Color(0xFFF9B233),
                          image: 'lib/assets/toPickup_image.png',
                        ),
                        const SizedBox(height: 16),
                        DashboardCard(
                          title: 'PENDING SHIPMENTS',
                          count: pendingOrders,
                          countColor: const Color(0xFFE53935),
                          image: 'lib/assets/pending_shipments_image.png',
                        ),
                        const SizedBox(height: 16),
                        DashboardCard(
                          title: 'DELIVERED ORDERS',
                          count: completedOrders,
                          countColor: const Color(0xFF2ECC40),
                          image: 'lib/assets/delivered_orders_image.png',
                        ),
                      ],
                    ),
                  ),

                  // BOTTOM NAVBAR
                  Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFF884B25),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        BottomNavItem(
                          icon: 'lib/assets/home_icon.png',
                          label: 'Home',
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        CourierHomePage(userId: widget.userId),
                              ),
                            );
                          },
                        ),
                        BottomNavItem(
                          icon: 'lib/assets/toPickup_icon.png',
                          label: 'To Pick-Up',
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ToPickUpPage(userId: widget.userId),
                              ),
                            );
                          },
                        ),
                        BottomNavItem(
                          icon: 'lib/assets/pending_icon.png',
                          label: 'To Ship',
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        PendingPage(userId: widget.userId),
                              ),
                            );
                          },
                        ),
                        BottomNavItem(
                          icon: 'lib/assets/delivered_icon.png',
                          label: 'OFD',
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => OfdPage(userId: widget.userId),
                              ),
                            );
                          },
                        ),
                        BottomNavItem(
                          icon: 'lib/assets/delivered_icon.png',
                          label: 'Delivered',
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        DeliveredPage(userId: widget.userId),
                              ),
                            );
                          },
                        ),
                        BottomNavItem(
                          icon: 'lib/assets/settings_icon.png',
                          label: 'Settings',
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        SettingsPage(userId: widget.userId),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

// DashboardCard widget
class DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final Color countColor;
  final String image;

  const DashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.countColor,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Image.asset(image, width: 70, height: 70, fit: BoxFit.contain),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF884B25),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: countColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// BottomNavItem widget
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
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(icon, width: 28, height: 28, color: Colors.white),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
