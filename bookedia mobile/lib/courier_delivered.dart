import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'courier_outfordelivery.dart';
import 'courier_home.dart';
import 'courier_topickup.dart';
import 'courier_pending.dart';
import 'courier_settings.dart';
import 'courier_notification.dart';
import 'main.dart';

class DeliveredPage extends StatefulWidget {
  final int userId;
  const DeliveredPage({super.key, required this.userId});

  @override
  State<DeliveredPage> createState() => _DeliveredPageState();
}

class _DeliveredPageState extends State<DeliveredPage> {
  List<CompletedOrder> deliveredOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDeliveredOrders();
  }

  Future<void> fetchDeliveredOrders() async {
    final url = Uri.parse(
      'http://192.168.68.116:5000/api/completed?user_id=${widget.userId}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // ignore: avoid_print
        print('Response body: ${response.body}');

        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> ordersList = jsonData['orders'];

        setState(() {
          deliveredOrders =
              ordersList.map((item) => CompletedOrder.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load completed orders');
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
                    const SizedBox(width: 190),
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
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
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
            child: Text(
              'Delivered',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Color(0xFF884B25),
              ),
            ),
          ),

          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : deliveredOrders.isEmpty
                    ? const Center(child: Text('No completed orders found.'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: deliveredOrders.length,
                      itemBuilder: (context, index) {
                        final order = deliveredOrders[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: DeliveredCard(order: order),
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
                  onTap:
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CourierHomePage(userId: widget.userId),
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
                  label: 'To Ship',
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
                  onTap: () {},
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
        ],
      ),
    );
  }
}

// COMPLETED ORDER MODEL
class CompletedOrder {
  final int orderId;
  final String productName;
  final int quantity;
  final double totalPrice;
  final String recipientName;
  final String shippingAddress;
  final String paymentMethod;
  final String orderDate;
  final String dateDelivered;
  final String status;

  CompletedOrder({
    required this.orderId,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.recipientName,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.orderDate,
    required this.dateDelivered,
    required this.status,
  });

  factory CompletedOrder.fromJson(Map<String, dynamic> json) {
    return CompletedOrder(
      orderId: json['order_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      totalPrice: double.parse(json['total_price'].toString()),
      recipientName: json['recipient_name'],
      shippingAddress: json['shipping_address'],
      paymentMethod: json['payment_method'],
      orderDate: json['order_date'],
      dateDelivered: json['date_delivered'],
      status: json['status'],
    );
  }
}

// DELIVERED CARD
class DeliveredCard extends StatelessWidget {
  final CompletedOrder order;

  const DeliveredCard({super.key, required this.order});

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
              'Order #${order.orderId}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF884B25),
              ),
            ),
            const SizedBox(height: 5),
            Text('Product: ${order.productName}'),
            Text('Qty: ${order.quantity}'),
            Text('Total: ₱${order.totalPrice.toStringAsFixed(2)}'),
            Text('Recipient: ${order.recipientName}'),
            Text('Address: ${order.shippingAddress}'),
            Text('Payment: ${order.paymentMethod}'),
            Text('Delivered: ${order.dateDelivered}'),
          ],
        ),
      ),
    );
  }
}

// BOTTOM NAV ITEM
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
