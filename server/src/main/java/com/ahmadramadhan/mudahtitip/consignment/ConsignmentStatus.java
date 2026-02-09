package com.ahmadramadhan.mudahtitip.consignment;

/**
 * Status of a consignment.
 */
public enum ConsignmentStatus {
    /**
     * Consignment is pending agreement acceptance (shop owner initiated).
     */
    PENDING,

    /**
     * Consignment is active and products are available for sale.
     */
    ACTIVE,

    /**
     * Consignment has expired (past the expiry date).
     */
    EXPIRED,

    /**
     * Remaining products have been returned to consignor.
     */
    RETURNED,

    /**
     * All products sold or settlement completed.
     */
    COMPLETED
}
