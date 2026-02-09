package com.ahmadramadhan.mudahtitip.complaint;

/**
 * Categories of product complaints that shop owners can file.
 */
public enum ComplaintCategory {
    EXPIRED("Kedaluwarsa"),
    DAMAGED("Rusak"),
    QUALITY_ISSUE("Masalah Kualitas"),
    PACKAGING("Kemasan Rusak"),
    OTHER("Lainnya");

    private final String displayName;

    ComplaintCategory(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
