package com.example.sakin_app

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.sakin_app/adhan_playback"
    private var mediaPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startPlayback" -> {
                    startPlayback()
                    result.success(1)
                }
                "stopPlayback" -> {
                    stopPlayback()
                    result.success(1)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startPlayback() {
        try {
            stopPlayback() // Ensure any previous playback is stopped

            val resourceId = R.raw.adhan // Ensure adhan.mp3 exists in res/raw
            mediaPlayer = MediaPlayer.create(this, resourceId)
            
            if (mediaPlayer == null) {
                 // Fallback if resource not found or create failed
                 println("Adhan playback failed: MediaPlayer creation returned null")
                 return
            }

            mediaPlayer?.apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                setOnCompletionListener {
                    stopPlayback()
                }
                start()
            }
        } catch (e: Exception) {
            println("Error starting adhan playback: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun stopPlayback() {
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    override fun onDestroy() {
        stopPlayback()
        super.onDestroy()
    }
}

