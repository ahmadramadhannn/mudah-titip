-- Add PENDING status to consignment status enum
-- Increase column length to accommodate new status value

ALTER TABLE consignments MODIFY COLUMN status VARCHAR(20) NOT NULL;
