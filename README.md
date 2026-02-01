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
- Lombok for cleaner code
- OpenAPI + Scalar for API documentation

### Client (Flutter)
- Dart SDK 3.10+
- State management: flutter_bloc
- Navigation: go_router
- DI: get_it + injectable
- UI: Material 3 with Google Fonts

## Project Structure

```
mudah-titip/
├── server/                    # Spring Boot backend (package-by-feature)
│   └── src/main/java/com/ahmadramadhan/mudahtitip/
│       ├── agreement/         # Agreement entities, services, controllers
│       ├── auth/              # Authentication & JWT
│       ├── common/            # Shared config (security, OpenAPI)
│       ├── consignment/       # Consignment management
│       ├── consignor/         # Guest consignor feature
│       ├── product/           # Product management
│       ├── sale/              # Sales recording
│       └── shop/              # Shop management
│
└── client/                    # Flutter mobile app
    └── lib/
        ├── core/              # API client, theme, DI setup
        ├── features/
        │   ├── agreement/     # Consignment agreements & negotiation
        │   ├── auth/          # Login & registration
        │   ├── dashboard/     # Main dashboard with stats
        │   ├── guest_consignor/  # Manage non-app consignors
        │   ├── products/      # Product CRUD
        │   └── profile/       # User profile management
        └── router/            # App routing
```

## Getting Started

### 1. Database Setup (MySQL)

Create a database and configure your environment:

```bash
cd server
cp .env.example .env
# Edit .env with your MYSQL_USER and MYSQL_ROOT_PASSWORD
```

### 2. Run the Backend

```bash
cd server
./mvnw spring-boot:run
```

Server runs at `http://localhost:8080`

API documentation available at `http://localhost:8080/scalar/api` (Scalar UI)

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
- Product CRUD
- Consignment system with status tracking
- Agreements with multiple commission types:
  - Percentage (e.g., 10% of sales)
  - Fixed per item (e.g., $5 per item sold)
  - Tiered bonus (bonuses based on sales targets)
- Negotiation workflow (propose, counter, accept, reject)
- Sales recording
- Guest consignor management (for non-app users)
- Health check endpoint
- OpenAPI/Scalar API documentation

**Frontend**
- Authentication flow (login, register, splash)
- Dashboard with real-time stats for shop owners and consignors
- Profile management
- Product management (list, add, edit)
- Agreement management with negotiation
- Guest consignor management

### 🚧 Work in Progress

- Push notifications
- Full analytics & reporting

## Development Notes

This project follows:
- **Clean Architecture** in Flutter (feature-based structure)
- **Package-by-Feature** architecture in Spring Boot
- **Conventional Commits** for git messages

---

> "Mudah Titip" means "Easy Consignment" in Indonesian. Simple as that.
