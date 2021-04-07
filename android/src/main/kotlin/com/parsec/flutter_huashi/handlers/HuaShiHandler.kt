package com.parsec.flutter_huashi.handlers

import android.content.Context
import io.flutter.plugin.common.MethodChannel

object HuaShiHandler {

    private var context: Context? = null
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
}