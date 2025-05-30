import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HistorypageBuyer extends StatefulWidget {
  const HistorypageBuyer({super.key});

  @override
  State<HistorypageBuyer> createState() => _HistorypageBuyerState();
}

class _HistorypageBuyerState extends State<HistorypageBuyer> {
  int selectedTab = 0;
  List<dynamic> orders = [];

  final List<Map<String, String>> statuses = [
    {"label": "Pending", "statusKey": "pending", "icon": "lib/assets/chat.png"},
    {
      "label": "To Ship",
      "statusKey": "toship",
      "icon": "lib/assets/shipping.png",
    },
    {
      "label": "Out for Delivery",
      "statusKey": "outfordelivery",
      "icon": "lib/assets/delivery.png",
    },
    {
      "label": "Completed",
      "statusKey": "completed",
      "icon": "lib/assets/completed.png",
    },
    {
      "label": "Cancelled",
      "statusKey": "cancelled",
      "icon": "lib/assets/cancelled.png",
    },
    {
      "label": "Returned/Refund",
      "statusKey": "returned",
      "icon": "lib/assets/return.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final statusKey = statuses[selectedTab]['statusKey']!;
    final url = Uri.parse("http://192.168.68.116:5000/api/orders/$statusKey");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> fetchedOrders = json.decode(response.body);
        setState(() {
          orders = fetchedOrders;
        });
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching orders: $e");
    }
  }

  Future<void> showCancelDialog(int? orderId) async {
    if (orderId == null) return;

    String? selectedReason;
    final List<String> reasons = [
      "Ordered by mistake",
      "Found a better price",
      "Item will not arrive on time",
      "Changed my mind",
      "Other",
    ];

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Cancel Order"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Reason for cancellation:"),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  items:
                      reasons.map((reason) {
                        return DropdownMenuItem<String>(
                          value: reason,
                          child: Text(reason),
                        );
                      }).toList(),
                  onChanged: (value) => selectedReason = value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedReason == null) return;
                  final url = Uri.parse(
                    "http://192.168.68.116:5000/api/cancel_order/$orderId",
                  );

                  try {
                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({"cancellation_reason": selectedReason}),
                    );
                    if (response.statusCode == 200) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      fetchOrders();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Order cancelled successfully"),
                        ),
                      );
                    } else {
                      final body = json.decode(response.body);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed: ${body['error']}")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      // ignore: use_build_context_synchronously
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
    );
  }

  Future<void> showReturnDialog(int orderId) async {
    String? selectedReason;
    final List<String> reasons = [
      "Item damaged",
      "Received wrong item",
      "Item not as described",
      "No longer needed",
      "Other",
    ];

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Return/Refund"),
            content: DropdownButtonFormField<String>(
              value: selectedReason,
              items:
                  reasons.map((reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
              onChanged: (value) => selectedReason = value,
              decoration: const InputDecoration(
                labelText: "Select a reason",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedReason == null) return;
                  final url = Uri.parse(
                    "http://192.168.68.116:5000/api/return_order/$orderId",
                  );

                  try {
                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({"reason": selectedReason}),
                    );
                    if (response.statusCode == 200) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      fetchOrders();
                      // ignore: use_build_context_synchronously
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Return/Refund requested"),
                        ),
                      );
                    } else {
                      final body = json.decode(response.body);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed: ${body['error']}")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      // ignore: use_build_context_synchronously
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
    );
  }

  // feedback
  Future<void> showFeedbackDialog(Map<String, dynamic> order) async {
    // ignore: no_leading_underscores_for_local_identifiers
    final _commentController = TextEditingController();
    double rating = 3;
    XFile? selectedImage;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Give Feedback"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Comment",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("Rating: ${rating.toInt()}"),
                        Slider(
                          value: rating,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: rating.toInt().toString(),
                          onChanged: (value) => setState(() => rating = value),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              setState(() => selectedImage = image);
                            }
                          },
                          child: Text(
                            selectedImage == null
                                ? "Attach Photo"
                                : "Photo Selected",
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final uri = Uri.parse(
                          "http://192.168.68.116:5000/api/submit_feedback",
                        );
                        final request = http.MultipartRequest("POST", uri);

                        request.fields['order_id'] =
                            order['order_id'].toString();
                        request.fields['comment'] = _commentController.text;
                        request.fields['rating'] = rating.toInt().toString();
                        request.fields['product_name'] = order['product_name'];

                        if (selectedImage != null) {
                          request.files.add(
                            await http.MultipartFile.fromPath(
                              'photo',
                              selectedImage!.path,
                            ),
                          );
                        }

                        try {
                          final response = await request.send();
                          if (response.statusCode == 200) {
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Feedback submitted"),
                              ),
                            );
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to submit feedback"),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(
                            // ignore: use_build_context_synchronously
                            context,
                          ).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6ED),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Order History",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: statuses.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedTab == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = index;
                      });
                      fetchOrders();
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFFFDF6ED)
                                : const Color.fromARGB(255, 248, 240, 230),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color.fromARGB(255, 67, 40, 24)
                                  : Colors.black12,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            statuses[index]['icon']!,
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            statuses[index]['label']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color:
                                  isSelected
                                      ? const Color.fromARGB(255, 67, 40, 34)
                                      : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 136, 75, 37),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statuses[selectedTab]['label']!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  orders.isEmpty
                      ? const Center(child: Text("No orders found"))
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return buildOrderItem(order);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderItem(Map<String, dynamic> order) {
    final int? orderId = order['order_id'];
    // ignore: unused_local_variable
    final status =
        (order['status'] ?? 'pending')
            .toString()
            .toLowerCase()
            .replaceAll(' ', '')
            .trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "http://192.168.68.116:5000/uploads/product_images/${order['product_image']}",
              width: 60,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 60),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['product_name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Quantity: ${order['quantity']}",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "₱${order['total_price']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "To: ${order['recipient_name']}",
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  "Address: ${order['shipping_address']}",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (statuses[selectedTab]['statusKey'] == 'pending' &&
                        orderId != null)
                      OutlinedButton(
                        onPressed: () => showCancelDialog(orderId),
                        child: const Text(
                          "Cancel Order",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    if (statuses[selectedTab]['statusKey'] ==
                            'outfordelivery' &&
                        orderId != null) ...[
                      OutlinedButton(
                        onPressed: () => showReturnDialog(orderId),

                        child: const Text(
                          "Return/Refund",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),

                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () async {
                          final url = Uri.parse(
                            "http://192.168.68.116:5000/api/order_received/$orderId",
                          );

                          try {
                            final response = await http.post(url);
                            if (response.statusCode == 200) {
                              fetchOrders();
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Order marked as received"),
                                ),
                              );
                            } else {
                              final body = json.decode(response.body);
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed: ${body['error']}"),
                                ),
                              );
                            }
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },
                        child: const Text(
                          "Order Received",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    if (statuses[selectedTab]['statusKey'] == 'completed')
                      OutlinedButton(
                        onPressed: () => showFeedbackDialog(order),

                        child: const Text(
                          "Give Feedback",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
