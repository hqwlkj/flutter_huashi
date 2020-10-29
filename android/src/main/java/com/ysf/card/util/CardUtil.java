package com.ysf.card.util;

import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;

/**
 * Author:yin.juan
 * Time:2020/10/12 12:33
 * Description:[切换盒子和读卡工具类]
 */
public class CardUtil {
    private static final String gpio = "/sys/devices/platform/soc/7af0000.uart/gpio";

    /**
     * 设置读卡
     */
    public static boolean setCard() throws InterruptedException {

        // 20201029切换到读卡器的时候先关闭扫码的数据流及串口
        CardApi.closeScan();

        //关闭扫码盒子电源
        closeBox();

        //开启身份证模块电源
        writeFile(gpio, "31");
        Thread.sleep(1000); //1000 毫秒
        //切换到身份证模块
        return writeFile(gpio, "11");
    }

    /**
     * 当初始化读卡器后，重新开始启动读卡器
     * @return
     * @throws InterruptedException
     */
    public static  boolean restartSetCard() throws InterruptedException {
        //关闭身份证模块电源
        writeFile(gpio, "30");
        //开启身份证模块电源
        writeFile(gpio, "31");
        Thread.sleep(1000); //1000 毫秒
        //切换到身份证模块
        return writeFile(gpio, "11");
    }

    /**
     * 设置扫码
     */
    public static void setScan() throws InterruptedException {

        //关闭身份证模块电源
        writeFile(gpio, "30");

        //开启扫码盒子电源
        writeFile(gpio, "01");
        Thread.sleep(1000); //1000 毫秒
        //切换到扫码盒子
        writeFile(gpio, "10");
    }

    /**
     * 关闭扫码盒子电源
     * @return
     */
    public static boolean closeBox(){
        //关闭扫码盒子电源
        return writeFile(gpio, "00");
    }

    /*
     *   读取节点值
     */
    public String readFileData(String fileName) {
        String result = "";
        try {
            File updatefile = new File(fileName);
            FileInputStream fis = new FileInputStream(fileName);
            // 获取文件长度
            int lenght = fis.available();
            byte[] buffer = new byte[lenght];
            fis.read(buffer);

            // 将byte数组转换成指定格式的字符串
            result = new String(buffer, "UTF-8");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public static boolean writeFile(String filePath, String content) {
        boolean res = true;
        File file = new File(filePath);
        File dir = new File(file.getParent());
        if (!dir.exists())
            dir.mkdirs();
        try {
            FileWriter mFileWriter = new FileWriter(file, false);
            mFileWriter.write(content);
            mFileWriter.close();
        } catch (IOException e) {
            res = false;
        }
        Log.d("zml", "writeFile   " + filePath + "   value   " + content);
        return res;
    }
}
