package com.kio.yimidelivery

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.kio.yimidelivery.services.Location
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private var service: Intent? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        service = Intent(activity.applicationContext, Location::class.java)

        val fineLocation = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
        val coarseLocation = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION)
        if (fineLocation != PackageManager.PERMISSION_GRANTED && coarseLocation != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION), 101)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kio.yimidelivery/location").setMethodCallHandler { call, result ->
            if (call.method == "startServiceLocation") {
                startServiceLocation()
                result.success("Service started.")
            } else if (call.method == "stopServiceLocation") {
                stopServiceLocation()
                result.success("Service stopped.")
            }
        }
    }

    private fun startServiceLocation() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(service)
        } else {
            startService(service)
        }
    }

    private fun stopServiceLocation() {
        val ok = stopService(service)
        Log.i("SERVICE_STOPPED", ok.toString())
    }

//    override fun onDestroy() {
//        super.onDestroy()
//        val ok = stopService(service)
//        Log.i("isStopped", ok.toString());
//    }
}
