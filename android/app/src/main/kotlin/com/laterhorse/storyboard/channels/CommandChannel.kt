package com.laterhorse.storyboard.channels

import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import com.google.zxing.integration.android.IntentIntegrator
import com.laterhorse.storyboard.MainActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class CommandChannel {
    companion object {
        var CHANNEL_COMMANDS = "/COMMANDS"

        var CMD_TAKE_PHOTO = "CMD:TAKE_PHOTO";
        var CMD_TAKE_QRCODE = "CMD:TAKE_QRCODE";

        var REQUEST_IMAGE_CAPTURE = 1001

        var LOG_TAG = CommandChannel::class.java.simpleName
    }

    lateinit var currentAbsolutePath : String
    lateinit var currentMethodChannelResult : MethodChannel.Result

    private fun createPhotoFile(activity: MainActivity): File {
        var ts: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        var dir: File? = activity.getExternalFilesDir(Environment.DIRECTORY_PICTURES)
        return File.createTempFile("JPEG_${ts}_", ".jpeg", dir).apply { currentAbsolutePath = absolutePath }
    }

    private fun dispatchTakePictureIntent(activity: MainActivity, result: MethodChannel.Result) {
        currentMethodChannelResult = result
        Intent(MediaStore.ACTION_IMAGE_CAPTURE).also { takePictureIntent ->
            takePictureIntent.resolveActivity(activity.packageManager)?.also {
                var photoFile : File
                try {
                    photoFile = createPhotoFile(activity);
                } catch (ex: IOException) {
                    // error occurred
                    ex.message?.let {
                        result.run { error(it) }
                    }
                    return@also
                }

                photoFile.also {
                    val photoURI: Uri = FileProvider.getUriForFile(activity, "com.laterhorse.storyboard.fileprovider", it)
                    takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
                    activity.startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE)
                }
            }
        }
    }

    private fun dispatchTakeQRCodeIntent(activity: MainActivity, result: MethodChannel.Result) {
        currentMethodChannelResult = result;

        var intent = IntentIntegrator(activity)
        intent.captureActivity = QRCodeScannerActivity::class.java
        intent.setDesiredBarcodeFormats(IntentIntegrator.QR_CODE)
        intent.setCameraId(0)
        intent.setPrompt("")
        intent.setBeepEnabled(false)
        intent.setBarcodeImageEnabled(false)
        intent.setOrientationLocked(false)
        intent.initiateScan()
    }

    fun registerEngine(activity: MainActivity, @NonNull flutterEngine: FlutterEngine) {
        var packageName = activity.packageName
        MethodChannel(flutterEngine.dartExecutor, "$packageName$CHANNEL_COMMANDS").setMethodCallHandler{
            call, result ->
            if (call.method.equals(CMD_TAKE_PHOTO)) {
                Log.d(LOG_TAG, "CMD_TAKE_PHOTO");
                dispatchTakePictureIntent(activity, result);
            } else if (call.method.equals(CMD_TAKE_QRCODE)) {
                Log.d(LOG_TAG, "CMD_TAKE_QRCODE");
                dispatchTakeQRCodeIntent(activity, result);
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) : Boolean {
        // qr code scan
        Log.d(LOG_TAG, "onActivityResult")
        var result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
        if (result != null) {
            if (result.contents != null) {
                currentMethodChannelResult.success(result.contents)
            }
            return true;
        }

        if (requestCode == REQUEST_IMAGE_CAPTURE) {
            if (resultCode == FlutterActivity.RESULT_OK) {
                Log.d(LOG_TAG, "CMD_TAKE_PHOTO got path: $currentAbsolutePath");
                currentMethodChannelResult.success(currentAbsolutePath);
            }
            return true;
        }
        return false;
    }
}