package com.laterhorse.storyboard

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Parcelable
import android.util.Log
import androidx.annotation.NonNull
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.analytics.ktx.logEvent
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
        firebaseAnalytics = Firebase.analytics
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        this.intent = intent
    }

    override fun onResume() {
        if (intent.action == Intent.ACTION_SEND) {
            if ("text/plain" == intent.type) {
                handleText(intent)
            } else if (intent.type?.startsWith("image/") == true) {
                handlePhoto(intent)
            }
            intent = null
        }
        super.onResume()
    }

    private fun handleText(intent: Intent) {
        intent.getStringExtra(Intent.EXTRA_TEXT).let {
            if (it != null) {
                commandChannel.shareInText(it)
            }
        }
    }

    private fun handlePhoto(intent: Intent) {
        (intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM) as? Uri)?.let {
            commandChannel.shareInPhoto(this, it)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        commandChannel.onRequestPermissionsResult(this@MainActivity, requestCode, grantResults)
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        this.flutterEngine?.run {
            commandChannel = CommandChannel()
            commandChannel.registerEngine(this@MainActivity, this)

            backendEventsChannel = BackendEventChannel()
            backendEventsChannel.registerEngine(this@MainActivity, this)

            firebaseAnalytics.logEvent(FirebaseAnalytics.Event.APP_OPEN){}
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        commandChannel.onActivityResult(this@MainActivity, requestCode, resultCode, data)
        super.onActivityResult(requestCode, resultCode, data)
    }
}
