package com.laterhorse.storyboard.channels

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Environment
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat.requestPermissions
import androidx.core.app.ActivityCompat.startActivityForResult
import androidx.core.content.PermissionChecker
import androidx.core.content.PermissionChecker.checkSelfPermission
import com.google.zxing.integration.android.IntentIntegrator
import com.laterhorse.storyboard.MainActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.*
import java.text.SimpleDateFormat
import java.util.*

class CommandChannel {
    companion object {
        var CHANNEL_COMMANDS = "/COMMANDS"

        var CMD_TAKE_PHOTO = "CMD:TAKE_PHOTO"
        var CMD_IMPORT_PHOTO = "CMD:IMPORT_PHOTO"
        var CMD_TAKE_QR_CODE = "CMD:TAKE_QR_CODE"

        var REQUEST_READ_STORAGE_CODE = 999
        var REQUEST_IMAGE_CAPTURE = 1001
        var REQUEST_IMAGE_CHOOSE = 1002

        var LOG_TAG = CommandChannel::class.java.simpleName
    }

    lateinit var currentAbsolutePath : String
    lateinit var currentMethodChannelResult : MethodChannel.Result

    private fun createPhotoFile(activity: MainActivity): File {
        val ts: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val dir: File? = activity.getExternalFilesDir(Environment.DIRECTORY_PICTURES)
        return File.createTempFile("JPEG_${ts}_", ".jpeg", dir).apply { currentAbsolutePath = absolutePath }
    }

    private fun savePhoto(fOut: File , streamIn: InputStream) {
        fOut.outputStream().use { streamOut ->
            streamIn.copyTo(streamOut)
        }
    }

    private fun dispatchTakePictureIntent(activity: MainActivity, result: MethodChannel.Result) {
        currentMethodChannelResult = result
        try {
            createPhotoFile(activity).also { photoFile ->
                val photoURI: Uri = Uri.fromFile(photoFile)
                val intent = Intent(activity, CameraActivity::class.java).apply {
                    putExtra(CameraActivity.EXTRA_OUTPUT_FILENAME, photoURI.toString())
                }
                activity.startActivityForResult(intent, REQUEST_IMAGE_CAPTURE, null)
            }
        } catch (ex: IOException) {
            // error occurred
            ex.message?.let {
                result.run { error(it) }
            }
        }
    }

    private fun importPicture(activity: MainActivity) {
        val intent = Intent(Intent.ACTION_PICK)
        intent.type = "image/*"
        startActivityForResult(activity, intent, REQUEST_IMAGE_CHOOSE, null)
    }

    private fun dispatchImportPictureIntent(activity: MainActivity, result: MethodChannel.Result) {
        currentMethodChannelResult = result

        if (checkSelfPermission(activity, Manifest.permission.READ_EXTERNAL_STORAGE) == PermissionChecker.PERMISSION_DENIED) {
            val permissions = arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
            requestPermissions(activity, permissions, REQUEST_READ_STORAGE_CODE)
            return
        }
        importPicture(activity)
    }

    private fun dispatchTakeQRCodeIntent(activity: MainActivity, result: MethodChannel.Result) {
        currentMethodChannelResult = result

        val intent = IntentIntegrator(activity)
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
        val packageName = activity.packageName
        MethodChannel(flutterEngine.dartExecutor, "$packageName$CHANNEL_COMMANDS").setMethodCallHandler{
            call, result ->
            when(call.method) {
                CMD_TAKE_PHOTO -> {
                    Log.d(LOG_TAG, "CMD_TAKE_PHOTO")
                    dispatchTakePictureIntent(activity, result)
                }
                CMD_IMPORT_PHOTO -> {
                    Log.d(LOG_TAG, "CMD_IMPORT_PHOTO")
                    dispatchImportPictureIntent(activity, result)
                }
                CMD_TAKE_QR_CODE -> {
                    Log.d(LOG_TAG, "CMD_TAKE_QR_CODE")
                    dispatchTakeQRCodeIntent(activity, result)
                }
            }
        }
    }

    fun onRequestPermissionsResult(activity: MainActivity, requestCode: Int, grantResults: IntArray) {
        if (requestCode == REQUEST_READ_STORAGE_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                importPicture(activity)
            } else {
                currentMethodChannelResult.run { error("Permission denied") }
            }
        }
    }

    fun onActivityResult(activity: MainActivity, requestCode: Int, resultCode: Int, data: Intent?) : Boolean {
        // qr code scan
        Log.d(LOG_TAG, "onActivityResult")
        val result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
        if (result != null) {
            if (result.contents != null) {
                currentMethodChannelResult.success(result.contents)
            }
            return true
        }

        if (requestCode == REQUEST_IMAGE_CAPTURE) {
            if (resultCode == FlutterActivity.RESULT_OK) {
                Log.d(LOG_TAG, "CMD_TAKE_PHOTO got path: $currentAbsolutePath")
                currentMethodChannelResult.success(currentAbsolutePath)
            }
            return true
        }

        if (requestCode == REQUEST_IMAGE_CHOOSE) {
            if (resultCode == FlutterActivity.RESULT_OK && data != null && data.data != null) {
                val streamIn = activity.contentResolver.openInputStream(data.data as Uri)
                Log.d(LOG_TAG, "CMD_CHOOSE_PHOTO got: $streamIn")

                if (streamIn != null) {
                    createPhotoFile(activity).also { photoFile ->
                        savePhoto(photoFile, streamIn)
                        currentMethodChannelResult.success(currentAbsolutePath)
                    }
                }
            }
            return true
        }
        return false
    }
}