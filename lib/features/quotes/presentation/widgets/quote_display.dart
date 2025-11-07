import 'package:flutter/material.dart';

class QuoteDisplay extends StatelessWidget {
  final String quote;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;

  const QuoteDisplay({
    super.key,
    required this.quote,
    required this.scaleAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scaleAnimation.value,
      child: Opacity(
        opacity: fadeAnimation.value,
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF3E8FF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.format_quote,
                  size: 48,
                  color: Color(0xFF9333EA),
                ),
                const SizedBox(height: 20),
                Text(
                  quote,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
