# 📦 Mudah Titip

> **Connect. Consign. Profit.**
> A modern consignment marketplace platform bridging the gap between product owners and shop owners.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.2.1-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white)
![Java](https://img.shields.io/badge/Java-17-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)

---

## 📖 About The Project

**Mudah Titip** (Indonesian for *"Easy Consignment"*) is a comprehensive digital solution for the consignment business model. It solves the chaos of manual tracking by providing a transparent, real-time platform for:

1.  **Consignors (Product Owners)**: Start selling without owning a store. Upload products, propose agreements, and track sales live.
2.  **Shop Owners**: Fill empty shelves without capital risk. Manage incoming products, set terms, and earn commissions.

### 🌟 Key Features

*   **👥 Role-Based Ecosystem**: Distinct, tailored interfaces for Shop Owners and Consignors.
*   **📊 Analytics Dashboard**: Beautiful, real-time charts using `fl_chart` to visualize sales trends, top products, and earnings.
*   **🌍 Multi-Language Support**: Fully localized in **Indonesian (ID)** and **English (EN)**.
*   **📝 Agreement Workflow**: Flexible negotiation system with support for Percentage, Fixed, or Tiered commission models.
*   **☁️ Cloud Integration**: Robust image hosting using **Cloudflare R2** (S3-compatible) for fast, secure assets.
*   **👤 Guest Consignors**: Shop owners can manage products from non-app users, bridging the offline-online gap.
*   **🔐 Secure Authentication**: JWT-based security with seamless login/registration flows.

---

## 🛠 Tech Stack

### Client (Mobile App)
*   **Framework**: Flutter (Dart)
*   **State Management**: `flutter_bloc`
*   **Navigation**: `go_router`
*   **Dependency Injection**: `get_it` + `injectable`
*   **UI/UX**: Material 3 Design, Google Fonts, `fl_chart`
*   **Localization**: `flutter_localizations` (ARB files)

### Backend (API)
*   **Framework**: Spring Boot 3
*   **Language**: Java 17
*   **Database**: MySQL / PostgreSQL
*   **ORM**: Spring Data JPA
*   **Storage**: Cloudflare R2 (AWS S3 SDK)
*   **Documentation**: OpenAPI + Scalar
*   **Structure**: Package-by-Feature Architecture

---

## 📂 Project Structure

Verified architecture for scalability and maintainability.

```
mudah-titip/
├── server/                    # Spring Boot Backend
│   └── src/main/java/com/ahmadramadhan/mudahtitip/
│       ├── analytics/         # 📈 Sales intelligence
│       ├── agreement/         # 🤝 Negotiation logic
│       ├── auth/              # 🔐 Security & Users
│       ├── consignment/       # 📦 Core consignment logic
│       ├── consignor/         # 👤 Guest consignor features
│       ├── product/           # 🏷️ Product catalog
│       ├── sale/              # 💰 Transaction records
│       └── storage/           # ☁️ R2 integration
│
└── client/                    # Flutter Frontend
    └── lib/
        ├── core/              # Shared logic, Config, Theme
        ├── features/          # Feature-based folders
        │   ├── analytics/     # Dashboard charts
        │   ├── auth/          # Login screens
        │   ├── agreement/     # Agreement UI
        │   ├── dashboard/     # Home dashboard
        │   ├── products/      # Product management
        │   ├── profile/       # User settings
        │   └── splash/        # Startup logic
        └── l10n/              # 🌏 Localization (app_en.arb, app_id.arb)
```

---

## 🚀 Getting Started

### Prerequisites
*   **Java**: JDK 17 or higher
*   **Flutter**: SDK 3.10.x or higher
*   **Database**: MySQL (local or docker)

### 1. Backend Setup

1.  Navigate to the server directory:
    ```bash
    cd server
    ```
2.  Configure Environment Variables:
    ```bash
    cp .env.example .env
    ```
    Update `.env` with your credentials:
    ```properties
    MYSQL_USER=root
    MYSQL_ROOT_PASSWORD=your_password
    
    # Cloudflare R2 (Required for Image Uploads)
    R2_ACCESS_KEY_ID=your_key
    R2_SECRET_ACCESS_KEY=your_secret
    R2_ACCOUNT_ID=your_account_id
    R2_BUCKET_NAME=your_bucket
    R2_PUBLIC_URL=https://your-domain.com
    ```
3.  Run the application:
    ```bash
    ./mvnw spring-boot:run
    ```
    > 🟢 Server will start at `http://localhost:8080`
    > 📄 API Docs available at `http://localhost:8080/scalar/api`

    **Note**: The app automatically seeds dummy data on the first run.
    *   **Shop Owner**: `owner@example.com` / `password123`
    *   **Consignor**: `consignor@example.com` / `password123`

### 2. Client Setup

1.  Navigate to the client directory:
    ```bash
    cd client
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```

---

## 🚧 Roadmap

- [x] Core Consignment System
- [x] Negotiation Workflow
- [x] Analytics Dashboard
- [x] Image Uploads (R2)
- [x] Localization (ID/EN)
- [ ] Push Notifications
- [ ] Export Reports to PDF/Excel
- [ ] Chat System

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

> Built with ❤️ by Ahmad Ramadhan & Antigravity Agent.
