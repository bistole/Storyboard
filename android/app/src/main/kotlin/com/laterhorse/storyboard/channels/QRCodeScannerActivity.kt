package com.laterhorse.storyboard.channels;

import android.app.Activity;
import android.content.Intent
import android.os.Bundle;
import android.util.Log
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.zxing.integration.android.IntentIntegrator

import com.journeyapps.barcodescanner.CaptureManager;
import com.journeyapps.barcodescanner.CompoundBarcodeView;
import com.laterhorse.storyboard.R;

class QRCodeScannerActivity : Activity() {
    companion object {
        var LOG_TAG = QRCodeScannerActivity::class.java.simpleName
    }

    lateinit var capture : CaptureManager
    lateinit var barcodeScannerView : CompoundBarcodeView;
    lateinit var closeButton : ImageButton;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.qrcode_scanner);

        closeButton = findViewById(R.id.scanner_close_btn);
        closeButton.setOnClickListener(View.OnClickListener {
            setResult(RESULT_CANCELED)
            finish()
        })

        barcodeScannerView = findViewById(R.id.scanner_barcode_view);
        capture = CaptureManager(this, barcodeScannerView);
        capture.initializeFromIntent(getIntent(), savedInstanceState);
        capture.decode();
    }

    override fun onResume() {
        super.onResume()
        capture.onResume()
    }

    override fun onPause() {
        super.onPause()
        capture.onPause()
    }

    override fun onDestroy() {
        super.onDestroy()
        capture.onDestroy()
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        capture.onSaveInstanceState(outState)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        capture.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        return  barcodeScannerView.onKeyDown(keyCode, event) ||  super.onKeyDown(keyCode, event)
    }
}
