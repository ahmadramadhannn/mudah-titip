-- Migration V3: Update notification type enum with all notification types
-- This migration updates the notifications table to use VARCHAR instead of ENUM
-- to avoid issues with adding new notification types in the future.

-- Step 1: Alter the table to change type column from ENUM to VARCHAR
ALTER TABLE notifications MODIFY COLUMN `type` VARCHAR(50) NOT NULL;

-- Note: If the column was already VARCHAR, this will be a no-op.
-- The NotificationType enum values in Java will handle validation.
