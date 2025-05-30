import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'courier_pending.dart';
import 'courier_home.dart';
import 'courier_topickup.dart';
import 'courier_delivered.dart';
import 'courier_settings.dart';
import 'courier_notification.dart';
import 'main.dart';

class OfdPage extends StatefulWidget {
  final int userId;
  const OfdPage({super.key, required this.userId});

  @override
  State<OfdPage> createState() => _OfdPageState();
}

class _OfdPageState extends State<OfdPage> {
  List<PendingOrder> pendingOrders = [];

  @override
  void initState() {
    super.initState();
    fetchOfdOrders();
  }

  Future<void> fetchOfdOrders() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.68.116:5000/api/ofd'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['orders'];
        setState(() {
          pendingOrders = data.map((e) => PendingOrder.fromJson(e)).toList();
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching orders: $e');
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

          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Center(
              child: Text(
                'Out for Delivery',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF884B25),
                ),
              ),
            ),
          ),

          Expanded(
            child:
                pendingOrders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pendingOrders.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: PendingCard(order: pendingOrders[index]),
                        );
                      },
                    ),
          ),

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
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ToPickUpPage(userId: widget.userId),
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
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DeliveredPage(userId: widget.userId),
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
        ],
      ),
    );
  }
}

// MODEL CLASS
class PendingOrder {
  final int parcelId;
  final String recipientName;
  final String shippingAddress;
  final String productNames;
  final String quantities;

  final double totalPrice;

  PendingOrder({
    required this.parcelId,
    required this.recipientName,
    required this.shippingAddress,
    required this.productNames,
    required this.quantities,

    required this.totalPrice,
  });

  factory PendingOrder.fromJson(Map<String, dynamic> json) {
    return PendingOrder(
      parcelId: json['parcel_id'],
      recipientName: json['recipient_name'],
      shippingAddress: json['shipping_address'],
      productNames: json['product_names'],
      quantities: json['quantities'],
      totalPrice: double.parse(json['total_price'].toString()),
    );
  }
}

// PENDING CARD UI
class PendingCard extends StatelessWidget {
  final PendingOrder order;

  const PendingCard({super.key, required this.order});

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
              'Parcel #${order.parcelId}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(order.recipientName, style: const TextStyle(fontSize: 16)),
            Text(order.shippingAddress, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text("Items: ${order.productNames}"),
            Text("Quantities: ${order.quantities}"),

            Text("Total: ₱${order.totalPrice.toStringAsFixed(2)}"),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  final response = await http.post(
                    Uri.parse(
                      'http://192.168.68.116:5000/api/mark_completed/${order.parcelId}',
                    ),
                  );

                  if (response.statusCode == 200) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Marked as out for completed'),
                      ),
                    );
                    // Optionally refresh the list after marking
                    // ignore: use_build_context_synchronously
                    if (context.findAncestorStateOfType<_OfdPageState>() !=
                        null) {
                      // ignore: use_build_context_synchronously
                      context
                          .findAncestorStateOfType<_OfdPageState>()!
                          .fetchOfdOrders();
                    }
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update status')),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF884B25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Order Delivered',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BOTTOM NAV BAR ITEM
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
