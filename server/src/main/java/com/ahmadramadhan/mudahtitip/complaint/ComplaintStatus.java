package com.ahmadramadhan.mudahtitip.complaint;

/**
 * Status of a complaint throughout its lifecycle.
 */
public enum ComplaintStatus {
    OPEN("Menunggu"),
    IN_REVIEW("Ditinjau"),
    RESOLVED("Selesai"),
    REJECTED("Ditolak");

    private final String displayName;

    ComplaintStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
