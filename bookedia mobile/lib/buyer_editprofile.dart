import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'buyer_home.dart';
import 'buyer_chat.dart';
import 'buyer_cart.dart';
import 'buyer_notif.dart';
import 'dart:convert';

class EditProfileBuyer extends StatefulWidget {
  final int userId;
  const EditProfileBuyer({super.key, required this.userId});

  @override
  State<EditProfileBuyer> createState() => _EditProfileBuyerState();
}

class _EditProfileBuyerState extends State<EditProfileBuyer> {
  int _selectedIndex = 4;

  final TextEditingController surnameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController middleInitialController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatBuyerPage(userId: widget.userId),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationBuyerPage(userId: widget.userId),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomepageBuyer(userId: widget.userId),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddtoCartBuyerPage(userId: widget.userId),
          ),
        );
        break;
    }
  }

  void fetchProfile() async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.68.116:5000/api/buyer/${widget.userId}/profile',
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        surnameController.text = data['surname'] ?? '';
        nameController.text = data['firstname'] ?? '';
        middleInitialController.text = data['middle_initial'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['contact'] ?? '';
        addressController.text = data['address'] ?? '';
        passwordController.text = data['password'] ?? '';
      });
    }
  }

  void updateProfile() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'http://192.168.68.116:5000/api/buyer/${widget.userId}/profile',
      ),
    );
    request.fields['surname'] = surnameController.text;
    request.fields['firstname'] = nameController.text;
    request.fields['middle_initial'] = middleInitialController.text;
    request.fields['email'] = emailController.text;
    request.fields['contact'] = phoneController.text;
    request.fields['address'] = addressController.text;
    request.fields['password'] = passwordController.text;

    var response = await request.send();
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/homepage.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(left: 10, top: 120),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color.fromARGB(255, 33, 19, 11),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color.fromARGB(255, 33, 19, 11),
                  ),
                ),
                const SizedBox(height: 10),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color.fromARGB(255, 33, 19, 11),
                  child: Text(
                    "👤",
                    style: TextStyle(fontSize: 35, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                buildTextField("Surname", surnameController),
                buildTextField("First Name", nameController),
                buildTextField("Middle Initial", middleInitialController),
                buildTextField("Email", emailController),
                buildTextField("Phone", phoneController),
                buildTextField("Address", addressController),
                buildTextField("Password", passwordController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A4C1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 140,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color.fromRGBO(255, 255, 255, 0.9),
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            navItem(
              "lib/assets/chat.png",
              "Chat",
              () => _onItemTapped(0),
              isSelected: _selectedIndex == 0,
            ),
            navItem(
              "lib/assets/notifications.png",
              "Notifications",
              () => _onItemTapped(1),
              isSelected: _selectedIndex == 1,
            ),
            navItem(
              "lib/assets/home.png",
              "Home",
              () => _onItemTapped(2),
              isSelected: _selectedIndex == 2,
            ),
            navItem(
              "lib/assets/cart.png",
              "Cart",
              () => _onItemTapped(3),
              isSelected: _selectedIndex == 3,
            ),
            navItem(
              "lib/assets/user.png",
              "Profile",
              () {},
              isSelected: _selectedIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          fillColor: Color.fromARGB(255, 248, 240, 230),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 219, 198, 178),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 219, 198, 178),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget navItem(
    String iconPath,
    String label,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
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
          Image.asset(
            iconPath,
            height: 30,
            color: isSelected ? const Color(0xFF8A4C1E) : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color:
                  isSelected
                      ? const Color(0xFF8A4C1E)
                      : const Color.fromARGB(255, 67, 40, 24),
            ),
          ),
        ],
      ),
    );
  }
}
