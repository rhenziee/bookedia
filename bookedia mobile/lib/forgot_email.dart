import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'forgot_otp.dart';
import 'main.dart';
import 'dart:convert';

class ForgotEmailVerificationPage extends StatefulWidget {
  const ForgotEmailVerificationPage({super.key});

  @override
  State<ForgotEmailVerificationPage> createState() =>
      _ForgotEmailVerificationPageState();
}

class _ForgotEmailVerificationPageState
    extends State<ForgotEmailVerificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const EmailVerificationDialog(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white);
  }
}

class EmailVerificationDialog extends StatelessWidget {
  const EmailVerificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF5C2E12),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
            const Text(
              "Email Verification",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please enter your active email address.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "Your e-mail",
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();

                if (email.isEmpty || !email.contains('@')) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid email address'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final response = await http.post(
                    Uri.parse(
                      'http://192.168.68.116:5000/api/forgot_verify_email',
                    ),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'email': email}),
                  );

                  if (!context.mounted) return;

                  if (response.statusCode == 200) {
                    final responseBody = jsonDecode(response.body);
                    if (responseBody['success']) {
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => ForgotEnterotpPage(email: email),
                        ),
                      );
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(responseBody['message']),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to send OTP: ${response.body}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7EED3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 10,
                ),
                shadowColor: Colors.black,
                elevation: 5,
              ),
              child: const Text(
                "Send OTP",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
