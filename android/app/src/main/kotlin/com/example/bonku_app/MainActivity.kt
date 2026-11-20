package com.example.bonku_app

import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val namaSaluran = "bonku/share"
    private var saluran: MethodChannel? = null
    private var awal: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        bersihkanCache()
        awal = bacaGambar(intent)

        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, namaSaluran)
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "ambilAwal" -> {
                    result.success(awal)
                    awal = null // hanya diserahkan sekali
                }
                else -> result.notImplemented()
            }
        }
        saluran = ch
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val data = bacaGambar(intent)
        if (data != null) saluran?.invokeMethod("gambarDibagikan", data)
    }

    private fun bacaGambar(intent: Intent?): Map<String, String>? {
        if (intent == null || intent.action != Intent.ACTION_SEND) return null
        // Dibuka ulang dari daftar aplikasi terbaru: jangan proses kiriman lama lagi.
        if ((intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0) return null
        val mimeIntent = intent.type ?: return null
        if (!mimeIntent.startsWith("image/")) return null

        val uri: Uri? = if (Build.VERSION.SDK_INT >= 33) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
        }
        if (uri == null) return null

        return try {
            val tujuan = File(cacheDir, "share_${System.currentTimeMillis()}")
            val masuk = contentResolver.openInputStream(uri) ?: return null
            masuk.use { input -> tujuan.outputStream().use { output -> input.copyTo(output) } }
            val mime = contentResolver.getType(uri)
                ?.takeIf { it.startsWith("image/") && !it.contains("*") }
                ?: mimeIntent
            mapOf("path" to tujuan.absolutePath, "mime" to mime)
        } catch (e: Exception) {
            null
        }
    }

    /** Hapus salinan gambar kiriman yang sudah lebih dari sehari. */
    private fun bersihkanCache() {
        val batas = System.currentTimeMillis() - 24L * 60 * 60 * 1000
        cacheDir.listFiles { f -> f.name.startsWith("share_") && f.lastModified() < batas }
            ?.forEach { it.delete() }
    }
}