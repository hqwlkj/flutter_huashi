package com.ysf.card.util;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.media.MediaPlayer;

import java.io.IOException;

public class PlayerUtil {
    private  static AssetManager assetManager;
    private  static MediaPlayer player = null;

    public static void play(Context context){
        player = new MediaPlayer();
        assetManager = context.getResources().getAssets();
        try {
            AssetFileDescriptor fileDescriptor = assetManager.openFd("prompt.mp3");
            player.setDataSource(fileDescriptor.getFileDescriptor(), fileDescriptor.getStartOffset(), fileDescriptor.getStartOffset());
            player.prepare();
            player.start();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void readPlay(Context context){
        player = new MediaPlayer();
        assetManager = context.getResources().getAssets();
        try {
            AssetFileDescriptor fileDescriptor = assetManager.openFd("read-card.mp3");
            player.setDataSource(fileDescriptor.getFileDescriptor(), fileDescriptor.getStartOffset(), fileDescriptor.getStartOffset());
            player.prepare();
            player.start();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void scanPayCodePlay(Context context){
        player = new MediaPlayer();
        assetManager = context.getResources().getAssets();
        try {
            AssetFileDescriptor fileDescriptor = assetManager.openFd("scan-pay-code.mp3");
            player.setDataSource(fileDescriptor.getFileDescriptor(), fileDescriptor.getStartOffset(), fileDescriptor.getStartOffset());
            player.prepare();
            player.start();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void scanCodePlay(Context context){
        player = new MediaPlayer();
        assetManager = context.getResources().getAssets();
        try {
            AssetFileDescriptor fileDescriptor = assetManager.openFd("scan-code.mp3");
            player.setDataSource(fileDescriptor.getFileDescriptor(), fileDescriptor.getStartOffset(), fileDescriptor.getStartOffset());
            player.prepare();
            player.start();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
