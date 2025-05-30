import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'buyer_home.dart';
import 'buyer_notif.dart';
import 'buyer_cart.dart';
import 'buyer_profile.dart';
import 'conversation_thread.dart';

class ChatBuyerPage extends StatefulWidget {
  final int userId;
  const ChatBuyerPage({super.key, required this.userId});

  @override
  State<ChatBuyerPage> createState() => _ChatBuyerPageState();
}

class _ChatBuyerPageState extends State<ChatBuyerPage> {
  List<Conversation> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    final url = Uri.parse(
      'http://192.168.68.116:5000/api/messages?user_id=${widget.userId}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      // ignore: avoid_print
      print('RESPONSE: $data'); // ← DEBUG
      setState(() {
        conversations = data.map((e) => Conversation.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      throw Exception('Failed to load messages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: const Text(
                "Messages",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 33, 19, 11),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                        itemCount: conversations.length,
                        separatorBuilder:
                            (context, index) => Divider(
                              color: Colors.grey.shade300,
                              indent: 25,
                              endIndent: 25,
                              thickness: 1,
                            ),
                        itemBuilder: (context, index) {
                          final convo = conversations[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.brown,
                              radius: 24,
                              child: Text(
                                convo.otherUserName.isNotEmpty
                                    ? convo.otherUserName[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            title: Text(
                              convo.otherUserName.isNotEmpty
                                  ? convo.otherUserName
                                  : "Unknown",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(convo.lastMessage),
                            trailing: Text(
                              convo.timestamp.split(' ').last,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ConversationThreadPage(
                                        userId: widget.userId,
                                        otherUserId: convo.otherUserId,
                                        productName: convo.productName,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
            Container(
              color: const Color.fromRGBO(255, 255, 255, 1),
              padding: const EdgeInsets.symmetric(horizontal: 10),
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

class Conversation {
  final int otherUserId;
  final String productName;
  final String otherUserName;
  final String lastMessage;
  final String timestamp;

  Conversation({
    required this.otherUserId,
    required this.productName,
    required this.otherUserName,
    required this.lastMessage,
    required this.timestamp,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      otherUserId: json['other_user_id'],
      productName: json['product_name'],
      otherUserName: json['other_user_name'],
      lastMessage: json['last_message'],
      timestamp: json['timestamp'],
    );
  }
}
