# Testing Guide: Shop Owner Agreement Flow

## Prerequisites

1. **Backend Server Running**
   ```bash
   cd server
   ./mvnw spring-boot:run
   ```

2. **Frontend Client Running**
   ```bash
   cd client
   flutter run -d chrome  # or your preferred device
   ```

3. **Test Accounts**
   - Shop Owner account
   - Consignor account with some products

---

## Test Scenario: Complete Shop Owner Flow

### Part 1: Browse Products (Shop Owner)

**Steps:**
1. ✅ Login as **Shop Owner**
2. ✅ On dashboard, click **"Cari Produk"** (Browse Products) button
3. ✅ Verify products are displayed in grid layout
4. ✅ Test category filter dropdown
5. ✅ Click on a product card
6. ✅ Verify product detail bottom sheet opens
7. ✅ Review product information (name, price, description, category)

**Expected Results:**
- Products from all consignors are visible
- Category filtering works correctly
- Product details display correctly in modal
- Images load properly (or show placeholder if missing)

---

### Part 2: Create Consignment (Shop Owner)

**Steps:**
1. ✅ From product detail modal, click **"Ajukan Perjanjian"** (Propose Agreement)
2. ✅ Verify navigation to create consignment page
3. ✅ Verify product info card displays correctly
4. ✅ Enter **Quantity** (e.g., 50)
5. ✅ Verify **Selling Price** is pre-filled with base price
6. ✅ Optionally modify selling price
7. ✅ Optionally add notes
8. ✅ Click **"Lanjutkan ke Perjanjian"** (Continue to Agreement)

**Expected Results:**
- Form displays product information correctly
- Validation errors show for invalid input (negative numbers, empty fields)
- Selling price defaults to product base price
- Clicking continue creates consignment and navigates to propose agreement

---

### Part 3: Propose Agreement (Shop Owner)

**Steps:**
1. ✅ After consignment creation, verify navigation to propose agreement page
2. ✅ Consignment ID should be auto-filled in the URL
3. ✅ Select commission type (Percentage/Fixed/Tiered)
4. ✅ Enter commission value
5. ✅ Optionally add agreement notes and terms
6. ✅ Click **"Ajukan Perjanjian"** (Submit Proposal)

**Expected Results:**
- Agreement proposal is created with status `PROPOSED`
- Consignment remains in `PENDING` status
- Success message shown
- Redirected to agreements list or detail page

---

### Part 4: Review & Accept Agreement (Consignor)

**Steps:**
1. ✅ Logout shop owner
2. ✅ Login as **Consignor** (product owner)
3. ✅ Navigate to Agreements page
4. ✅ Verify notification/indicator for new proposal
5. ✅ Open the proposed agreement
6. ✅ Review terms (commission, quantity, price)
7. ✅ Click **"Accept"** or **"Counter"** button

**Expected Results:**
- Consignor sees the new agreement proposal
- All agreement details are correct
- Upon acceptance:
  - Agreement status → `ACCEPTED`
  - Consignment status → `PENDING` → `ACTIVE`
  - Both parties receive appropriate notifications

---

## API Endpoints to Test

### 1. Browse Products
```bash
GET /api/v1/products/available
Authorization: Bearer <shop_owner_token>

# With category filter
GET /api/v1/products/available?category=Makanan%20Ringan
```

**Expected:** 200 OK with list of active products

### 2. Create Consignment (Shop Owner)
```bash
POST /api/v1/consignments
Authorization: Bearer <shop_owner_token>
Content-Type: application/json

{
  "productId": 1,
  "shopId": 1,
  "quantity": 50,
  "sellingPrice": 15000,
  "notes": "Test consignment"
}
```

**Expected:** 201 Created with consignment object (status: `PENDING`)

### 3. Propose Agreement
```bash
POST /api/v1/agreements
Authorization: Bearer <shop_owner_token>
Content-Type: application/json

{
  "consignmentId": 123,
  "commissionType": "PERCENTAGE",
  "commissionValue": 15,
  "termsNote": "15% commission on sales"
}
```

**Expected:** 201 Created with agreement object (status: `PROPOSED`)

### 4. Accept Agreement
```bash
PUT /api/v1/agreements/{agreementId}/accept
Authorization: Bearer <consignor_token>
```

**Expected:** 
- 200 OK
- Agreement status → `ACCEPTED`
- Related consignment status → `ACTIVE`

---

## Edge Cases to Test

### 1. Validation Errors
- [ ] Enter negative quantity → Should show error
- [ ] Enter zero or negative price → Should show error
- [ ] Leave required fields empty → Should show validation messages

### 2. Product Edge Cases
- [ ] Product without image → Should show placeholder
- [ ] Product without category → Should display gracefully
- [ ] Product with very long name → Should truncate with ellipsis

### 3. Error Scenarios
- [ ] Network error during product load → Should show error state with retry button
- [ ] Server error during consignment creation → Should show error message
- [ ] Unauthorized access to products → Should handle 403 appropriately

### 4. Category Filtering
- [ ] Select different categories → Products should filter correctly
- [ ] Select "All Categories" → Should show all products again
- [ ] Empty category → Should show "no products" state

---

## Known Limitations

1. **Shop ID Hardcoded**: CreateConsignmentForProductPage currently sets `shopId: 0`. Backend should extract shop from authenticated user.

2. **No Duplicate Check**: System doesn't prevent shop owner from creating multiple consignments for the same product.

3. **No Product Search**: Browse page only has category filter, no text search yet.

---

## Success Criteria

✅ **All checks must pass:**

- [ ] Shop owner can browse all active products
- [ ] Category filtering works correctly
- [ ] Product details display correctly
- [ ] Consignment creation succeeds with valid data
- [ ] Consignment is created with `PENDING` status
- [ ] Auto-navigation works after consignment creation
- [ ] Agreement proposal succeeds
- [ ] Consignor receives notification of new proposal
- [ ] Agreement acceptance updates consignment to `ACTIVE`
- [ ] Error handling works gracefully
- [ ] UI is responsive and user-friendly

---

## Troubleshooting

**Problem**: "Product not found" error  
**Solution**: Ensure product ID exists and is active

**Problem**: 403 Forbidden on `/products/available`  
**Solution**: Verify user has SHOP_OWNER role

**Problem**: Consignment stays PENDING after agreement acceptance  
**Solution**: Check backend logs for agreement acceptance handler

**Problem**: Navigation doesn't work after creating consignment  
**Solution**: Verify router configuration for `/agreements/propose/:consignmentId`
