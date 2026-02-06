# Database Migration - Final Steps

## Current Situation

The Spring Boot server has successfully created the new admin fields in the database:
- ✅ `users.status` column created
- ✅ `users.last_login_at` column created  
- ✅ `users.suspension_reason` column created
- ✅ `shops.is_verified` column created
- ✅ `shops.verification_message` column created
- ✅ `shops.verified_at` column created

**However**, there's one issue: The existing `users.role` column is too small to fit the new admin roles like `SUPER_ADMIN`.

---

## Solution: Resize the Role Column

You need to run ONE SQL command to resize the `role` column:

### Option 1: Using MySQL Command Line

```bash
# Install MySQL client if not installed
sudo apt install mysql-client-core-8.0

# Connect to MySQL
mysql -u root -p

# Switch to database
USE mudahtitip_db;

# Resize the role column
ALTER TABLE users MODIFY COLUMN role VARCHAR(20) NOT NULL;

# Verify
DESCRIBE users;

# Exit
EXIT;
```

### Option 2: Using MySQL Workbench or phpMyAdmin

1. Open your MySQL GUI tool
2. Connect to `mudahtitip_db` database
3. Run this SQL:
   ```sql
   ALTER TABLE users MODIFY COLUMN role VARCHAR(20) NOT NULL;
   ```

### Option 3: Using Docker (if MySQL is in Docker)

```bash
# Find your MySQL container
docker ps | grep mysql

# Execute SQL directly
docker exec -it <container_name> mysql -u root -p -e "USE mudahtitip_db; ALTER TABLE users MODIFY COLUMN role VARCHAR(20) NOT NULL;"
```

---

## After Running the SQL

Once you've resized the `role` column, the Spring Boot server will start successfully and:

1. ✅ All database columns will be properly sized
2. ✅ DataSeeder will create the admin account
3. ✅ Admin login will work

**Admin Credentials:**
- Email: `admin@mudahtitip.com`
- Password: `admin123`

---

## Verification Steps

After the server starts successfully:

1. **Check the logs** for:
   ```
   Admin user created successfully
   ```

2. **Test admin login** via API:
   ```bash
   curl -X POST http://localhost:8080/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email": "admin@mudahtitip.com", "password": "admin123"}'
   ```

3. **Test admin endpoint**:
   ```bash
   curl -X GET http://localhost:8080/api/v1/admin/analytics/overview \
     -H "Authorization: Bearer YOUR_TOKEN_HERE"
   ```

---

## Quick Reference

**What was done automatically:**
- ✅ New columns created by Hibernate
- ✅ Default values set
- ✅ Existing data preserved

**What needs manual action:**
- ⏳ Resize `users.role` column (ONE SQL command)
- ⏳ Restart Spring Boot server

**Total time:** ~2 minutes

---

## Troubleshooting

### If you get "Access denied"
```bash
# Reset MySQL root password if needed
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your_password';
FLUSH PRIVILEGES;
EXIT;
```

### If you can't find MySQL
```bash
# Check if MySQL is running
sudo systemctl status mysql

# Or check Docker
docker ps | grep mysql
```

---

## Alternative: Fresh Database (Nuclear Option)

If you want to start fresh (⚠️ **WARNING: This deletes all data**):

```bash
# Drop and recreate database
mysql -u root -p -e "DROP DATABASE IF EXISTS mudahtitip_db; CREATE DATABASE mudahtitip_db;"

# Then start Spring Boot - it will create everything fresh
cd server && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

---

**Ready to proceed?** Just run the SQL command above and then start the server! 🚀
