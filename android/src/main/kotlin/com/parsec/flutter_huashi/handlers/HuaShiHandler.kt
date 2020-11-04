package com.parsec.flutter_huashi.handlers

import android.content.Context
import android.util.Log
import com.tencent.wxpayface.WxfacePayLoadingDialog
import io.flutter.plugin.common.MethodChannel

object HuaShiHandler {

    private var context: Context? = null
    private  lateinit var wxfacePayLoadingDialog: WxfacePayLoadingDialog
    private var channel: MethodChannel? = null
    fun setContext(context: Context?) {
        HuaShiHandler.context = context
    }

    fun getContext(): Context? {
        return this.context
    }

    fun setMethodChannel(channel: MethodChannel) {
        HuaShiHandler.channel = channel
    }

    fun initDialog(context: Context){
        wxfacePayLoadingDialog = WxfacePayLoadingDialog(context)
    }

    fun showDialog(){
        wxfacePayLoadingDialog.show()
    }
    fun hideDialog(){
        wxfacePayLoadingDialog.hide()
    }
}