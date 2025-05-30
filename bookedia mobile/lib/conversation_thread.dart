import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For formatting timestamps

class ConversationThreadPage extends StatefulWidget {
  final int userId;
  final int otherUserId;
  final String productName;

  const ConversationThreadPage({
    super.key,
    required this.userId,
    required this.otherUserId,
    required this.productName,
  });

  @override
  State<ConversationThreadPage> createState() => _ConversationThreadPageState();
}

class _ConversationThreadPageState extends State<ConversationThreadPage> {
  List messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    final url = Uri.parse(
      'http://192.168.68.116:5000/api/conversation?user_id=${widget.userId}&other_user_id=${widget.otherUserId}&product_name=${Uri.encodeComponent(widget.productName)}',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        messages = json.decode(response.body);
      });
      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  Future<void> sendMessage(String text) async {
    final url = Uri.parse('http://192.168.68.116:5000/api/send_message');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "sender_id": widget.userId,
        "recipient_id": widget.otherUserId,
        "product_name": widget.productName,
        "message": text,
      }),
    );
    if (response.statusCode == 200) {
      _controller.clear();
      await loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B4513),
        title: Text(
          widget.productName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),

        centerTitle: true,
        elevation: 3,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender_id'] == widget.userId;
                String formattedTime = '';
                final rawTimestamp = msg['timestamp'];
                if (rawTimestamp != null &&
                    rawTimestamp.toString().isNotEmpty) {
                  try {
                    final dateTime = DateTime.parse(rawTimestamp);
                    formattedTime = DateFormat.jm().format(
                      dateTime,
                    ); // e.g., "5:30 PM"
                  } catch (e) {
                    formattedTime = ''; // or fallback to rawTimestamp if needed
                  }
                }

                return Container(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment:
                        isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isMe
                                  ? const Color(0xFFD1E7DD)
                                  : const Color(0xFFE2E3E5),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(isMe ? 12 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 12),
                          ),
                        ),
                        child: Text(
                          msg['message'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF8B4513),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        sendMessage(_controller.text.trim());
                      }
                    },
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
