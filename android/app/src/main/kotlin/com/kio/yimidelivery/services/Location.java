package com.kio.yimidelivery.services;

import android.annotation.SuppressLint;
//import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.location.LocationManager;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.PowerManager;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import com.google.android.gms.location.FusedLocationProviderClient;
//import com.google.android.gms.location.LocationListener;
//import com.google.android.gms.location.LocationServices;
//import com.google.android.gms.tasks.OnSuccessListener;
import com.kio.yimidelivery.MainActivity;
import com.kio.yimidelivery.R;
import com.kio.yimidelivery.api.APIClient;

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
//import java.util.Objects;

import io.flutter.Log;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class Location extends Service {
    private String deviceID, token, idRepartidor;
    FusedLocationProviderClient client;
    Handler handler = new Handler();
    private String coords ="["; // "[\"12.2323, -123.1234\", ]";
    private int counter = 0;
    private PowerManager.WakeLock wakeLock;

    private static final String TAG = "SERVICE_LOCATION";
    private LocationManager mLocationManager = null;
    private static final int DELAY = 5000;
    private static final float LOCATION_DISTANCE = 10f;

    private static class LocationListener implements android.location.LocationListener {
        android.location.Location mLastLocation;

        LocationListener(String provider) {
            Log.e(TAG, "LocationListener " + provider);
            mLastLocation = new android.location.Location(provider);
        }

        @Override
        public void onLocationChanged(android.location.Location location) {
            Log.e(TAG, "onLocationChanged: " + location);
            mLastLocation.set(location);
        }

        @Override
        public void onProviderDisabled(String provider) {
            Log.e(TAG, "onProviderDisabled: " + provider);
        }

        @Override
        public void onProviderEnabled(String provider) {
            Log.e(TAG, "onProviderEnabled: " + provider);
        }

        @Override
        public void onStatusChanged(String provider, int status, Bundle extras) {
            Log.e(TAG, "onStatusChanged: " + provider);
        }
    }

    LocationListener[] mLocationListeners = new LocationListener[]{
            new LocationListener(LocationManager.GPS_PROVIDER),
            new LocationListener(LocationManager.NETWORK_PROVIDER)
    };

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        idRepartidor = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE).getString("flutter.id_usuario", null);
        deviceID = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE).getString("flutter.device_id", null);
        token = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE).getString("flutter.token", null);
        Log.i("ID_REPARTIDOR", idRepartidor);
        Log.i("DEVICE_ID", deviceID);
        Log.i("TOKEN", token);
//        client = LocationServices.getFusedLocationProviderClient(getApplicationContext());
        initializeLocationManager();
        try {
            mLocationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, DELAY, LOCATION_DISTANCE, mLocationListeners[1]);
        } catch (java.lang.SecurityException ex) {
            Log.i(TAG, "fail to request location update, ignore", ex);
        } catch (IllegalArgumentException ex) {
            Log.d(TAG, "network provider does not exist, " + ex.getMessage());
        }
        try {
            mLocationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, DELAY, LOCATION_DISTANCE, mLocationListeners[0]);
        } catch (java.lang.SecurityException ex) {
            Log.i(TAG, "fail to request location update, ignore", ex);
        } catch (IllegalArgumentException ex) {
            Log.d(TAG, "gps provider does not exist " + ex.getMessage());
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String name = "yimi_delivery";
            String description = "yimi_delivery_description";
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel mChannel = new NotificationChannel(name, name, importance);
            mChannel.setDescription(description);
            Uri soundUri = Uri.parse("android.resource://" + getApplicationContext().getPackageName() + "/" + R.raw.notification_sound);
            AudioAttributes audioAttributes = new AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build();
            mChannel.setSound(soundUri, audioAttributes);
            NotificationManager notificationManager = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);
            assert notificationManager != null;
            notificationManager.createNotificationChannel(mChannel);

            Intent notificationIntent = new Intent(this, MainActivity.class);
            PendingIntent pendingIntent = PendingIntent.getForegroundService(this, 0, notificationIntent, 0);

            Notification notification = new NotificationCompat.Builder(this, "yimi_delivery")
                    .setContentTitle("Foreground Service")
                    .setContentText("input")
                    .setContentIntent(pendingIntent)
                    .build();

            startForeground(1, notification);
        } else {
            Uri soundUri = Uri.parse("android.resource://" + getApplicationContext().getPackageName() + "/" + R.raw.notification_sound);
            Notification notification = new NotificationCompat.Builder(this, "yimi_delivery")
                    .setContentTitle("Foreground Service")
                    .setContentText("input")
                    .setSound(soundUri ,AudioManager.STREAM_NOTIFICATION)
                    .build();
            startForeground(1, notification);
        }
        start();
        return START_NOT_STICKY;//super.onStartCommand(intent, flags, startId);
    }

    @SuppressLint("InvalidWakeLockTag")
    @RequiresApi(api = Build.VERSION_CODES.M)
    private void start() {
        PowerManager mgr = (PowerManager)getSystemService(Context.POWER_SERVICE);
        assert mgr != null;
        wakeLock = mgr.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "LocationWakeLock");
        wakeLock.acquire();
