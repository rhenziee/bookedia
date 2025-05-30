import 'package:flutter/material.dart';
import 'conversation_thread.dart';

import 'buyer_cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'buyer_ordersummary.dart';

class BooksdetailsPage extends StatefulWidget {
  final int productId;
  final int userId;

  const BooksdetailsPage({
    super.key,
    required this.productId,
    required this.userId,
  });

  @override
  State<BooksdetailsPage> createState() => _BooksdetailsPageState();
}

class _BooksdetailsPageState extends State<BooksdetailsPage> {
  int quantity = 1;
  bool isLoading = true;
  bool isFeedbackLoading = true;
  Map<String, dynamic> productDetails = {};
  List<dynamic> feedbackList = [];

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    fetchProductFeedback();
  }

  Future<void> fetchProductDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.68.116:5000/api/get_product_details/${widget.productId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            productDetails = data['product'] ?? {};
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchProductFeedback() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.68.116:5000/api/get_product_feedback/${widget.productId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            feedbackList = data['feedbacks'] ?? [];
            isFeedbackLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load product feedback');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isFeedbackLoading = false;
        });
      }
    }
  }

  void increment() {
    setState(() {
      quantity++;
    });
  }

  void decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> addToCart() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.68.116:5000/api/add_to_cart'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId.toString(),
          'product_name': productDetails['product_name'],
          'quantity': quantity,
          'price':
              double.tryParse(productDetails['product_price'].toString()) ??
              0.0,
          'product_image': productDetails['product_image'],
        }),
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to cart successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Failed to add to cart')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  // Add this method inside _BooksdetailsPageState:
  void openConversationThread() {
    final otherUserId =
        productDetails['seller_id'] ?? productDetails['user_id'];
    if (otherUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seller information not available')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ConversationThreadPage(
              userId: widget.userId,
              otherUserId: otherUserId,
              productName: productDetails['product_name'] ?? '',
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_checkout, color: Colors.brown),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AddtoCartBuyerPage(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Image.network(
                        productDetails['product_image'] != null &&
                                productDetails['product_image'].isNotEmpty
                            ? 'http://192.168.68.116:5000/uploads/product_images/${productDetails['product_image']}'
                            : 'http://192.168.68.116:5000/uploads/product_images/default_image.png',
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF8EDE3),
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  productDetails['average_rating']
                                          ?.toString() ??
                                      '0.0',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₱${productDetails['product_price']?.toString() ?? '0.00'}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    productDetails['product_name'] ??
                                        'No name available',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: decrement,
                                      icon: const Icon(Icons.remove),
                                    ),
                                    Text(
                                      quantity.toString(),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    IconButton(
                                      onPressed: increment,
                                      icon: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Text(
                              'Description:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              productDetails['product_description'] ??
                                  'No description available',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const Text(
                              'Feedback:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            isFeedbackLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : feedbackList.isEmpty
                                ? const Text('No feedback available')
                                : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: feedbackList.length,
                                  itemBuilder: (context, index) {
                                    final feedback = feedbackList[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.brown,
                                            child: Text(
                                              feedback['rating'].toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  feedback['comment'] ??
                                                      'No comment',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Date: ${feedback['created_at']}',
                                                  style: const TextStyle(
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: openConversationThread,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.brown,
                              side: const BorderSide(color: Colors.brown),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Chat Now'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.brown,
                              side: const BorderSide(color: Colors.brown),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Add to Cart'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SummaryPageBuyer(
                                        userId: widget.userId,
                                        selectedProducts: [
                                          {
                                            "product_name":
                                                productDetails['product_name'],
                                            "product_image":
                                                productDetails['product_image'],
                                            "quantity": quantity,
                                            "price":
                                                double.tryParse(
                                                  productDetails['product_price']
                                                      .toString(),
                                                ) ??
                                                0.0,
                                          },
                                        ],
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Buy Now"),
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
