package com.ahmadramadhan.mudahtitip.auth;

/**
 * User roles in the system.
 * SHOP_OWNER: Manages a shop, receives and sells consigned products
 * CONSIGNOR: Leaves products at shops for sale (penitip)
 * SUPER_ADMIN: Platform administrator with full access
 * MODERATOR: Content moderator for quality control
 * FINANCE_ADMIN: Financial operations manager
 */
public enum UserRole {
    SHOP_OWNER,
    CONSIGNOR,
    SUPER_ADMIN,
    MODERATOR,
    FINANCE_ADMIN
}
