package com.laterhorse.storyboard.channels

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.ImageFormat
import android.graphics.SurfaceTexture
import android.hardware.camera2.*
import android.media.Image
import android.media.ImageReader
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import android.util.Size
import android.util.SparseIntArray
import android.view.Surface
import android.view.TextureView
import android.view.TextureView.SurfaceTextureListener
import android.widget.Button
import com.laterhorse.storyboard.R
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import kotlin.collections.ArrayList

class CameraActivity : Activity() {

    companion object {
        var REQUEST_CAMERA_PERMISSION = 200
        var EXTRA_OUTPUT_FILENAME = "output_filename"
        var EXTRA_DATA = "data"
        var LOG_TAG: String = CameraActivity::class.java.simpleName
        var ORIENTATION = SparseIntArray().apply {
            append(Surface.ROTATION_0, 90)
            append(Surface.ROTATION_90, 0)
            append(Surface.ROTATION_180, 270)
            append(Surface.ROTATION_270, 180)
        }
    }

    // input
    private var photoURI : Uri? = null

    // ui
    private lateinit var captureButton : Button
    private lateinit var textureView : TextureView

    // camera
    private var cameraId : String? = null
    private var cameraDevice : CameraDevice? = null
    private var captureSession : CameraCaptureSession? = null
    private var captureRequestBuilder : CaptureRequest.Builder? = null
    private var imageDimension : Size? = null

    // thread
    private var handler: Handler? = null
    private var handlerThread: HandlerThread? = null

