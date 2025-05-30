import 'package:flutter/material.dart';
import 'buyer_cart.dart';
import 'buyer_chat.dart';
import 'buyer_home.dart';
import 'buyer_notif.dart';
import 'buyer_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SummaryPageBuyer extends StatefulWidget {
  final int userId;
  final List<dynamic> selectedProducts;

  const SummaryPageBuyer({
    super.key,
    required this.userId,
    required this.selectedProducts,
  });

  @override
  State<SummaryPageBuyer> createState() => _SummaryPageBuyerState();
}

class _SummaryPageBuyerState extends State<SummaryPageBuyer> {
  String buyerName = '';
  String shippingAddress = '';
  bool isLoading = true;

  final List<String> paymentMethods = ['Cash on Delivery'];
  String selectedPaymentMethod = 'Cash on Delivery';

  static const double shippingFee = 50.0;

  double getSubtotal() {
    return widget.selectedProducts.fold(0.0, (sum, product) {
      final price = double.tryParse(product['price'].toString()) ?? 0.0;
      return sum + price;
    });
  }

  double getTotalPrice() {
    return getSubtotal() + shippingFee;
  }

  @override
  void initState() {
    super.initState();
    fetchBuyerDetails();
  }

  Future<void> fetchBuyerDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.68.116:5000/api/get_buyer/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          buyerName = data['name'] ?? '';
          shippingAddress = data['address'] ?? '';
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load buyer data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double subtotal = getSubtotal();
    final double total = getTotalPrice();

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/homepage.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, right: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/history");
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, top: 37),
                      child: Column(
                        children: [
                          Image.asset('lib/assets/orders.png', height: 30),
                          const SizedBox(height: 6),
                          const Text(
                            "Orders",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 90),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          child: Text(
                            "Check Out Summary",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 33, 19, 11),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...widget.selectedProducts.map((product) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 5,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      'http://192.168.68.116:5000/uploads/product_images/${product['product_image']}',
                                      width: 60,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Image.asset(
                                          'lib/assets/placeholder.png',
                                          width: 60,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['product_name'] ??
                                              'Product Name',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Quantity: ${product['quantity']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      "₱${(double.tryParse(product['price'].toString()) ?? 0.0).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 248, 240, 230),
                              border: Border.all(
                                color: const Color.fromARGB(255, 136, 75, 37),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                buildSummaryRow("Subtotal", subtotal),
                                const Divider(thickness: 1),
                                buildSummaryRow("Shipping", shippingFee),
                                const Divider(thickness: 1),
                                buildSummaryRow("Total", total),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildShippingDetailsSection(),
                        const SizedBox(height: 20),
                        buildPlaceOrderButton(total),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              buildBottomNavigationBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSummaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            "₱${value.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildShippingDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Shipping Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: buyerName,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Buyer Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: shippingAddress,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Shipping Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedPaymentMethod,
            items:
                paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedPaymentMethod = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Payment Method',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlaceOrderButton(double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ElevatedButton(
        onPressed: () async {
          final uri = Uri.parse("http://192.168.68.116:5000/api/submit_order");

          final orderData = {
            "userId": widget.userId,
            "recipientName": buyerName,
            "shippingAddress": shippingAddress,
            "paymentMethod": selectedPaymentMethod,
            "shippingFee": shippingFee,
            "orderSummary":
                widget.selectedProducts.map((product) {
                  return {
                    "productName": product['product_name'],
                    "quantity":
                        int.tryParse(product['quantity'].toString()) ?? 1,
                    "totalPrice":
                        double.tryParse(product['price'].toString()) ?? 0.0,
                  };
                }).toList(),
          };

          try {
            final response = await http.post(
              uri,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(orderData),
            );

            if (!mounted) return;

            final responseData = jsonDecode(response.body);
            if (response.statusCode == 200 && responseData['success']) {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("Order Placed"),
                      content: const Text(
                        "Your order was placed successfully!",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        HomepageBuyer(userId: widget.userId),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Order failed: ${responseData['message']}"),
                ),
              );
            }
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("An error occurred. Please try again."),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 136, 75, 37),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "Place Order",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return Container(
      color: Colors.white,
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
            Navigator.push(
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
                builder: (context) => AddtoCartBuyerPage(userId: widget.userId),
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
