
package com.example.shanke_quote_app

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt

class MainActivity: FlutterActivity(), SensorEventListener {
    private val METHOD_CHANNEL = "com.example.shake/methods"
    private val EVENT_CHANNEL = "com.example.shake/events"
    
    private var sensorManager: SensorManager? = null
    private var accelerometer: Sensor? = null
    private var eventSink: EventChannel.EventSink? = null
    
    // Shake detection parameters
    private var lastShakeTime: Long = 0
    private val SHAKE_THRESHOLD = 15.0 
    private val SHAKE_TIME_WINDOW = 500 
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup MethodChannel for start/stop commands
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startShakeDetection" -> {
                    startShakeDetection()
                    result.success(true)
                }
                "stopShakeDetection" -> {
                    stopShakeDetection()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        
        // Setup EventChannel for shake events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
        
        // Initialize sensor manager
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    }
    
    private fun startShakeDetection() {
        accelerometer?.let {
            sensorManager?.registerListener(
                this,
                it,
                SensorManager.SENSOR_DELAY_NORMAL
            )
        }
    }
    
    private fun stopShakeDetection() {
        sensorManager?.unregisterListener(this)
    }
    
    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_ACCELEROMETER) {
            val x = event.values[0]
            val y = event.values[1]
            val z = event.values[2]
            
            // Calculate acceleration magnitude (excluding gravity)
            val acceleration = sqrt((x * x + y * y + z * z).toDouble()) - SensorManager.GRAVITY_EARTH
            
            // Detect shake
            if (acceleration > SHAKE_THRESHOLD) {
                val currentTime = System.currentTimeMillis()
                
                // Prevent multiple rapid detections
                if (currentTime - lastShakeTime > SHAKE_TIME_WINDOW) {
                    lastShakeTime = currentTime
                    
                    // Send shake event to Flutter
                    eventSink?.success("shake_detected")
                }
            }
        }
    }
    
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Not needed for this implementation
    }
    
    override fun onDestroy() {
        super.onDestroy()
        stopShakeDetection()
    }
}
