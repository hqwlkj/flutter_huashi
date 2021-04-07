package com.parsec.flutter_huashi

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.huashi.otg.sdk.HSIDCardInfo
import com.parsec.flutter_huashi.handlers.HuaShiHandler
import com.urovo.xbsdk.Function
import com.urovo.xbsdk.IDCardReadCallBack
import com.urovo.xbsdk.ScanCallBack
import com.ysf.card.util.FastJsonUtil
import com.ysf.card.util.PlayerUtil
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
            "openCardInfo" -> {
                openCard(result)
            }
            "openScanCode" -> {
                openScanCode(result)
            }
            "stopScanCode" -> {
                stopScanCode(result)
            }
            "stopReadCard" -> {
                stopReadCard(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }


    private fun openCard(@NonNull result: Result) {
        Function.doReadIDCard(HuaShiHandler.getContext(), object : IDCardReadCallBack {
            override fun success(ic: HSIDCardInfo?) {
                PlayerUtil.play(HuaShiHandler.getContext())
                uiThreadHandler.post {
                    val params: MutableMap<String, Any> = HashMap()
                    params["data"] = FastJsonUtil.toJson(ic)
                    params["code"] = "SUCCESS"
                    Log.e("HUASHI-CARD",  """
     证件类型：身份证
     姓名：${ic!!.peopleName}
     性别：${ic.sex}
     民族：${ic.people}
     """.trimIndent())
                    result.success(params)
                }
            }

            override fun fail(code: Int, message: String?) {
                Log.e("HUASHI-CARD", code.toString())
                Log.e("HUASHI-CARD", message.toString())
                // 失败了先不处理异常信息
//            uiThreadHandler.post {
//                result.error(code.toString(), message.toString(), null)
//            }
            }
        })
    }

    private fun openScanCode(@NonNull result: Result) {
        Function.doScanLoop(object : ScanCallBack {
            override fun success(data: String?) {
                PlayerUtil.play(HuaShiHandler.getContext())
                Function.stopScan() // 停止扫码
                uiThreadHandler.post {
                    val params: MutableMap<String, Any> = HashMap()
                    params["data"] = data.toString()
                    params["code"] = "SUCCESS"
                    result.success(params)
                }
            }

            override fun fail(code: Int, message: String?) {
                uiThreadHandler.post {
                    Log.e("HUASHI-CARD", code.toString())
                    Log.e("HUASHI-CARD", message.toString())
                    val params: MutableMap<String, Any> = HashMap()
                    params["code"] = "ERROR"
                    params["resultCode"] = code
                    params["message"] = message.toString()
                    result.success(params)
                }
            }
        })
    }


    private fun stopScanCode(@NonNull result: Result){
        Function.stopScan()
        result.success("SUCCESS")
    }

    private fun stopReadCard(@NonNull result: Result){
        Function.stopReadIDCard()
        result.success("SUCCESS")
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
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }
}
