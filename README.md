# WeStore

A modern, full-stack e-commerce platform with a REST API backend, React admin dashboard, and cross-platform Flutter mobile app.

## Features

### Mobile App (Flutter)
- **Authentication** — Login, register, email verification, JWT auto-refresh
- **Product Browsing** — Categories, featured products, flash sales with live countdown, search with filters
- **Shopping Cart** — Add/update/remove items, badge counts, subtotal calculation
- **Checkout** — Order creation with shipping address and payment selection
- **Order Management** — Order history, status tracking, cancellation
- **User Profile** — Edit profile, avatar upload, address management, wishlist, saved cards
- **Reviews** — Product reviews with ratings, user review management
- **Notifications** — In-app notifications with unread badges
- **Settings** — Dark/light theme toggle, notification preferences

### Admin Dashboard (React)
- **Dashboard** — Sales overview, order stats, user analytics with charts
- **Product Management** — CRUD operations, image uploads, inventory tracking
- **Category Management** — Hierarchical categories with image support
- **Order Management** — View all orders, update status, track fulfillment
- **User Management** — User listing, role assignment, account management
- **Review Moderation** — View and manage all product reviews

### Backend API (Node.js)
- **Authentication** — JWT access + refresh tokens, email verification, password reset
- **Authorization** — Role-based access control (user/admin)
- **Security** — Helmet, CORS, rate limiting, input sanitization, bcrypt hashing
- **File Uploads** — Cloudinary integration for product/category/avatar images
- **Email** — Transactional emails via Resend (verification, password reset)
- **Error Handling** — Centralized error middleware with structured responses
- **Graceful Shutdown** — Proper cleanup of MongoDB connections and HTTP server

---

## Tech Stack

| Component | Technology |
|---|---|
| **Backend** | Node.js 22+, Express 5, MongoDB + Mongoose |
| **Admin** | React 18, TypeScript, Vite, Chakra UI, React Query, Zustand, Recharts |
| **Mobile** | Flutter, Dart, Riverpod, GoRouter, Dio, Freezed |
| **Services** | Cloudinary (images), Resend (email) |
| **Security** | JWT, bcryptjs, Helmet, CORS, express-rate-limit, express-validator |

---

## Prerequisites

- **Node.js** >= 22.0.0
- **npm** >= 10.0.0
- **Flutter SDK** >= 3.0.0
- **MongoDB** (local or Atlas)
- **Cloudinary** account
- **Resend** API key

---

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd ecommerce_flutter
```

### 2. Backend Setup

```bash
# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your MongoDB URI, JWT secrets, Cloudinary, and Resend credentials

# Start development server
npm run dev
```

The API runs on `http://localhost:5000`.

### 3. Admin Dashboard Setup

```bash
cd admin
npm install
npm run dev
```

The dashboard runs on `http://localhost:5173`.

### 4. Mobile App Setup

```bash
cd mobile
flutter pub get
flutter run
```

For Android emulator with local backend:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
```

---

## Environment Variables

| Variable | Description | Required |
|---|---|---|
| `NODE_ENV` | Environment mode (`development` / `production`) | Yes |
| `PORT` | Server port (default: `5000`) | No |
| `MONGODB_URI` | MongoDB connection string | Yes |
| `JWT_SECRET` | JWT signing key (min 64 chars) | Yes |
| `JWT_EXPIRE` | Access token expiry (default: `7d`) | No |
| `JWT_REFRESH_SECRET` | Refresh token signing key (min 64 chars) | Yes |
| `JWT_REFRESH_EXPIRE` | Refresh token expiry (default: `30d`) | No |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name | Yes |
| `CLOUDINARY_API_KEY` | Cloudinary API key | Yes |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret | Yes |
| `RESEND_API_KEY` | Resend email API key | Yes |
| `CLIENT_URL` | Frontend URL(s), comma-separated | Yes |
| `EMAIL_VERIFY_EXPIRE` | Email verification token expiry (ms) | No |
| `DEV_AUTO_VERIFY` | Auto-verify emails in development (`true`/`false`) | No |

Generate secure JWT secrets:
```bash
openssl rand -hex 64
```

---

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/register` | Register new user |
| `POST` | `/api/auth/login` | Login |
| `POST` | `/api/auth/logout` | Logout |
| `POST` | `/api/auth/refresh-token` | Refresh JWT token |
| `GET` | `/api/auth/me` | Get current user |
| `POST` | `/api/auth/forgot-password` | Request password reset |
| `PUT` | `/api/auth/reset-password/:token` | Reset password |
| `PUT` | `/api/auth/update-password` | Change password |
| `GET` | `/api/auth/verify-email/:token` | Verify email |

