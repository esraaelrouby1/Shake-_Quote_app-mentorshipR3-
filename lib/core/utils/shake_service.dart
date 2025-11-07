import 'dart:async';
import 'package:flutter/services.dart';

class ShakeService {
  static const EventChannel _shakeEventChannel = EventChannel(
    'com.example.shake/events',
  );

  static const MethodChannel _shakeMethodChannel = MethodChannel(
    'com.example.shake/methods',
  );

  StreamSubscription? _shakeSubscription;

  Future<void> start(void Function() onShake) async {
    try {
      await _shakeMethodChannel.invokeMethod('startShakeDetection');

      _shakeSubscription = _shakeEventChannel.receiveBroadcastStream().listen((
        event,
      ) {
        if (event == 'shake_detected') {
          onShake();
        }
      });
    } catch (e) {
      print("Shake service error: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _shakeMethodChannel.invokeMethod('stopShakeDetection');
      await _shakeSubscription?.cancel();
    } catch (e) {
      print("Stop shake error: $e");
    }
  }
}
