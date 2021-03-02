package com.laterhorse.storyboard

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.analytics.ktx.logEvent
import com.google.firebase.crashlytics.internal.common.CrashlyticsCore
import com.google.firebase.crashlytics.internal.model.CrashlyticsReport
import com.google.firebase.ktx.Firebase
import com.laterhorse.storyboard.channels.BackendEventChannel
import com.laterhorse.storyboard.channels.CommandChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.*

class MainActivity: FlutterActivity() {

    companion object {
        var LOG_TAG = MainActivity::class.java.simpleName
    }

    private lateinit var firebaseAnalytics: FirebaseAnalytics

    lateinit var commandChannel: CommandChannel
    lateinit var backendEventsChannel: BackendEventChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        firebaseAnalytics = Firebase.analytics;
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        Log.d(LOG_TAG, "configureFlutterEngine");
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        this.flutterEngine?.run {
            commandChannel = CommandChannel();
            commandChannel.registerEngine(this@MainActivity, this)

            backendEventsChannel = BackendEventChannel()
            backendEventsChannel.registerEngine(this@MainActivity, this)

            firebaseAnalytics.logEvent(FirebaseAnalytics.Event.APP_OPEN){}
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        commandChannel.onActivityResult(requestCode, resultCode, data);
        super.onActivityResult(requestCode, resultCode, data)
    }
}
