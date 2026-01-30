# Mudah Titip

A consignment marketplace platform that connects product owners with shop owners.

Got stuff to sell but no store? Or have a store but need products? This is where you meet.

## What is Mudah Titip?

It's a digital **consignment** system:

1. **Product Owners** — register, upload products, set prices and commission terms
2. **Shop Owners** — accept consignments, sell at their store, earn commission from sales
3. **Agreements** — flexible negotiation system (percentage, fixed per item, or tiered bonus)

Everything tracked. Everything transparent.

## Tech Stack

### Backend (Java Spring Boot)
- Spring Boot 3.5 + Java 17
- Spring Security + JWT for authentication
- Spring Data JPA + MySQL
- Lombok for cleaner code

### Client (Flutter)
- Flutter 3.10+ with Dart
- State management: flutter_bloc
- Navigation: go_router
- DI: get_it + injectable
- UI: Material 3 with Google Fonts

## Project Structure

```
mudah-titip/
├── server/          # Spring Boot backend
│   ├── src/main/java/com/ahmadramadhan/mudahtitip/
│   │   ├── config/       # App & security config
│   │   ├── controllers/  # REST endpoints
│   │   ├── dto/          # Request/Response objects
│   │   ├── entities/     # JPA entities
│   │   ├── repositories/ # Data access layer
│   │   ├── security/     # JWT & auth logic
│   │   └── services/     # Business logic
│   └── pom.xml
│
└── client/          # Flutter mobile app
    └── lib/
        ├── core/         # API client, theme, DI
        ├── features/     # Auth, Dashboard, etc.
        └── router/       # App routing
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

### 3. Run the Client

```bash
cd client
flutter pub get
flutter run
```

## Current Features

- ✅ Authentication (login & register) + JWT
- ✅ User & Shop management
- ✅ Product CRUD
- ✅ Consignment system with status tracking
- ✅ Agreements with multiple commission types:
  - Percentage (e.g., 10% of sales)
  - Fixed per item (e.g., $5 per item sold)
  - Tiered bonus (bonuses based on sales targets)
- ✅ Sales recording

## Work in Progress

- 🚧 Flutter UI for main features
- 🚧 Real-time notifications
- 🚧 Analytics dashboard

## Development Notes

This project follows:
- Clean Architecture in Flutter (feature-based structure)
- Layered architecture in Spring Boot
- Conventional Commits for git messages

---

> "Mudah Titip" means "Easy Consignment" in Indonesian. Simple as that.
