package com.ysf.card.util;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.media.MediaPlayer;

import java.io.IOException;

public class PlayerUtil {

    public static void play(Context context){
        AssetManager assetManager;
        MediaPlayer player = null;
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
}
