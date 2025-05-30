import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'buyer_home.dart';
import 'courier_home.dart';
import 'verify_email.dart';
import 'forgot_email.dart';
import 'splash_screen.dart';

void main() {
  runApp(
    const MaterialApp(home: SplashScreen(), debugShowCheckedModeBanner: false),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = Uri.parse('http://192.168.68.116:5000/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (responseData['success'] == true) {
      String userType = responseData['user_type'];
      int userId =
          responseData['user_id']; // 🛠 FIXED: Get userId from response

      if (!mounted) return;

      if (userType == 'buyer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomepageBuyer(userId: userId),
          ),
        );
      } else if (userType == 'courier') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CourierHomePage(userId: userId),
          ),
        );
      }
    } else {
      if (!mounted) return;

      // Show dialog box for error message
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Login Failed'),
              content: Text(responseData['message'] ?? 'Login failed'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    emailController.clear();
                    passwordController.clear();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B2B1D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFFFFAEE),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Image.asset('lib/assets/loginicon.png', height: 140),
                          const SizedBox(height: 40),
                          const Text(
                            'Log in to your account.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B3B1A),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Color(0xFF6B3B1A),
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Color(0xFF6B3B1A)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF6B3B1A),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF6B3B1A),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Color(0xFF6B3B1A),
                                ),
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Color(0xFF6B3B1A)),
                                suffixIcon: Icon(
                                  Icons.visibility,
                                  color: Color(0xFF6B3B1A),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF6B3B1A),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF6B3B1A),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: isLoading ? null : loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B3B1A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                            ),
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Log in',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF6B3B1A),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const EmailVerificationPage(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Sign up',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFFF7931E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const ForgotEmailVerificationPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFF6B3B1A),
                                      fontSize: 18,
                                      decoration:
                                          TextDecoration
                                              .underline, // optional styling
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF4B2B1D),
                        width: 10,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Image.asset(
                      'lib/assets/Bookedia.png',
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
