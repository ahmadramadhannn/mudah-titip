package com.ahmadramadhan.mudahtitip.entities;

/**
 * Status of a consignment (titipan).
 */
public enum ConsignmentStatus {
    /**
     * Active consignment - products available for sale.
     */
    ACTIVE,

    /**
     * Products have expired and should not be sold.
     */
    EXPIRED,

    /**
     * Products were returned to the consignor.
     */
    RETURNED,

    /**
     * All products have been sold or handled.
     */
    COMPLETED
}