    // texture listener, if surface is ready, call openCamera
    private var textureListener : SurfaceTextureListener = object : SurfaceTextureListener {
        override fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int) {
            Log.i(LOG_TAG, "SurfaceTextureListener: onSurfaceTextureAvailable: ($width, $height)")
            openCamera()
        }
        override fun onSurfaceTextureSizeChanged(surface: SurfaceTexture, width: Int, height: Int) {
            Log.i(LOG_TAG, "SurfaceTextureListener: onSurfaceTextureSizeChanged: ($width, $height)")
        }
        override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean {
            Log.i(LOG_TAG, "SurfaceTextureListener: onSurfaceTextureDestroyed")
            return false
        }
        override fun onSurfaceTextureUpdated(surface: SurfaceTexture) {}
    }

    // camera device's state callback.
    // - if camera is opened, call create camera preview
    // - if camera is disconnected or get an error, call close camera
    private var stateCallback : CameraDevice.StateCallback = object: CameraDevice.StateCallback() {
        override fun onOpened(camera: CameraDevice) {
            Log.i(LOG_TAG, "CameraDevice.StateCallback: onOpened")
            cameraDevice = camera
            createCameraPreview()
        }

        override fun onDisconnected(camera: CameraDevice) {
            Log.i(LOG_TAG, "CameraDevice.StateCallback: onDisconnected")
            closeCamera()
        }

        override fun onError(camera: CameraDevice, error: Int) {
            Log.e(LOG_TAG, "CameraDevice.StateCallback: onError $error")
            closeCamera()
        }
    }

    // override onCreate
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // input
        val temp = intent.getStringExtra(EXTRA_OUTPUT_FILENAME)
        if (temp != null) {
            photoURI = Uri.parse(temp)
        }

        setContentView(R.layout.camera_surface)

        // preview texture
        textureView = findViewById(R.id.camera_surface)
        textureView.surfaceTextureListener = textureListener

        // capture button
        captureButton = findViewById(R.id.camera_capture)
        captureButton.setOnClickListener {
            takePicture()
        }
    }

    // override onResume
    override fun onResume() {
        startBackgroundThread()
        if (textureView.isAvailable) {
           openCamera()
        } else {
            textureView.surfaceTextureListener = textureListener
        }
        super.onResume()
    }

    // override onPause
    override fun onPause() {
        stopBackgroundThread()
        super.onPause()
    }

    // override get permission request result
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        // if permission is not granted, will close activity
        if (requestCode == REQUEST_CAMERA_PERMISSION) {
            if (grantResults[0] == PackageManager.PERMISSION_DENIED) {
                Log.w(LOG_TAG, "onRequestPermissionsResult: denied")
                finish()
            }
            Log.i(LOG_TAG, "onRequestPermissionsResult: granted")
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    // create thread to handle camera session
    private fun startBackgroundThread() {
        handlerThread = HandlerThread("Camera Background").also {
            it.start()
            handler = Handler(it.looper)
        }
    }

    // stop thread which handles camera session
    private fun stopBackgroundThread() {
        handlerThread?.quitSafely()
        try {
            handlerThread?.join()
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
        handlerThread = null
        handler = null
    }

    // check permission
    private fun checkPermission() : Boolean {
        if ((checkSelfPermission(Manifest.permission.CAMERA)
                        != PackageManager.PERMISSION_GRANTED)
                && (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                        != PackageManager.PERMISSION_GRANTED))
        {
            requestPermissions(arrayOf(
                    Manifest.permission.CAMERA,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
            ), REQUEST_CAMERA_PERMISSION)
            return false
        }
        return true
    }

    // open camera
    private fun openCamera() {
        if (!checkPermission()) return
        Log.i(LOG_TAG, "openCamera")

        val cm : CameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        try {
            // get camera id
            cameraId = cm.cameraIdList[0]
            if (cameraId == null) return

            // get dimension of camera
            val characteristics = cm.getCameraCharacteristics(cameraId!!)
            characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP).let { map ->
                imageDimension = map!!.getOutputSizes(SurfaceTexture::class.java)[0]
            }

            // open camera
            cm.openCamera(cameraId!!, stateCallback, handler)
        } catch (e : CameraAccessException) {
            Log.e(LOG_TAG, "openCamera got exception")
            e.printStackTrace()
        }
    }

    // close camera
    private fun closeCamera() {
        cameraDevice?.close()
        cameraDevice = null
    }

    // create camera preview, called when camera device is opened
    private fun createCameraPreview() {
        if (imageDimension == null) return
        if (cameraDevice == null) return

        try {
            // set texture size
            val texture = textureView.surfaceTexture
            texture!!.setDefaultBufferSize(imageDimension!!.width, imageDimension!!.height)

            // get surface of texture view
            val surface = Surface(texture)

            // create capture request builder
            captureRequestBuilder = cameraDevice!!.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW)
            captureRequestBuilder!!.addTarget(surface)

            // create capture session
            cameraDevice!!.createCaptureSession(listOf(surface), createCapturePreviewStateCallback(), handler)

        } catch (e: CameraAccessException) {
            e.printStackTrace()
        }
    }

    // create state callback for preview photo
    private fun createCapturePreviewStateCallback() : CameraCaptureSession.StateCallback {
        return object: CameraCaptureSession.StateCallback() {
            override fun onConfigured(ccs: CameraCaptureSession) {
                Log.i(LOG_TAG, "createCapturePreviewStateCallback: onConfigured")
                if (cameraDevice == null) return
                // When the session is ready, we start displaying the preview.
                captureSession = ccs
                updateCameraPreview()
            }
            override fun onConfigureFailed(ccs: CameraCaptureSession) {
                Log.e(LOG_TAG, "createCapturePreviewStateCallback: onConfigureFailed")
            }
        }
    }

    // update camera preview, make session repeatedly capture photo
    // since the request and session are attached to surface of texture view
    // preview result will show on the texture view
    private fun updateCameraPreview() {
        Log.i(LOG_TAG, "updateCameraPreview")
        if (imageDimension == null) return
        if (captureSession == null) return
        if (captureRequestBuilder == null) return

        captureRequestBuilder!!.set(CaptureRequest.CONTROL_MODE, CameraMetadata.CONTROL_MODE_AUTO)
        try {
            captureSession!!.setRepeatingRequest(captureRequestBuilder!!.build(), null, handler)
        } catch (e : CameraAccessException) {
            e.printStackTrace()
        }
    }

    // save to file and exit activity
    private fun finishWithFile(bytes: ByteArray) {
        Log.i(LOG_TAG, "finishWithFile $photoURI")
        if (photoURI == null) return

        var output : FileOutputStream? = null
        try {
            val photoPath = photoURI!!.path!!

            output = FileOutputStream(File(photoPath))
            output.write(bytes)
        } finally {
            output?.close()
        }
        setResult(RESULT_OK)
        finish()
    }

    // exit with data
    private fun finishWithData(bytes: ByteArray) {
        Log.i(LOG_TAG, "finishWithData")
        intent.putExtra(EXTRA_DATA, bytes)
        setResult(RESULT_OK)
        finish()
    }

    // create a image reader when taking photo
    private fun getImageReader() : ImageReader? {
        Log.i(LOG_TAG, "getImageReader")
        if (cameraId == null) return null

        val cm = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        val characteristics = cm.getCameraCharacteristics(cameraId!!)
        val map = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
        val size = if (map == null) Size(640, 480)
            else map.getOutputSizes(ImageFormat.JPEG)[0]

        val imgReader = ImageReader.newInstance(size.width, size.height, ImageFormat.JPEG, 1)

        val readerListener = ImageReader.OnImageAvailableListener { reader ->
            var image : Image? = null
            try {
                Log.i(LOG_TAG, "OnImageAvailableListener");
                image = reader.acquireLatestImage()
                if (image != null) {
                    Log.i(LOG_TAG, "OnImageAvailableListener: acquireLatestImage");
                    val buffer = image.planes[0].buffer
                    val bytes = ByteArray(buffer.capacity())
                    buffer.get(bytes)

                    if (photoURI != null) {
                        finishWithFile(bytes)
                    } else {
                        finishWithData(bytes)
                    }
                }
            } catch (e: FileNotFoundException) {
                e.printStackTrace()
            } catch (e: IOException) {
                e.printStackTrace()
            } finally {
                image?.close()
            }
        }

        imgReader.setOnImageAvailableListener(readerListener, handler)
        return imgReader
    }

    // take picture
    private fun takePicture() {
        Log.i(LOG_TAG, "takePicture")
        if (cameraId == null) return
        if (cameraDevice == null) return

        try {
            // get image reader for saving or returning the photo
            val imageReader = getImageReader()

            // surfaces to output
            val surfaces = ArrayList<Surface>(2)
            surfaces.add(imageReader!!.surface)
            surfaces.add(Surface(textureView.surfaceTexture))

            cameraDevice?.createCaptureSession(surfaces,
                    createCaptureFinalStateCallback(imageReader.surface),
                    handler)
        } catch (e : CameraAccessException) {
            e.printStackTrace()
        }
    }

    // create camera capture builder for final photo
    private fun createCaptureBuilderForFinal(surface: Surface) : CaptureRequest.Builder {
        Log.i(LOG_TAG, "createCaptureBuilderForFinal")
        val captureBuilder = cameraDevice!!.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE)
        captureBuilder.addTarget(surface)
        captureBuilder.set(CaptureRequest.CONTROL_MODE, CameraMetadata.CONTROL_MODE_AUTO)

        val rotation = windowManager.defaultDisplay.rotation
        captureBuilder.set(CaptureRequest.JPEG_ORIENTATION, ORIENTATION.get(rotation))

        return captureBuilder
    }

    // create state callback for final photo
    private fun createCaptureFinalStateCallback(surface: Surface) : CameraCaptureSession.StateCallback {
        Log.i(LOG_TAG, "createCaptureFinalStateCallback")
        return object: CameraCaptureSession.StateCallback() {
            override fun onConfigured(session: CameraCaptureSession) {
                Log.i(LOG_TAG, "createCameraPreview: onConfigured")
                try {
                    val captureBuilder = createCaptureBuilderForFinal(surface)
                    session.capture(captureBuilder.build(), null, handler)
                } catch (e : CameraAccessException) {
                    e.printStackTrace()
                }
            }
            override fun onConfigureFailed(session: CameraCaptureSession) {
                Log.e(LOG_TAG, "createCameraPreview: onConfigureFailed")
            }
        }
    }

}