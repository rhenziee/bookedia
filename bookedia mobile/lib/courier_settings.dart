import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'courier_home.dart';
import 'courier_topickup.dart';
import 'courier_pending.dart';
import 'courier_delivered.dart';
import 'courier_outfordelivery.dart';

// BOTTOM NAV ITEM COMPONENT
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
          Text(label, style: TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

// SETTINGS PAGE WITH DYNAMIC USER ID
class SettingsPage extends StatefulWidget {
  final int userId;

  const SettingsPage({super.key, required this.userId});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? user;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> fetchUserData() async {
    final response = await http.get(
      Uri.parse('http://192.168.68.116:5000/api/user/${widget.userId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        user = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> changePassword() async {
    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Error"),
              content: const Text(
                "New password and confirmation do not match.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http:// 192.168.68.116:5000/api/change_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': widget.userId,
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Success"),
              content: const Text("Password changed successfully."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } else {
      final error = jsonDecode(response.body)['error'] ?? "Unknown error";
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Failed"),
              content: Text("Password change failed: $error"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF884B25),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CourierHomePage(userId: widget.userId),
              ),
            );
          },
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        ),
      ),
      body:
          user == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    const Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E342E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Name: ${user!['firstname']} ${user!['surname']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Email: ${user!['email']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Contact No.: ${user!['contact']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Privacy and Security',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E342E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: oldPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Old Password',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF884B25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Change Password',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
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
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourierHomePage(userId: widget.userId),
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
                    builder: (_) => ToPickUpPage(userId: widget.userId),
                  ),
                );
              },
            ),
            BottomNavItem(
              icon: 'lib/assets/pending_icon.png',
              label: 'Pending',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PendingPage(userId: widget.userId),
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
                    builder: (context) => OfdPage(userId: widget.userId),
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
                    builder: (_) => DeliveredPage(userId: widget.userId),
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
                    builder: (_) => SettingsPage(userId: widget.userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
