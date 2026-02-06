# Database Migration Guide

## Issue
The database schema needs to be updated to support the new admin system fields.

## Option 1: Manual SQL Migration (Recommended for existing data)

Run this SQL script on your MySQL database:

```sql
-- Add user status fields
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' AFTER role,
ADD COLUMN IF NOT EXISTS last_login_at DATETIME NULL AFTER status,
ADD COLUMN IF NOT EXISTS suspension_reason VARCHAR(500) NULL AFTER last_login_at;

-- Add shop verification fields
ALTER TABLE shops
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN NOT NULL DEFAULT FALSE AFTER is_active,
ADD COLUMN IF NOT EXISTS verification_message VARCHAR(500) NULL AFTER is_verified,
ADD COLUMN IF NOT EXISTS verified_at DATETIME NULL AFTER verification_message;

-- Update existing data
UPDATE users SET status = 'ACTIVE' WHERE status IS NULL OR status = '';
UPDATE shops SET is_verified = FALSE WHERE is_verified IS NULL;
```

## Option 2: Drop and Recreate (For development only)

**WARNING: This will delete all existing data!**

```bash
# Connect to MySQL
mysql -u root -p

# Drop and recreate database
DROP DATABASE mudahtitip;
CREATE DATABASE mudahtitip;
exit;

# Restart the Spring Boot application
# It will automatically create the schema with new fields
```

## Option 3: Use the provided SQL file

```bash
# Run the migration script
mysql -u root -p mudahtitip < server/src/main/resources/db/migration/V2__add_admin_fields.sql
```

## After Migration

Restart the Spring Boot application:
```bash
cd server
./mvnw spring-boot:run
```

The DataSeeder will automatically create the admin account:
- Email: `admin@mudahtitip.com`
- Password: `admin123`
