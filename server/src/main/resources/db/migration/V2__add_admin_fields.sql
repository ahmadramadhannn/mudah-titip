-- Migration script to add admin system fields
-- Run this script to update existing database schema

-- Add user status fields
ALTER TABLE users 
ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' AFTER role,
ADD COLUMN last_login_at DATETIME NULL AFTER status,
ADD COLUMN suspension_reason VARCHAR(500) NULL AFTER last_login_at;

-- Add shop verification fields
ALTER TABLE shops
ADD COLUMN is_verified BOOLEAN NOT NULL DEFAULT FALSE AFTER is_active,
ADD COLUMN verification_message VARCHAR(500) NULL AFTER is_verified,
ADD COLUMN verified_at DATETIME NULL AFTER verification_message;

-- Update existing data
UPDATE users SET status = 'ACTIVE' WHERE status IS NULL;
UPDATE shops SET is_verified = FALSE WHERE is_verified IS NULL;
