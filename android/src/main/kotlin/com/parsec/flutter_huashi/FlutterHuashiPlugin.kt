package com.parsec.flutter_huashi

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.Intent.getIntent
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.parsec.flutter_huashi.handlers.HuaShiHandler
import com.ysf.card.util.CardApi
import com.ysf.card.util.CardUtil
import com.ysf.card.util.ICallback
import com.ysf.wxface.utils.WxFaceUtil
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


/** FlutterHuashiPlugin */
public class FlutterHuashiPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private val uiThreadHandler = Handler(Looper.getMainLooper())

    private val locatiopnBroadcast: LocatiopnBroadcast? = null
    val BROADCAST_ACTION_DISC = "com.ub.ysf.data"

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var responseHandler: HuaShiHandler? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_huashi")
        channel.setMethodCallHandler(this)
        HuaShiHandler.setMethodChannel(channel)
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        const val tag = "FlutterHuashiPlugin"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            HuaShiHandler.setContext(registrar.activity())
            HuaShiHandler.initDialog(registrar.activity())
            val channel = MethodChannel(registrar.messenger(), "flutter_huashi")
            HuaShiHandler.setMethodChannel(channel)
            channel.setMethodCallHandler(FlutterHuashiPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "initCard" -> {
                result.success(initCard())
            }
            "openCard" -> {
                result.success(openCard())
            }
            "openAutoCard" -> {
                openAutoCard(result)
            }
            "scanCode" -> {
                openScan(result)
            }
            "closeScanCode" -> {
                result.success(closeScanCode())
            }
            "closeOpenCard" -> {
                result.success(closeOpenCard())
            }
            "initWxpayface" -> { // 初始化刷脸支付
                initWxpayface(result)
            }
            "faceVerified" -> {
                faceRecognition(result)
            }
            "wxFacePay" -> {
                wxFacePay(result)
            }
            "releaseWxpayface" -> {
                releaseWxpayface()
            }
            "showPayLoading" -> {
                showDialog()
            }
            "hidePayLoading" -> {
                hideDialog()
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun showDialog() {
        Log.i(tag, "showDialog" + HuaShiHandler.getContext())
        HuaShiHandler.showDialog()
    }

    private fun hideDialog() {
        Log.i(tag, "hideDialog" + HuaShiHandler.getContext())
        HuaShiHandler.hideDialog()
    }

    private fun initWxpayface(@NonNull result: Result) {
        WxFaceUtil.init(HuaShiHandler.getContext(), object : ICallback {
            override fun callback(params: MutableMap<String, Any>?) {
                uiThreadHandler.post {
                    result.success(params)
                }
            }
        })
    }


    private fun faceRecognition(@NonNull result: Result) {
        WxFaceUtil.InfoVer(HuaShiHandler.getContext(), object : ICallback {
            override fun callback(params: MutableMap<String, Any>?) {
                uiThreadHandler.post {
                    result.success(params)
                }
            }
        })
    }

    private fun wxFacePay(@NonNull result: Result){
        WxFaceUtil.FacePay(HuaShiHandler.getContext(), "", object: ICallback{
            override fun callback(params: MutableMap<String, Any>?) {
                uiThreadHandler.post {
                    result.success(params)
                }
            }
        })
    }

    /**
     * 释放微信刷脸
     */
    private fun releaseWxpayface(){
        WxFaceUtil.releaseWxpayface(HuaShiHandler.getContext())
    }


    private fun initCard(): String {
        Log.i(tag, "initCard")
        if (CardUtil.setCard())
            return "SUCCESS"
        return "ERROR"
    }

    private fun openCard(): String {
        Log.i(tag, "openCard")
        CardApi.openCard(HuaShiHandler.getContext())
        return "SUCCESS"
    }

    private fun openAutoCard(@NonNull result: Result) {
        Log.i(tag, "openAutoCard")
        CardApi.openAutoCard(HuaShiHandler.getContext(), object : ICallback {
            override fun callback(params: MutableMap<String, Any>?) {
                uiThreadHandler.post {
                    result.success(params)
                }
            }
        })
    }

    private fun openScan(@NonNull result: Result) {
        Log.i(tag, "openScan")
        CardApi.openScan(HuaShiHandler.getContext(), object : ICallback {
            override fun callback(params: MutableMap<String, Any>?) {
                uiThreadHandler.post {
                    result.success(params)
                }
            }
        })
    }

    private fun closeScanCode(): String {
        Log.i(tag, "closeScanCode")
        CardApi.closeScan()
        return "SUCCESS"
    }

    private fun closeOpenCard(): String {
        Log.i(tag, "closeOpenCard")
        CardApi.closeOpenCard()
        return "SUCCESS"
    }

    fun sendMessage() {

    }

    //广播接收者
    class LocatiopnBroadcast : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            //收到广播后的操作
            if (intent.action != null) {
                if (intent.action == "com.ub.ysf.data") {
                    Log.e("receiver", intent.getStringExtra("data"))
                }
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        HuaShiHandler.setContext(binding.activity);
        HuaShiHandler.initDialog(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }
}
