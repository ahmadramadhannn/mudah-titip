package com.ahmadramadhan.mudahtitip.notification;

/**
 * Types of notifications that can be sent to users.
 */
public enum NotificationType {
    // ===== Agreement Lifecycle =====
    /**
     * Someone proposed an agreement for a consignment.
     */
    AGREEMENT_PROPOSED,

    /**
     * An agreement was accepted.
     */
    AGREEMENT_ACCEPTED,

    /**
     * An agreement was rejected.
     */
    AGREEMENT_REJECTED,

    /**
     * A counter-offer was received.
     */
    AGREEMENT_COUNTERED,

    /**
     * An agreement was extended.
     */
    AGREEMENT_EXTENDED,

    /**
     * Shop requested to discontinue agreement early.
     */
    AGREEMENT_DISCONTINUED,

    // ===== Stock & Inventory =====
    /**
     * Stock is running low (below threshold).
     */
    STOCK_LOW,

    /**
     * Stock is completely out.
     */
    STOCK_OUT,

    /**
     * Weekly summary of stock levels.
     */
    STOCK_WEEKLY_SUMMARY,

    // ===== Sales =====
    /**
     * A sale was recorded for your product.
     */
    SALE_RECORDED,

    // ===== Consignment Lifecycle =====
    /**
     * A consignment is expiring soon.
     */
    CONSIGNMENT_EXPIRING,

    /**
     * A consignment has expired.
     */
    CONSIGNMENT_EXPIRED,

    /**
     * All products sold, consignment completed.
     */
    CONSIGNMENT_COMPLETED,

    // ===== Financial =====
    /**
     * Payout/settlement is ready for collection.
     */
    PAYOUT_READY,

    // ===== Complaints =====
    /**
     * A complaint was received about your product.
     */
    COMPLAINT_RECEIVED,

    /**
     * A complaint you filed has been resolved.
     */
    COMPLAINT_RESOLVED
}
