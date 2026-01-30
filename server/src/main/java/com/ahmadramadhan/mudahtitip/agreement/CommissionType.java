package com.ahmadramadhan.mudahtitip.agreement;

/**
 * Type of commission in an agreement.
 */
public enum CommissionType {
    /**
     * Shop gets a percentage of each sale.
     * commission_value = percentage (e.g., 10 for 10%)
     */
    PERCENTAGE,

    /**
     * Shop gets a fixed amount per item sold.
     * commission_value = amount per item (e.g., 2000 for Rp2.000)
     */
    FIXED_PER_ITEM,

    /**
     * Shop gets a bonus if sales reach a threshold.
     * bonus_threshold_percent = minimum sold percentage (e.g., 90)
     * bonus_amount = bonus to pay if threshold met
     */
    TIERED_BONUS
}
