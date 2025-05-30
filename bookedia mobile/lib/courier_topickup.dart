import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'courier_outfordelivery.dart';
import 'courier_home.dart';
import 'courier_pending.dart';
import 'courier_settings.dart';
import 'courier_notification.dart';
import 'main.dart';

class ToPickUpPage extends StatefulWidget {
  final int userId;
  const ToPickUpPage({super.key, required this.userId});

  @override
  State<ToPickUpPage> createState() => _ToPickUpPageState();
}

class _ToPickUpPageState extends State<ToPickUpPage> {
  List<dynamic> pickupOrders = [];

  @override
  void initState() {
    super.initState();
    fetchPickUpOrders();
  }

  Future<void> fetchPickUpOrders() async {
    final url = Uri.parse('http://192.168.68.116:5000/api/courier_topickup');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        pickupOrders = json.decode(response.body);
      });
    } else {
      // ignore: avoid_print
      print('Failed to load pickup orders');
    }
  }

  Future<void> updateOrderStatus(String parcelId) async {
    final url = Uri.parse('http://192.168.68.116:5000/api/update_status');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'parcel_id': parcelId, 'new_status': 'toship'}),
    );

    if (response.statusCode == 200) {
      fetchPickUpOrders();
    } else {
      // ignore: avoid_print
      print('Failed to update status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
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
                                (context) =>
                                    NotificationPage(userId: widget.userId),
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
                      icon: const Icon(Icons.logout, color: Colors.white),
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

          // TO PICK-UP TITLE
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Center(
              child: Text(
                'To Pick-Up',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF884B25),
                ),
              ),
            ),
          ),

          // DISPLAY PICKUP CARDS
          Expanded(
            child:
                pickupOrders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pickupOrders.length,
                      itemBuilder: (context, index) {
                        final order = pickupOrders[index];
                        final orderDate = DateTime.tryParse(
                          order['order_date'] ?? '',
                        );
                        final formattedDate =
                            orderDate != null
                                ? DateFormat('yyyy-MM-dd').format(orderDate)
                                : 'Date unknown';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PickUpCard(
                            parcelId: order['parcel_id'].toString(),
                            sellerName: order['seller_name'],
                            sellerAddress: order['seller_address'],
                            dateTime: formattedDate,
                            onPickUp:
                                () => updateOrderStatus(
                                  order['parcel_id'].toString(),
                                ),
                          ),
                        );
                      },
                    ),
          ),

          // BOTTOM NAVBAR
          Container(
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
                        builder:
                            (context) => CourierHomePage(userId: widget.userId),
                      ),
                    );
                  },
                ),
                BottomNavItem(
                  icon: 'lib/assets/toPickup_icon.png',
                  label: 'To Pick-Up',
                ),
                BottomNavItem(
                  icon: 'lib/assets/pending_icon.png',
                  label: 'To Ship',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PendingPage(userId: widget.userId),
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
        ],
      ),
    );
  }
}

class PickUpCard extends StatelessWidget {
  final String parcelId;
  final String sellerName;
  final String sellerAddress;
  final String dateTime;
  final VoidCallback onPickUp;

  const PickUpCard({
    super.key,
    required this.parcelId,
    required this.sellerName,
    required this.sellerAddress,
    required this.dateTime,
    required this.onPickUp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parcel #$parcelId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(sellerName, style: const TextStyle(fontSize: 16)),
            Text(sellerAddress, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateTime, style: const TextStyle(fontSize: 14)),
                ElevatedButton(
                  onPressed: onPickUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF884B25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'PICK UP',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
