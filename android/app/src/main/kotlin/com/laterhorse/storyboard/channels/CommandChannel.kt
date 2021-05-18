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
import androidx.core.content.FileProvider
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

        var CMD_READY = "CMD:READY"
        var CMD_TAKE_PHOTO = "CMD:TAKE_PHOTO"
        var CMD_IMPORT_PHOTO = "CMD:IMPORT_PHOTO"
        var CMD_SHARE_OUT_PHOTO = "CMD:SHARE_OUT_PHOTO"
        var CMD_SHARE_OUT_TEXT = "CMD:SHARE_OUT_TEXT"

        var CMD_TAKE_QR_CODE = "CMD:TAKE_QR_CODE"
        
        var CMD_SHARE_IN_PHOTO = "CMD:SHARE_IN_PHOTO"
        var CMD_SHARE_IN_TEXT = "CMD:SHARE_IN_TEXT"

        var REQUEST_READ_STORAGE_CODE = 999
        var REQUEST_IMAGE_CAPTURE = 1001
        var REQUEST_IMAGE_CHOOSE = 1002

        var LOG_TAG = CommandChannel::class.java.simpleName
    }

    lateinit var currentAbsolutePath : String
    lateinit var currentMethodChannelResult : MethodChannel.Result

    lateinit var methodChannel : MethodChannel

    var channelIsReady: Boolean = false
    var bufferShareInPhoto : Uri? = null
    var bufferShareInText : String? = null

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

    private fun copyPhoto(fOut: File, fIn: File) {
        fOut.outputStream().use { streamOut ->
            fIn.inputStream().use { streamIn ->
                streamIn.copyTo(streamOut)
            }
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

    private fun dispatchSharePicture(activity: MainActivity, path: String) {
        val file = File(path)

        // TODO: flutter should add extension to image file, so it can show when sharing
        //   without copying image file
        val dir: File? = activity.getExternalFilesDir(Environment.DIRECTORY_PICTURES)
        val shareFile = File.createTempFile("export-", ".jpeg", dir)
        copyPhoto(shareFile, file)

        val authority = "${activity.applicationContext.packageName}.fileprovider"
        val photoURI = FileProvider.getUriForFile(activity, authority, shareFile)

        val intent = Intent().apply {
            action = Intent.ACTION_SEND
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            type = "image/jpeg"
            putExtra(Intent.EXTRA_STREAM, photoURI)
        }

        val chooser = Intent.createChooser(intent, "Share photo via")

        // grant permission to all app can accept sharing
        val permission = Intent.FLAG_GRANT_READ_URI_PERMISSION
        val resInfoList = activity.packageManager.queryIntentActivities(chooser, PackageManager.MATCH_DEFAULT_ONLY)
        for (resolveInfo in resInfoList) {
            val packageName = resolveInfo.activityInfo.packageName
            activity.grantUriPermission(packageName, photoURI, permission)
        }

        activity.startActivity(chooser)
    }

    private fun dispatchShareText(activity: MainActivity, text: String) {
        val intent = Intent(Intent.ACTION_SEND)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        intent.type = "text/plain"
        intent.putExtra(Intent.EXTRA_TEXT, text)
        activity.startActivity(Intent.createChooser(intent, "Share note via"))
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
        methodChannel = MethodChannel(flutterEngine.dartExecutor, "$packageName$CHANNEL_COMMANDS")
        methodChannel.setMethodCallHandler{
            call, result ->
            when(call.method) {
                CMD_READY -> {
                    Log.d(LOG_TAG, "CMD_READY")
                    result.success(null)
                    if (!channelIsReady) {
                        channelIsReady = true
                        if (bufferShareInPhoto != null) {
                            shareInPhoto(activity, bufferShareInPhoto!!)
                            bufferShareInPhoto = null
                        } else if (bufferShareInText != null) {
                            shareInText(bufferShareInText!!)
                            bufferShareInText = null
                        }
                    }
                }
                CMD_TAKE_PHOTO -> {
                    Log.d(LOG_TAG, "CMD_TAKE_PHOTO")
                    dispatchTakePictureIntent(activity, result)
                }
                CMD_IMPORT_PHOTO -> {
                    Log.d(LOG_TAG, "CMD_IMPORT_PHOTO")
                    dispatchImportPictureIntent(activity, result)
                }
                CMD_SHARE_OUT_PHOTO -> {
                    Log.d(LOG_TAG, "CMD_SHARE_OUT_PHOTO")
                    dispatchSharePicture(activity, call.arguments as String)
                }
                CMD_SHARE_OUT_TEXT -> {
                    Log.d(LOG_TAG, "CMD_SHARE_OUT_TEXT")
                    dispatchShareText(activity, call.arguments as String)
                }
                CMD_TAKE_QR_CODE -> {
                    Log.d(LOG_TAG, "CMD_TAKE_QR_CODE")
                    dispatchTakeQRCodeIntent(activity, result)
                }
            }
        }
    }

    fun shareInPhoto(activity: MainActivity, uri: Uri) {
        if (!channelIsReady) {
            bufferShareInPhoto = uri
            return
        }

        val streamIn = activity.contentResolver.openInputStream(uri)
        Log.d(LOG_TAG, "CMD_SHARE_IN_PHOTO got: $streamIn")

        if (streamIn != null) {
            createPhotoFile(activity).also { photoFile ->
                savePhoto(photoFile, streamIn)
                methodChannel.invokeMethod(CMD_SHARE_IN_PHOTO, currentAbsolutePath )
            }
        }
    }

    fun shareInText(text: String) {
        if (!channelIsReady) {
            bufferShareInText = text
            return
        }
        methodChannel.invokeMethod(CMD_SHARE_IN_TEXT, text )
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