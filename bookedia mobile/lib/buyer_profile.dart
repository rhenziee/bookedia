import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import 'buyer_cart.dart';
import 'buyer_chat.dart';
import 'buyer_notif.dart';
import 'buyer_home.dart';
import 'main.dart';

// Placeholder imports for pages
import 'buyer_editprofile.dart';
import 'buyer_orderhistory.dart';

class ProfilepageBuyer extends StatefulWidget {
  final int userId;

  const ProfilepageBuyer({super.key, required this.userId});

  @override
  State<ProfilepageBuyer> createState() => _ProfilepageBuyerState();
}

class _ProfilepageBuyerState extends State<ProfilepageBuyer> {
  late Future<Map<String, dynamic>> _userFuture;
  final TextEditingController searchController = TextEditingController();

  Future<Map<String, dynamic>> fetchBuyerProfile() async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.68.116:5000/api/buyer/profile/${widget.userId}',
      ),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  @override
  void initState() {
    super.initState();
    _userFuture = fetchBuyerProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final user = snapshot.data!;
          final idUpload = user['id_upload'];

          return SafeArea(
            child: Column(
              children: [
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
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
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
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 70,
                  backgroundColor: const Color.fromARGB(255, 136, 75, 37),
                  backgroundImage:
                      idUpload != null
                          ? NetworkImage('http://192.168.68.116:5000$idUpload')
                          : null,
                  child:
                      idUpload == null
                          ? const Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.white,
                          )
                          : null,
                ),
                const SizedBox(height: 15),
                Text(
                  user['firstname'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(user['email'], style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 60),
                buildOptionTile("Edit Profile", Icons.edit, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditProfileBuyer(userId: widget.userId),
                    ),
                  );
                }),
                buildOptionTile("Order History", Icons.history, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistorypageBuyer()),
                  );
                }),
                buildOptionTile("Logout", Icons.logout, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
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
                  builder: (context) => ChatBuyerPage(userId: widget.userId),
                ),
              );
            }),
            navItem("lib/assets/notifications.png", "Notifications", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => NotificationBuyerPage(userId: widget.userId),
                ),
              );
            }),
            navItem("lib/assets/home.png", "Home", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomepageBuyer(userId: widget.userId),
                ),
              );
            }),
            navItem("lib/assets/cart.png", "Cart", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AddtoCartBuyerPage(userId: widget.userId),
                ),
              );
            }),
            navItem("lib/assets/user.png", "Profile", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilepageBuyer(userId: widget.userId),
                ),
              );
            }),
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
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 67, 40, 24),
            ),
          ),
        ],
      ),
    );
  }

  // Updated to accept onTap callback
  Widget buildOptionTile(String title, IconData icon, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
