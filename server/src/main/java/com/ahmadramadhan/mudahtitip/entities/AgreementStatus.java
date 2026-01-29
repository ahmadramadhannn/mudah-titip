package com.ahmadramadhan.mudahtitip.entities;

/**
 * Status of an agreement negotiation.
 */
public enum AgreementStatus {
    /**
     * Initial proposal, waiting for response.
     */
    PROPOSED,

    /**
     * Counter-offer made, waiting for response.
     */
    COUNTER,

    /**
     * Agreement accepted by both parties.
     */
    ACCEPTED,

    /**
     * Agreement rejected, no deal.
     */
    REJECTED
}
