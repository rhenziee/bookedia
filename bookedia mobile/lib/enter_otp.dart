import 'package:flutter/material.dart';
import 'main.dart';
import 'registrationform.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EnterotpPage extends StatefulWidget {
  final String email;
  const EnterotpPage({super.key, required this.email});

  @override
  State<EnterotpPage> createState() => _EnterotpPageState();
}

class _EnterotpPageState extends State<EnterotpPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => EnterotpPageDialog(email: widget.email),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white);
  }
}

class EnterotpPageDialog extends StatelessWidget {
  final String email;
  const EnterotpPageDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final List<TextEditingController> otpControllers = List.generate(
      6,
      (_) => TextEditingController(),
    );
    final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 350,
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
              "OTP Verification",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: "Times New Roman",
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please enter the code we have sent you.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      counterText: "",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        focusNodes[index - 1].requestFocus();
                      }
                    },
                    onSubmitted: (_) {
                      if (index == 5) {
                        FocusScope.of(context).unfocus(); // hide keyboard
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final otpCode = otpControllers.map((c) => c.text).join();

                if (otpCode.length != 6 ||
                    !RegExp(r'^\d{6}$').hasMatch(otpCode)) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text("Invalid OTP"),
                            content: const Text(
                              "Please enter a valid 6-digit OTP.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                    );
                  }
                  return;
                }

                try {
                  final response = await http.post(
                    Uri.parse('http://192.168.68.116:5000/api/enter_otp'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'email': email, 'otp': otpCode}),
                  );

                  if (!context.mounted) return;

                  final data = jsonDecode(response.body);
                  if (response.statusCode == 200 && data['success']) {
                    // Success Dialog
                    await showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text("Success"),
                            content: const Text("OTP verified successfully!"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                    );

                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) => RegistrationPage(verifiedEmail: email),
                      ),
                    );
                  } else {
                    // Error Dialog
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text("Verification Failed"),
                            content: Text(data['message'] ?? 'Unknown error'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Error"),
                          content: Text("An error occurred: $e"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("OK"),
                            ),
                          ],
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
                "Verify OTP",
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
