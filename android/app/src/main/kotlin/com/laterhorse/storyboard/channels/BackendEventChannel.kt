package com.laterhorse.storyboard.channels

import android.util.Log
import androidx.annotation.NonNull
import com.laterhorse.storyboard.MainActivity
import io.flutter.BuildConfig
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class BackendEventChannel {
    companion object {
        var CHANNEL_BACKENDS = "/BACKENDS"
        var BK_GET_DATAHOME = "BK:GET_DATA_HOME"

        var LOG_TAG = CommandChannel::class.java.simpleName
    }

    fun registerEngine(activity: MainActivity, @NonNull flutterEngine: FlutterEngine) {
        val packageName = activity.packageName
        MethodChannel(flutterEngine.dartExecutor, "$packageName${CHANNEL_BACKENDS}").setMethodCallHandler{
            call, result ->
            if (call.method.equals(BK_GET_DATAHOME)) {
                Log.d(LOG_TAG, "BK_GET_DATAHOME")

                var env = ""
                when {
                    BuildConfig.DEBUG -> env = "debug"
                    BuildConfig.PROFILE -> env = "profile"
                    BuildConfig.RELEASE -> env = "release"
                }
                val dirWithEnv = File(activity.filesDir.path + File.separator + env)
                result.success(dirWithEnv.absolutePath)
            }
        }
    }

}