### Products
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/products` | List products (paginated) |
| `GET` | `/api/products/featured` | Featured products |
| `GET` | `/api/products/flash-sale` | Flash sale products |
| `GET` | `/api/products/:id` | Get product by ID |
| `GET` | `/api/products/slug/:slug` | Get product by slug |
| `POST` | `/api/products` | Create product (admin) |
| `PUT` | `/api/products/:id` | Update product (admin) |
| `DELETE` | `/api/products/:id` | Delete product (admin) |

### Cart
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/cart` | Get cart |
| `POST` | `/api/cart` | Add to cart |
| `PUT` | `/api/cart/:itemId` | Update cart item |
| `DELETE` | `/api/cart/:itemId` | Remove from cart |
| `DELETE` | `/api/cart` | Clear cart |

### Orders
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/orders` | My orders |
| `POST` | `/api/orders` | Create order |
| `GET` | `/api/orders/:id` | Order details |
| `PUT` | `/api/orders/:id/cancel` | Cancel order |
| `GET` | `/api/orders/admin/all` | All orders (admin) |
| `PUT` | `/api/orders/admin/:id/status` | Update status (admin) |

### Users
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/users/profile` | Get profile |
| `PUT` | `/api/users/profile` | Update profile |
| `DELETE` | `/api/users/profile` | Delete account |
| `GET` | `/api/users/addresses` | Get addresses |
| `POST` | `/api/users/addresses` | Add address |
| `PUT` | `/api/users/addresses/:id` | Update address |
| `DELETE` | `/api/users/addresses/:id` | Delete address |
| `GET` | `/api/users/wishlist` | Get wishlist |
| `POST` | `/api/users/wishlist/:productId` | Add to wishlist |
| `DELETE` | `/api/users/wishlist/:productId` | Remove from wishlist |

### Categories, Reviews, Notifications, Payments
Additional endpoints for categories (CRUD), reviews (CRUD), notifications (list/mark read), and payments (validate/process). See backend routes for full details.

---

## Project Structure

```
ecommerce_flutter/
├── backend/                 # Express.js REST API
│   ├── config/              # Database & Cloudinary config
│   ├── controllers/         # Request handlers
│   ├── middlewares/         # Auth, error, sanitization, validation
│   ├── models/              # Mongoose schemas (8 models)
│   ├── routes/              # API route definitions (11 modules)
│   ├── utils/               # Helper utilities
│   ├── validators/          # Request validation schemas
│   └── server.js            # Express app entry point
├── admin/                   # React admin dashboard
│   ├── src/
│   │   ├── components/      # Reusable UI components
│   │   ├── hooks/           # Custom React hooks
│   │   ├── pages/           # Dashboard pages
│   │   ├── services/        # API client (Axios)
│   │   └── store/           # Zustand state management
│   └── vite.config.ts       # Vite configuration
├── mobile/                  # Flutter mobile app
│   ├── lib/
│   │   ├── core/            # Shared: DI, network, router, theme, utils
│   │   ├── features/        # Feature modules (auth, cart, home, order, etc.)
│   │   └── main.dart        # Flutter entry point
│   └── pubspec.yaml         # Flutter dependencies
├── scripts/                 # Utility scripts
│   └── create-admin.js      # Create admin user script
├── .env.example             # Environment template
└── package.json             # Root package (backend)
```

---

## Available Scripts

### Backend (root)
```bash
npm run dev     # Start with nodemon (development)
npm start       # Start production server
```

### Admin Dashboard
```bash
npm run dev         # Start Vite dev server
npm run build       # TypeScript + Vite production build
npm run preview     # Preview production build
npm run lint        # ESLint check
npm run typecheck   # TypeScript type check
```

### Mobile App
```bash
flutter pub get         # Install dependencies
flutter run             # Run on connected device
flutter build apk       # Build Android APK
flutter build ios       # Build iOS app
```

### Utilities
```bash
# Create an admin user
node scripts/create-admin.js
```

---

## Security

- **JWT Authentication** — Access + refresh token rotation with secure storage
- **Password Hashing** — bcrypt with cost factor 12
- **Rate Limiting** — Global and endpoint-specific limits (auth, payments, health)
- **Input Sanitization** — Custom middleware for XSS prevention
- **Helmet** — HTTP security headers
- **CORS** — Configurable allowed origins with credentials support
- **Validation** — express-validator schemas on all inputs
- **Graceful Shutdown** — Proper resource cleanup on SIGTERM/SIGINT

---
