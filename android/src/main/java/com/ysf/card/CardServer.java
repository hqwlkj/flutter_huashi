package com.ysf.card;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.text.TextUtils;
import android.util.Log;

import com.huashi.otg.sdk.HSIDCardInfo;
import com.huashi.otg.sdk.HsSerialPortSDK;
import com.ysf.card.entry.CardInfo;
import com.ysf.card.util.CardUtil;
import com.ysf.card.util.DigitalTrans;
import com.ysf.card.util.FastJsonUtil;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;

import android_serialport_api.SerialPort;
import android_serialport_api.SerialPortUtil;
import androidx.annotation.Nullable;

/**
 * Author:yin.juan
 * Time:2020/10/12 12:44
 * Description:[一句话描述]
 */
public class CardServer extends Service {
    //串口以及接受线程
    protected SerialPort mSerialPort;
    protected OutputStream mOutputStream;
    private InputStream mInputStream;
    private ReadThread mReadThread;


    //发送线程
    private  final Object sDecodeLock = new Object();// 用来保证当前对象只有一个线程在访问
    private   byte[] mBuffer; //要发送的数组数据
    private SendingThread mSendingThread; //发送数据的线程

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent!=null &&intent.getAction()!=null){
            if (intent.getAction().equals("com.ub.ysf.scan")){
                isCard=true;
                openSerialPort();
            }else if (intent.getAction().equals("com.ub.ysf.card")){
                isCard=false;
                closeSerialPort();
                try {
                    HsSerialPortSDK ComApi = new HsSerialPortSDK(this, "");
                    //打开串口
                    if (ComApi.init("/dev/ttyHS0", 115200, 0)==0){
                        //身份证认证
                        if (ComApi.Authenticate(1000)==0){
                            //读卡
                            HSIDCardInfo ici = new HSIDCardInfo();
                            if(ComApi.Read_Card(ici, 2300)==0){
                                //成功
                               // Log.d("CardApi", ici.getAddr());
                                CardInfo cardInfo=new CardInfo();
                                ici.setFpDate(null);
                                cardInfo.setHsidCardInfo(ici);
                                cardInfo.setType("idCard");
                                sendCardData(FastJsonUtil.toJson(cardInfo));
                                //关闭串口
                                ComApi.close();
                            }else {
                                //读卡失败
                                ComApi.close();
                            }
                        }else {
                            //认证失败
                            ComApi.close();
                        }
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return super.onStartCommand(intent, flags, startId);
    }




    @Override
    public void onDestroy() {
        super.onDestroy();
    }


    /**
     * 打开串口，开启接收线程
     */

    private void openSerialPort() {
        if (mSerialPort ==null){
            try {
                mSerialPort = SerialPortUtil.getInstance().openSerialPort();
                mOutputStream = mSerialPort.getOutputStream();
                mInputStream = mSerialPort.getInputStream();

                /* Create a receiving thread */
                mReadThread = new ReadThread();
                mReadThread.start();

            } catch (Exception e) {

            }
            // LoggerUtil.i_file("打开串口 :"+mSerialPort);

        }

    }
    /**
     * 关闭串口，停掉接受线程
     */
    private void closeSerialPort() {

        SerialPortUtil.getInstance().closeSerialPort();
        if (mReadThread != null) mReadThread.interrupt();
        mSerialPort = null;
        mReadThread=null;
    //    CardUtil.writeFile("/sys/devices/platform/soc/7af0000.uart/gpio","00");

        //  LoggerUtil.i_file("关闭串口 :closeSerialPort()");

    }
    /**
     * 开启数据发送的线程
     */
    private  void startDataListener() {
        if (mSerialPort != null) {

            if (mSendingThread !=null){
                if (!mSendingThread.isInterrupted()){
                    mSendingThread.interrupt();
                }
                mSendingThread=null;
            }
            synchronized (SendingThread.class){
                if (mSendingThread==null){
                    mSendingThread = new SendingThread();
                    mSendingThread.start();
                }
            }

        }
    }
    /**
     * 发送数据的线程
     */

    private class SendingThread extends Thread {
        @Override
        public void run() {
//            while (!isInterrupted()) {

            synchronized (sDecodeLock) {

                try {
                    if (mOutputStream != null) {
                        mOutputStream.write(mBuffer);
                        //   LoggerUtil.i_file("指令command: "+DigitalTrans.bytesToHexString(mBuffer));
                        try {
                            sDecodeLock.wait(50);

                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        } catch (NullPointerException e2) {
                            e2.printStackTrace();
                        }

                    } else {
                        return;
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                    return;
                }
            }
        }
    }

    private static ArrayList<byte[]> byteReadList =new ArrayList<>();
    private boolean isCard =true;
    private class ReadThread extends Thread {

        @Override
        public void run() {
            super.run();
            while (isCard) {
                int size;
                try {
                    if (mInputStream == null) return;
                    try {

                        byte[] buffer = new byte[1];
                        size = mInputStream.read(buffer);

                        if (size > 0) {
                            Thread.sleep(50);
                            byte[] buffer2 =new byte[1023];
                            size = mInputStream.read(buffer2);
                            byteReadList.add(buffer);
                            byteReadList.add(buffer2);
                            byte[] data = DigitalTrans.copyByte(byteReadList) ;
                            byteReadList.clear();
                            CardInfo cardInfo =new CardInfo();

                           // Log.d("ReadThread", "size:" + size);
                            byte[] dataByteArray =new byte[Math.abs(size)];
                            System.arraycopy(data, 0, dataByteArray, 0,Math.abs(size));
                           // Log.d("ReadThread", DigitalTrans.bytesToHexString(dataByteArray));
                           // Log.d("ReadThread", new String(dataByteArray));
                          //  Log.d("ReadThread", "dataByteArray[0]:" + dataByteArray[0]);
                            if (dataByteArray[0]==0){
                                byte[] dat =new byte[Math.abs(size)-1];
                                System.arraycopy(dataByteArray, 1, dat, 0,Math.abs(size)-1);
                                cardInfo.setInfo(new String(dat));
                                cardInfo.setType("scan");
                                sendCardData(FastJsonUtil.toJson(cardInfo));
                            }else {
                                cardInfo.setInfo(new String(dataByteArray));
                                cardInfo.setType("scan");
                                sendCardData(FastJsonUtil.toJson(cardInfo));
                            }


                           // closeSerialPort();

                        }

                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                } catch (IOException e) {
                    e.printStackTrace();
                    return;
                }
            }
        }

    }

    /**
     * 发送读卡数据广播
     *
     * @param cardInfo
     */
    public void sendCardData(String cardInfo) {

       // Log.d("CardServer", cardInfo);
        Intent cardDataIntent = new Intent();
        cardDataIntent.putExtra("data", cardInfo);
        cardDataIntent.setAction("com.ub.ysf.data");
        sendBroadcast(cardDataIntent);

    }
}
