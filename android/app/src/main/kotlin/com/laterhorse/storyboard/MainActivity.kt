package com.laterhorse.storyboard

import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.laterhorse.storyboard.channels.CommandChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.*

class MainActivity: FlutterActivity() {

    companion object {
        var LOG_TAG = MainActivity::class.java.simpleName
    }

    lateinit var commandChannel: CommandChannel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        Log.d(LOG_TAG, "configureFlutterEngine");
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        this.flutterEngine?.run {
            commandChannel = CommandChannel();
            commandChannel.registerEngine(this@MainActivity, this);
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        commandChannel.onActivityResult(requestCode, resultCode);
        super.onActivityResult(requestCode, resultCode, data)
    }
}
