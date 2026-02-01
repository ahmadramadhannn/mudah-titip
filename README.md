# Mudah Titip

A consignment marketplace platform that connects product owners with shop owners.

Got stuff to sell but no store? Or have a store but need products? This is where you meet.

## What is Mudah Titip?

It's a digital **consignment** system:

1. **Consignors (Product Owners)** — register, upload products, set prices and commission terms
2. **Shop Owners** — accept consignments, sell at their store, earn commission from sales
3. **Guest Consignors** — shop owners can manage products from consignors who don't have accounts
4. **Agreements** — flexible negotiation system (percentage, fixed per item, or tiered bonus)

Everything tracked. Everything transparent.

## Tech Stack

### Backend (Java Spring Boot)
- Spring Boot 3.5.7 + Java 17
- Spring Security + JWT for authentication
- Spring Data JPA + MySQL
- **Cloudflare R2 Object Storage** (AWS S3 compatible) for images
- Lombok for cleaner code
- OpenAPI + Scalar for API documentation

### Client (Flutter)
- Dart SDK 3.10+
- State management: flutter_bloc
- Navigation: go_router
- DI: get_it + injectable
- Charts: fl_chart
- UI: Material 3 with Google Fonts

## Project Structure

```
mudah-titip/
├── server/                    # Spring Boot backend (package-by-feature)
│   └── src/main/java/com/ahmadramadhan/mudahtitip/
│       ├── agreement/         # Agreement entities, services, controllers
│       ├── analytics/         # Sales analytics & charts data
│       ├── auth/              # Authentication & JWT
│       ├── common/            # Shared config (security, OpenAPI, seeder)
│       ├── consignment/       # Consignment management
│       ├── consignor/         # Guest consignor feature
│       ├── product/           # Product management
│       ├── sale/              # Sales recording
│       ├── shop/              # Shop management
│       └── storage/           # R2 Object Storage integration
│
└── client/                    # Flutter mobile app
    └── lib/
        ├── core/              # API client, theme, DI setup
        ├── features/
        │   ├── agreement/     # Consignment agreements & negotiation
        │   ├── analytics/     # Analytics dashboard with charts
        │   ├── auth/          # Login & registration
        │   ├── consignment/   # Consignment tracking
        │   ├── dashboard/     # Main dashboard with stats
        │   ├── guest_consignor/  # Manage non-app consignors
        │   ├── products/      # Product CRUD
        │   ├── profile/       # User profile management
        │   └── sale/          # Sales processing
        └── router/            # App routing
```

## Getting Started

### 1. Database Setup (MySQL)

Create a database and configure your environment:

```bash
cd server
cp .env.example .env
# Edit .env with your:
# - MYSQL_USER & MYSQL_ROOT_PASSWORD
# - R2_ACCESS_KEY_ID & R2_SECRET_ACCESS_KEY (for image uploads)
```

### 2. Run the Backend

```bash
cd server
./mvnw spring-boot:run
```

- Server runs at `http://localhost:8080`
- API documentation: `http://localhost:8080/scalar/api`
- **Data Seeding**: On first run, dummy data (Shop Owner, Consignor, Products) is automatically created.
    - Owner: `owner@example.com` / `password123`
    - Consignor: `consignor@example.com` / `password123`

### 3. Run the Client

```bash
cd client
flutter pub get
flutter run
```

## Features

### ✅ Implemented

**Backend**
- Authentication (login & register) with JWT
- User & Shop management
- Product CRUD with **Image Upload (R2)**
- Consignment system with status tracking
- Agreements with multiple commission types
- Negotiation workflow (propose, counter, accept, reject)
- Sales recording & **Analytics**
- Guest consignor management
- Automatic Data Seeding
- OpenAPI/Scalar API documentation

**Frontend**
- Authentication flow (login, register, splash)
- Dashboard with real-time stats
- **Analytics Dashboard** (Charts for sales trends, top products)
- Profile management
- Product management (list, add, edit, upload images)
- Agreement management with negotiation
- Guest consignor management
- Consignment tracking

### 🚧 Work in Progress

- Push notifications
- Advanced reporting export

## Development Notes

This project follows:
- **Clean Architecture** in Flutter (feature-based structure)
- **Package-by-Feature** architecture in Spring Boot
- **Conventional Commits** for git messages

---

> "Mudah Titip" means "Easy Consignment" in Indonesian. Simple as that.
