import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'buyer_home.dart';
import 'buyer_chat.dart';
import 'buyer_notif.dart';
import 'buyer_profile.dart';
import 'buyer_orderhistory.dart';
import 'buyer_ordersummary.dart';

class AddtoCartBuyerPage extends StatefulWidget {
  final int userId;
  const AddtoCartBuyerPage({super.key, required this.userId});

  @override
  State<AddtoCartBuyerPage> createState() => _AddtoCartBuyerPage();
}

class _AddtoCartBuyerPage extends State<AddtoCartBuyerPage> {
  List<dynamic> cartItems = [];
  List<bool> selectedItems = [];
  List<dynamic> messages = [];
  bool selectAll = false;
  final TextEditingController searchController = TextEditingController();

  Future<void> fetchCartData() async {
    final response = await http.post(
      Uri.parse('http://192.168.68.116:5000/api/cart'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': widget.userId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cartItems = data['cart_items'];
        selectedItems = List.filled(cartItems.length, false);
        messages = data['messages'];
        selectAll = false;
      });
    } else {
      throw Exception('Failed to load cart data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCartData();
  }

  double getTotalPrice() {
    double total = 0;
    for (int i = 0; i < cartItems.length; i++) {
      if (selectedItems[i]) {
        total += double.parse(cartItems[i]['total_price'].toString());
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                  const SizedBox(
                    width: 200,
                  ), // Adjust this to move "Orders" more/less left
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                    ), // Adjust to move "Orders" lower
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistorypageBuyer(),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset('lib/assets/orders.png', height: 40),
                          SizedBox(height: 2),
                          Text(
                            "Orders",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Cart",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 33, 19, 11),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: selectAll,
                        onChanged: (bool? value) {
                          setState(() {
                            selectAll = value!;
                            selectedItems = List.filled(
                              cartItems.length,
                              value,
                            );
                          });
                        },
                      ),
                      Text("Select All"),
                    ],
                  ),
                ],
              ),
            ),
            if (messages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children:
                      messages.map<Widget>((msg) {
                        Color bg =
                            msg['type'] == 'warning'
                                ? Colors.red[100]!
                                : Colors.orange[100]!;
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(msg['text']),
                        );
                      }).toList(),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 25),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 15),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(229),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: selectedItems[index],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedItems[index] = value!;
                              selectAll = selectedItems.every(
                                (selected) => selected,
                              );
                            });
                          },
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            "http://192.168.68.116:5000/uploads/product_images/${item['product_image']}",
                            width: 60,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    Icon(Icons.broken_image),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['product_name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "₱${double.parse(item['price'].toString()).toStringAsFixed(2)}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "x${item['quantity']}",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "₱${double.parse(item['total_price'].toString()).toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₱${getTotalPrice().toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: ElevatedButton(
                onPressed: () {
                  final selectedProducts = <Map<String, dynamic>>[];
                  for (int i = 0; i < cartItems.length; i++) {
                    if (selectedItems[i]) {
                      selectedProducts.add(cartItems[i]);
                    }
                  }

                  if (selectedProducts.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SummaryPageBuyer(
                              userId: widget.userId,
                              selectedProducts: selectedProducts,
                            ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please select items to checkout"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 136, 75, 37),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Checkout",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            Container(
              color: Colors.white.withAlpha(216),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                NotificationBuyerPage(userId: widget.userId),
                      ),
                    );
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
          SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
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
