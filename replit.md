# Virtum Health — Mobile + Mock Backend

## Project Overview

This is a health tracking application consisting of:
- **`backend/`** — Node.js (Express) REST API with SQLite database
- **`mobile/`** — Flutter mobile app (Android/iOS)

## Architecture

### Backend (Node.js/Express)
- Runs on port **3000** (localhost)
- SQLite database stored at `backend/virtum.db`
- Auth: Firebase + JWT tokens
- AI chat: OpenRouter API (qwen/qwen-2.5-7b-instruct)
- Email: Resend API

### Mobile (Flutter)
- Flutter app targeting Android/iOS
- Points to backend via `mobile/lib/services/api_config.dart`
- Production backend URL: `https://android-virtum--ayoamooo.replit.app`

## Key Files

- `backend/app.js` — Main Express entry point (starts server, mounts routes)
- `backend/config.js` — Central config loaded from `.env`
- `backend/db.js` — SQLite schema and connection
- `backend/routes/` — API route handlers (auth, data, AI, summary)
- `backend/middlewares.js` — JWT auth, rate limiting, audit logging
- `backend/services/` — Chat engine, intent analyzer, response generator
- `mobile/lib/services/api_config.dart` — Backend URL config
- `mobile/lib/services/api_service.dart` — All API calls

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/health` | None | Health check |
| GET | `/api/data/simulate` | None | Simulate random biomarker data |
| POST | `/api/data/store` | JWT | Store simulated data |
| POST | `/api/data/custom` | JWT | Store user-entered metrics |
| POST | `/api/data/water` | JWT | Save water intake |
| GET | `/api/data/history` | JWT | Get biomarker history |
| GET | `/api/ai/recommend` | JWT | Get AI recommendation |
| POST | `/api/ai/chat` | JWT | Chat with Jeffrey (AI health assistant) |
| GET | `/api/summary/daily\|weekly\|monthly\|yearly` | JWT | Health summaries |
| GET | `/api/auth/firebase-config` | None | Firebase config |
| POST | `/api/auth/login-firebase` | None | Login with Firebase token |
| GET | `/api/auth/me` | JWT | Get current user |
| GET | `/api/provider/aggregate` | Provider role | Aggregated stats |
| GET | `/api/provider/patterns` | Provider role | Anonymized patterns |

## Environment Variables (backend/.env)

- `PORT` — Server port (default: 3000)
- `OPENROUTER_API_KEY` — OpenRouter AI API key
- `JWT_SECRET` — JWT signing secret
- `ALLOWED_ORIGINS` — CORS origins (default: *)
- `RESEND_API_KEY` — Email sending via Resend
- `FIREBASE_*` — Firebase Admin SDK credentials

## Workflows

- **Start application** — `cd backend && node app.js` on port 3000 (console output)

## Deployment

- Target: autoscale
- Run: `node backend/app.js`
- The backend uses SQLite (file-based DB at `backend/virtum.db`)

## Dependencies

- express, cors, sqlite3, jsonwebtoken, firebase-admin, nodemailer, dotenv, crypto-js, jwks-rsa