//        int delay = 5000;
        handler.postDelayed(new Runnable() {
            @SuppressLint("MissingPermission")
            @Override
            public void run() {
                double latGPS = mLocationListeners[1].mLastLocation.getLatitude();
                double lngGPS = mLocationListeners[1].mLastLocation.getLongitude();
                double latNET = mLocationListeners[0].mLastLocation.getLatitude();
                double lngNET = mLocationListeners[0].mLastLocation.getLongitude();
                double lat, lng;
                if (latGPS == 0.0d && lngGPS == 0.0d) {
                    lat = latNET;
                    lng = lngNET;
                } else {
                    lat = latGPS;
                    lng = lngGPS;
                }
//                double lat = mLocationListeners[0].mLastLocation.getLatitude();
//                double lng = mLocationListeners[0].mLastLocation.getLongitude();
                if (counter == DELAY * 12) {
                    coords += "\""+lat+", "+lng+"\"]";
                    Log.i("API_CALL", coords);
                    call(coords);
                    counter = 0;
                    coords ="[";
                } else {
                    coords += "\""+lat+", "+lng+"\", ";
                    counter += DELAY;
                    Log.i("LAT_LNG", lat+", "+lng);
                }
                handler.postDelayed(this, DELAY);
            }
        }, DELAY);
    }

    private void call(String coords) {
             APIClient apiClient = new APIClient();
             Call<ResponseBody> call = apiClient.updateCooordenadasRepartidor(coords, idRepartidor);
             call.enqueue(new Callback<ResponseBody>() {
                 @Override
                 public void onResponse(@NotNull Call<ResponseBody> call, @NotNull Response<ResponseBody> response) {
                     Log.i("RESPONSE_WAS_SUCCESSFUL", String.valueOf(response.isSuccessful()));
                     try {
                         if (response.isSuccessful()){
                             assert response.body() != null;
                             Log.i("RESPONSE", response.body().string());
                         } else {
                             assert response.errorBody() != null;
                             Log.i("ERROR_RESPONSE", response.errorBody().string());
                         }
                     } catch (IOException e) {
                         e.printStackTrace();
                     }
                 }

                 @Override
                 public void onFailure(@NotNull Call<ResponseBody> call, @NotNull Throwable t) {
                     call.cancel();
                     t.printStackTrace();
                 }
             });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        handler.removeCallbacksAndMessages(null);
        wakeLock.release();
        if (mLocationManager != null) {
            for (LocationListener mLocationListener : mLocationListeners) {
                try {
                    mLocationManager.removeUpdates(mLocationListener);
                } catch (Exception ex) {
                    Log.i(TAG, "fail to remove location listners, ignore", ex);
                }
            }
        }
    }

    private void initializeLocationManager() {
        Log.e("LOCATION_MANGER", "initializeLocationManager");
        if (mLocationManager == null) {
            mLocationManager = (LocationManager) getApplicationContext().getSystemService(Context.LOCATION_SERVICE);
        }
    }
}
