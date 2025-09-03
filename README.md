# Premium Content Platform - Backend

Backend API for a Patreon-like premium content platform built with Node.js, Express, and MySQL.

## Features

- JWT Authentication
- Creator tier management
- Subscription system
- Content management
- Real-time notifications
- Payment integration (Mercado Pago, PayPal)
- File upload system

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables in `.env`:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=tcc_project
JWT_SECRET=your-secret-key
```

3. Set up database:
```bash
mysql -u root -p < db_schema.sql
```

4. Start the server:
```bash
npm run dev
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update user profile

### Creator Features
- `POST /api/creators/tiers` - Create subscription tier
- `GET /api/creators/tiers` - Get creator tiers
- `PUT /api/creators/tiers/:id` - Update tier
- `DELETE /api/creators/tiers/:id` - Delete tier
- `POST /api/creators/content` - Publish content
- `GET /api/creators/content` - Get creator content
- `GET /api/creators/stats` - Get creator statistics

## Project Structure

```
├── config/          # Database and configuration
├── controllers/     # Route controllers
├── middleware/      # Authentication middleware
├── models/          # Database models
├── routes/          # API routes
├── docs/            # Documentation
├── .env             # Environment variables
├── db_schema.sql    # Database schema
├── package.json     # Dependencies
└── server.js        # Main server file
```

## Technologies

- Node.js
- Express.js
- MySQL
- JWT Authentication
- Socket.io (Real-time features)
- Mercado Pago & PayPal (Payments)
