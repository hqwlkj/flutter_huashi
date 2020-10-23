package android_serialport_api;

import android.util.Log;

import java.io.File;
import java.io.IOException;

/**
 * Author:yin.juan
 * Time:2019/5/16 12:06
 * Description:[一句话描述]
 */
public class SerialPortUtil {

    private static String path_card_v5 = "/dev/ttyS3"; //5/8代机

    private static String path_card_v3 = "/dev/ttyMT1"; //三代机
    private static String path_card_v2 = "/dev/ttyMT3"; //二代机
    public static int baudrate = 9600; //波特率
    public static String port = "/dev/ttyHS0";

    private static SerialPort mSerialPort = null;

    //单列模式
    private static class SingletonLoader {
        private static final SerialPortUtil INSTANCE = new SerialPortUtil();
    }

    public static SerialPortUtil getInstance() {
        return SingletonLoader.INSTANCE;
    }

    public SerialPort openSerialPort() throws IOException {

        Log.d("HF", "mSerialPort:" + mSerialPort);
        if (mSerialPort == null) {
            mSerialPort = new SerialPort(new File(port), baudrate, 0);
        }

        return mSerialPort;

    }

    public void closeSerialPort() {
        Log.d("HF", "closeSerialPort:" + mSerialPort);

        if (mSerialPort != null) {
            mSerialPort.close();
        }
        mSerialPort = null;
    }
}
