package com.ysf.card.entry;





import com.huashi.otg.sdk.HSIDCardInfo;

import java.io.Serializable;

public class CardInfo implements Serializable {
    private static final long serialVersionUID = 8026198876199889291L;

    private String info;
    private String type;
    private HSIDCardInfo hsidCardInfo;

    public HSIDCardInfo getHsidCardInfo() {
        return hsidCardInfo;
    }

    public void setHsidCardInfo(HSIDCardInfo hsidCardInfo) {
        this.hsidCardInfo = hsidCardInfo;
    }

    public String getInfo() {
        return info;
    }

    public void setInfo(String info) {
        this.info = info;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
