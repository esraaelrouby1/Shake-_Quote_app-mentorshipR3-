import 'package:flutter/material.dart';
import 'features/quotes/presentation/screens/shake_screen.dart';

void main() {
  runApp(const ShakeQuoteApp());
}

class ShakeQuoteApp extends StatelessWidget {
  const ShakeQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Shake for Motivation",
      home: const ShakeScreen(),
    );
  }
}
