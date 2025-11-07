import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/utils/shake_service.dart';
import '../../data/quotes_list.dart';
import '../widgets/initial_state.dart';
import '../widgets/quote_display.dart';
import '../widgets/shake_counter.dart';

class ShakeScreen extends StatefulWidget {
  const ShakeScreen({super.key});

  @override
  State<ShakeScreen> createState() => _ShakeScreenState();
}

class _ShakeScreenState extends State<ShakeScreen>
    with TickerProviderStateMixin {
  late ShakeService _shakeService;

  String _currentQuote = "";
  int _shakeCount = 0;
  bool _hasShaken = false;

  late AnimationController _scaleController;
  late AnimationController _fadeController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeService = ShakeService();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.8,
      upperBound: 1.2,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _shakeService.start(_onShakeDetected);
  }

  void _onShakeDetected() {
    setState(() {
      _shakeCount++;
      _currentQuote = quotes[Random().nextInt(quotes.length)];
      _hasShaken = true;

      _scaleController.forward(from: 0.8);
      _fadeController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _shakeService.stop();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Shake for Motivation"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9333EA), Color(0xFFEC4899), Color(0xFFEF4444)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: !_hasShaken
                      ? const InitialState()
                      : AnimatedBuilder(
                          animation: Listenable.merge([
                            _scaleController,
                            _fadeController,
                          ]),
                          builder: (context, _) {
                            return QuoteDisplay(
                              quote: _currentQuote,
                              scaleAnimation: _scaleAnimation,
                              fadeAnimation: _fadeAnimation,
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 30),
              ShakeCounter(count: _shakeCount),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
