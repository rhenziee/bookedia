import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import 'buyer_cart.dart';
import 'buyer_chat.dart';
import 'buyer_notif.dart';
import 'buyer_profile.dart';
import 'buyer_detailsprod.dart';

class HomepageBuyer extends StatefulWidget {
  final int userId;

  const HomepageBuyer({super.key, required this.userId});

  @override
  State<HomepageBuyer> createState() => _HomepageBuyerState();
}

class _HomepageBuyerState extends State<HomepageBuyer> {
  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
    searchController.addListener(() {
      searchProducts(searchController.text);
    });
  }

  Future<void> fetchAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.68.116:5000/api/buyer_home_mobile'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final products = decoded['all_products'] ?? [];

        setState(() {
          allProducts = products;
          filteredProducts = products;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchProducts(String query) {
    setState(() {
      filteredProducts =
          allProducts.where((product) {
            final name = product['product_name']?.toLowerCase() ?? '';
            final desc = product['product_description']?.toLowerCase() ?? '';
            return name.contains(query.toLowerCase()) ||
                desc.contains(query.toLowerCase());
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header with logo and background
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
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search, size: 21),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'All Products',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 33, 19, 11),
                  ),
                ),
              ),
            ),

            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: GridView.builder(
                          itemCount: filteredProducts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 0.6,
                              ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return buildProductItem(product);
                          },
                        ),
                      ),
            ),
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
                    Navigator.pushReplacement(
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

  Widget buildProductItem(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BooksdetailsPage(
                  productId: product['id'],
                  userId: widget.userId,
                ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  "http://192.168.68.116:5000/uploads/product_images/${product['product_image']}",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product['product_name'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  (double.tryParse(product['average_rating'].toString()) ?? 0.0)
                      .toStringAsFixed(1),
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "₱${(double.tryParse(product['product_price'].toString()) ?? 0.0).toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.brown,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Stock: ${product['product_quantity']}",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
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
}
