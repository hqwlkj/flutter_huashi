package com.parsec.flutter_huashi_example

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootBroadcastReceiver : BroadcastReceiver() {
    private val actionBoot = "android.intent.action.BOOT_COMPLETED"

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent!!.action.equals(actionBoot)) {
//            val intent = Intent(context, MainActivity::class.java) // 要启动的Activity
            //1.如果自启动APP，参数为需要自动启动的应用包名
            val bootIntent = context!!.packageManager.getLaunchIntentForPackage("com.parsec.flutter_huashi_example");
            //下面这句话必须加上才能开机自动运行app的界面
            bootIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            //2.如果自启动Activity
            context.startActivity(bootIntent);
            //3.如果自启动服务
//            context!!.startService(intent)
        }
    }
}