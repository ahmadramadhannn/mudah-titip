# 📦 Mudah Titip - App Flow Guide

## 🎭 User Roles

### 1. **CONSIGNOR (Penitip)** - Product Owner
- Has products to sell but NO physical shop
- Wants to place products in shops on consignment

### 2. **SHOP_OWNER (Pemilik Toko)** - Store Owner
- Has a physical shop
- Wants to fill shelves without buying inventory upfront
- Earns commission from sales

---

## 🔄 Core Business Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CONSIGNMENT WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  CONSIGNOR                          SHOP OWNER                       │
│  (Siti Consignor)                   (Jonatan)                        │
│       │                                  │                           │
│       │  1. CREATE PRODUCTS              │                           │
│       │  ──────────────────►             │                           │
│       │  • Keripik Singkong Pedas        │                           │
│       │  • Kue Bolu Kukus                │                           │
│       │                                  │                           │
│       │                                  │  2. BROWSE PRODUCTS       │
│       │                                  │  ◄──────────────────      │
│       │                                  │  (sees available products)│
│       │                                  │                           │
│       │       3. PROPOSE AGREEMENT       │                           │
│       │  ◄───────────────────────────────│                           │
│       │  "I want to sell your Keripik"   │                           │
│       │  • Commission: 15%               │                           │
│       │  • Quantity: 50 pcs              │                           │
│       │  • Duration: 30 days             │                           │
│       │                                  │                           │
│       │  4. ACCEPT/REJECT/COUNTER        │                           │
│       │  ──────────────────────────────► │                           │
│       │  (Consignor reviews proposal)    │                           │
│       │                                  │                           │
│       │       5. AGREEMENT ACTIVE        │                           │
│       │  ◄───────────────────────────────│                           │
│       │  → CONSIGNMENT CREATED           │                           │
│       │  • Products placed in shop       │                           │
│       │  • Stock tracked                 │                           │
│       │                                  │                           │
│       │                                  │  6. RECORD SALES          │
│       │                                  │  ──────────────────►      │
│       │                                  │  (customer buys product)  │
│       │                                  │                           │
│       │       7. NOTIFICATIONS           │                           │
│       │  ◄───────────────────────────────│                           │
│       │  • "3 Keripik Singkong sold!"    │                           │
│       │  • "Stock running low"           │                           │
│       │                                  │                           │
│       │                                  │  8. SETTLEMENT            │
│       │  ◄───────────────────────────────│                           │
│       │  • Shop keeps 15% commission     │                           │
│       │  • Consignor receives 85%        │                           │
│       │                                  │                           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📱 Navigation Flow per Role

### CONSIGNOR (consignor@example.com)
```
Dashboard (Beranda)
    ├── See sales summary
    ├── View notifications (stock alerts, sale records)
    │
├── Produk
│   ├── View my products
│   ├── Add new product
│   └── Edit/Delete product
│
├── Titipan (Consignments)
│   ├── View active consignments
│   ├── Track stock at each shop
│   └── See sales per shop
│
├── Kesepakatan (Agreements)
│   ├── ⭐ INCOMING proposals from shop owners
│   ├── Accept / Reject / Counter-offer
│   └── View active agreements
│
└── Profile
    ├── Edit profile
    └── Settings / Logout
```

### SHOP_OWNER (jonatan@example.com)
```
Dashboard (Beranda)
    ├── See shop statistics
    ├── View notifications (new proposals, low stock)
    │
├── Produk
│   ├── Browse available products from consignors
│   └── Guest consignor products
│
├── Titipan (Consignments)
│   ├── View products in my shop
│   ├── Record sales
│   └── Track inventory
│
├── Kesepakatan (Agreements)
│   ├── ⭐ CREATE new proposal to consignor
│   ├── Set commission rate, quantity, terms
│   └── View my proposals & agreements
│
└── Profile
    ├── Manage shop details
    └── Settings / Logout
```

---

## 🤝 Agreement States

```
PROPOSED → ACCEPTED → (creates CONSIGNMENT)
    │
    ├── REJECTED
    │
    └── COUNTER_OFFERED → ACCEPTED/REJECTED
```

### Agreement Types:
- **PERCENTAGE**: Shop takes X% of sale price
- **FIXED**: Shop takes fixed amount per item
- **TIERED**: Different rates based on quantity sold

---

## 📝 Test Scenario: jonatan ↔ consignor

### Step 1: Login as `jonatan@example.com` (SHOP_OWNER)
1. Go to **Kesepakatan** → **Create New Agreement**
2. Select product: **Keripik Singkong Pedas** (from Siti Consignor)
3. Set terms:
   - Commission: 15%
   - Quantity: 50 pcs
   - Duration: 30 days
4. Submit proposal

### Step 2: Login as `consignor@example.com` (CONSIGNOR)
1. Check **Notifications** (should see new proposal)
2. Go to **Kesepakatan** → See incoming proposal
3. **Accept** the agreement

### Result:
- Agreement becomes ACTIVE
- Consignment is created automatically
- Both users receive notifications
- Stock tracking begins

---

## 🔔 Notification Types

| Type | Triggered When | Who Receives |
|------|----------------|--------------|
| `AGREEMENT_PROPOSED` | Shop owner sends proposal | Consignor |
| `AGREEMENT_ACCEPTED` | Consignor accepts | Shop owner |
| `AGREEMENT_REJECTED` | Consignor rejects | Shop owner |
| `SALE_RECORDED` | Item sold in shop | Consignor |
| `STOCK_LOW` | Stock ≤ 5 units | Both |
| `STOCK_OUT` | Stock = 0 | Consignor |
| `CONSIGNMENT_EXPIRING` | 7 days before expiry | Both |
| `CONSIGNMENT_COMPLETED` | All items sold | Both |

---

## 📊 Test Accounts

| Email | Password | Role | Has |
|-------|----------|------|-----|
| `owner@example.com` | `password123` | SHOP_OWNER | Toko Berkah Jaya |
| `consignor@example.com` | `password123` | CONSIGNOR | 2 products |
| `jonatan@example.com` | `password123` | SHOP_OWNER | Toko Jonatan |
| `nurul@example.com` | `indonesiajuara` | CONSIGNOR | Keripik Pisang |

