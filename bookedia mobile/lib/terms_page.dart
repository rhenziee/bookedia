import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Agreements'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Last Updated: April 15, 2025\n\n'
          'Welcome to Bookedia, your trusted platform for buying and selling books. \n'
          'By creating an account on Bookedia,you agree to provide accurate and up-to-date information and to keep your login credentials confidential. You must be at least 18 years old or of legal age in your jurisdiction to register. Your account is personal and non-transferable, and any use must comply with applicable laws and these Terms. We reserve the right to suspend or terminate accounts that violate our policies or engage in fraudulent, abusive, or suspicious activity.\n'
          'By signing up, you consent to the collection and use of your personal information as outlined in our Privacy Policy. You also agree to receive transactional and promotional communications from us, with the option to unsubscribe from marketing messages at any time. We may update these Terms periodically, and continued use of your account indicates your acceptance of any changes.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
