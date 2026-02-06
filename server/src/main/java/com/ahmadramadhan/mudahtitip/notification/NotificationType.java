package com.ahmadramadhan.mudahtitip.notification;

/**
 * Types of notifications that can be sent to users.
 */
public enum NotificationType {
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
     * A sale was recorded for your product.
     */
    SALE_RECORDED,

    /**
     * A consignment is expiring soon.
     */
    CONSIGNMENT_EXPIRING,

    /**
     * A consignment has expired.
     */
    CONSIGNMENT_EXPIRED
}
