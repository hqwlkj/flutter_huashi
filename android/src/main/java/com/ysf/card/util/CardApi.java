package com.ysf.card.util;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.huashi.otg.sdk.HSIDCardInfo;
import com.huashi.otg.sdk.HsSerialPortSDK;
import com.ysf.card.CardServer;
import com.ysf.card.entry.CardInfo;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import android_serialport_api.SerialPort;
import android_serialport_api.SerialPortUtil;

import static com.ysf.card.util.CardUtil.writeFile;

/**
 * Author:yin.juan
 * Time:2020/10/12 12:38
 * Description:[一句话描述]
 */
public class CardApi {

    //串口以及接受线程
    protected static SerialPort mSerialPort;
    protected static OutputStream mOutputStream;
    private static InputStream mInputStream;
    private static ArrayList<byte[]> byteReadList = new ArrayList<>();
    private static boolean isCard = true;

    /**
     * 单次读卡
     *
     * @param context
     */
    public static void openCard(Context context) {
        try {
            HsSerialPortSDK ComApi = new HsSerialPortSDK(context, "");
            //打开串口
            if (ComApi.init("/dev/ttyHS0", 115200, 0) == 0) {
                //身份证认证
                if (ComApi.Authenticate(1000) == 0) {
                    //读卡
                    HSIDCardInfo ic = new HSIDCardInfo();
                    if (ComApi.Read_Card(ic, 2300) == 0) {
                        //成功
                        Log.d("CardApi", "证件类型：身份证\n" + "姓名：" + ic.getPeopleName()
                                + "\n" + "性别：" + ic.getSex() + "\n" + "民族："
                                + ic.getPeople() + "\n");
                    }
                }
                //关闭串口 如果读卡失败、认证失败都直接关闭串口
                ComApi.close();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 自动读卡
     *
     * @param context
     */
    public static void openAutoCard(Context context, final ICallback callback) {
        try {
            final HsSerialPortSDK ComApi = new HsSerialPortSDK(context, "");
            //打开串口
            int openState = ComApi.init("/dev/ttyHS0", 115200, 0);
            Log.i("打开串口 ==== >openState:", openState + "");
            if (openState != 0) {
                Log.i("openState:", "哦豁读卡器初始化失败了，我要开始重启了哦，当前状态"+openState + "");
                // 如果读卡器初始化失败后，重新开启读卡器
                CardUtil.restartSetCard();
            }
            readCardInfo(ComApi, callback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 读取卡片信息
     * @param ComApi
     * @param callback
     */
    private static  void readCardInfo(final HsSerialPortSDK ComApi, final ICallback callback){
        //身份证认证if
        new Thread(new Runnable() {
            @Override
            public void run() {
                boolean isAuto = true;
                while (isAuto) {
                    if (ComApi.Authenticate(200) == 0) {
                        HSIDCardInfo ic = new HSIDCardInfo();
                        if (ComApi.Read_Card(ic, 2300) == 0) {
                            //成功
                            Log.d("CardApi", "证件类型：身份证\n" + "姓名：" + ic.getPeopleName()
                                    + "\n" + "性别：" + ic.getSex() + "\n" + "民族："
                                    + ic.getPeople() + "\n");
                            //关闭串口
                            ComApi.close();
                            isAuto = false;
                            // 处理完业务逻辑，
                            Map<String, Object> params = new HashMap<String, Object>();
                            params.put("data", FastJsonUtil.toJson(ic));
                            params.put("code", "SUCCESS");
                            callback.callback(params);
                        } else {
                            //读卡失败
                            ComApi.close();
                            isAuto = false;
                            Map<String, Object> params = new HashMap<String, Object>();
                            params.put("code", "ERROR");
                            params.put("message", "读卡失败");
                            callback.callback(params);
                        }
                    }
                }
            }
        }).start();
    }

    /**
     * 开启扫码
     * @param context
     * @param callback
     * @throws InterruptedException
     */
    public static void openScan(Context context, final ICallback callback) throws InterruptedException {
        CardUtil.setScan();
        isCard = true;
        openSerialPort(callback);
    }

    public static void closeScan() {
        //关闭扫码串口
        closeSerialPort();
        CardUtil.closeBox(); //关闭盒子
    }

    public static void closeOpenCard() {
        CardUtil.closeBox(); //关闭盒子
    }

    /**
     * 打开串口，开启接收线程
     */

    private static void openSerialPort(final ICallback callback) {
        if (mSerialPort == null) {
            try {
                mSerialPort = SerialPortUtil.getInstance().openSerialPort();
                mOutputStream = mSerialPort.getOutputStream();
                mInputStream = mSerialPort.getInputStream();

                /* Create a receiving thread */
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        while (isCard) {
                            int size;
                            try {
                                if (mInputStream == null) return;
                                try {

                                    byte[] buffer = new byte[1];
                                    size = mInputStream.read(buffer);

                                    if (size > 0) {
                                        Thread.sleep(50);
                                        byte[] buffer2 = new byte[1023];
                                        size = mInputStream.read(buffer2);
                                        byteReadList.add(buffer);
                                        byteReadList.add(buffer2);
                                        byte[] data = DigitalTrans.copyByte(byteReadList);
                                        byteReadList.clear();

                                        byte[] dataByteArray = new byte[Math.abs(size)];
                                        System.arraycopy(data, 0, dataByteArray, 0, Math.abs(size));
                                        String scanString;
                                        if (dataByteArray[0] == 0) {
                                            byte[] dat = new byte[Math.abs(size) - 1];
                                            System.arraycopy(dataByteArray, 1, dat, 0, Math.abs(size) - 1);
                                            scanString = new String(dat);
                                        } else {
                                            scanString = new String(dataByteArray);
                                        }
                                        Log.d("ReadThread", scanString);

                                        closeSerialPort();
                                        Map<String, Object> params = new HashMap<String, Object>();
                                        params.put("code", "SUCCESS");
                                        params.put("data", scanString);
                                        callback.callback(params);
                                    }
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                    Map<String, Object> params = new HashMap<String, Object>();
                                    params.put("code", "ERROR");
                                    params.put("data", "");
                                    params.put("message", e.getMessage());
                                    callback.callback(params);
                                }

                            } catch (IOException e) {
                                e.printStackTrace();
                                Map<String, Object> params = new HashMap<String, Object>();
                                params.put("code", "ERROR");
                                params.put("data", "");
                                params.put("message", e.getMessage());
                                callback.callback(params);
                            }
                        }
                    }
                }).start();
            } catch (Exception e) {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("code", "ERROR");
                params.put("data", "");
                params.put("message", e.getMessage());
                callback.callback(params);
            }

        }
    }

    /**
     * 关闭串口，停掉接收线程
     */
    private static void closeSerialPort() {

        SerialPortUtil.getInstance().closeSerialPort();
        isCard = false;
        mSerialPort = null;

        //    CardUtil.writeFile("/sys/devices/platform/soc/7af0000.uart/gpio","00");

        //  LoggerUtil.i_file("关闭串口 :closeSerialPort()");

    }

}
