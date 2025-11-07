// ==================== FLUTTER CODE ====================
// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const ShakeQuoteApp());
}

class ShakeQuoteApp extends StatelessWidget {
  const ShakeQuoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shake for Motivation',
      theme: ThemeData(primarySwatch: Colors.purple, useMaterial3: true),
      home: const QuoteScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({Key? key}) : super(key: key);

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen>
    with SingleTickerProviderStateMixin {
  // Communication channels
  static const EventChannel _shakeEventChannel = EventChannel(
    'com.example.shake/events',
  );
  static const MethodChannel _shakeMethodChannel = MethodChannel(
    'com.example.shake/methods',
  );

  // State variables
  String? _currentQuote;
  int _shakeCount = 0;
  StreamSubscription? _shakeSubscription;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Motivational quotes
  final List<String> _quotes = [
    "Believe you can and you're halfway there.\n— Theodore Roosevelt",
    "Success is not final, failure is not fatal: It is the courage to continue that counts.\n— Winston Churchill",
    "The only way to do great work is to love what you do.\n— Steve Jobs",
    "Don't watch the clock; do what it does. Keep going.\n— Sam Levenson",
    "The future belongs to those who believe in the beauty of their dreams.\n— Eleanor Roosevelt",
    "It always seems impossible until it's done.\n— Nelson Mandela",
    "You are never too old to set another goal or to dream a new dream.\n— C.S. Lewis",
    "Success is stumbling from failure to failure with no loss of enthusiasm.\n— Winston Churchill",
    "The only limit to our realization of tomorrow will be our doubts of today.\n— Franklin D. Roosevelt",
    "Do not wait to strike till the iron is hot; but make it hot by striking.\n— William Butler Yeats",
    "Education is the most powerful weapon which you can use to change the world.\n— Nelson Mandela",
    "The expert in anything was once a beginner.\n— Helen Hayes",
    "Your limitation—it's only your imagination.\n— Unknown",
    "Great things never come from comfort zones.\n— Unknown",
    "Dream it. Wish it. Do it.\n— Unknown",
  ];

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _initializeShakeDetection();
  }

  Future<void> _initializeShakeDetection() async {
    try {
      // Start shake detection via MethodChannel
      await _shakeMethodChannel.invokeMethod('startShakeDetection');

      // Listen for shake events via EventChannel
      _shakeSubscription = _shakeEventChannel.receiveBroadcastStream().listen(
        (event) {
          if (event == 'shake_detected') {
            _onShakeDetected();
          }
        },
        onError: (error) {
          debugPrint('Shake detection error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize shake detection: $e');
    }
  }

  void _onShakeDetected() {
    setState(() {
      _shakeCount++;
      _currentQuote = _quotes[Random().nextInt(_quotes.length)];
    });

    // Trigger animation
    _animationController.forward(from: 0.0);

    // Provide haptic feedback
    HapticFeedback.mediumImpact();
  }

  Future<void> _stopShakeDetection() async {
    try {
      await _shakeMethodChannel.invokeMethod('stopShakeDetection');
    } catch (e) {
      debugPrint('Failed to stop shake detection: $e');
    }
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    _stopShakeDetection();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF9333EA), // purple-600
              Color(0xFFEC4899), // pink-500
              Color(0xFFEF4444), // red-500
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                        SizedBox(width: 8),
                        Text(
                          'Shake for Motivation',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shake your phone to get inspired!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Quote Display Area
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _currentQuote == null
                        ? _buildInitialState()
                        : _buildQuoteDisplay(),
                  ),
                ),
              ),

              // Shake Counter
              Container(
                margin: const EdgeInsets.all(24.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Shakes Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_shakeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🤳', style: TextStyle(fontSize: 80)),
            SizedBox(height: 20),
            Text(
              'Shake your phone!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Get instant motivation whenever you need it',
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteDisplay() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
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
                      _currentQuote!,
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
      },
    );
  }
}
