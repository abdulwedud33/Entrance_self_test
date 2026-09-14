# Grade 12 Entrance Exam Self-Test System

A full-stack web application that allows students to practice multiple-choice entrance examination questions online in preparation for the Grade 12 entrance exam.

---

## 📋 Project Structure

```
Entrance_Self_Test/
├── backend/                  # Express.js + TypeScript + Prisma
│   ├── prisma/
│   │   ├── schema.prisma     # Database schema (PostgreSQL)
│   │   └── seed.ts           # Seed script (admin + sample data)
│   ├── src/
│   │   ├── controllers/      # Business logic
│   │   ├── middleware/       # JWT auth + role guards
│   │   ├── routes/           # API route definitions
│   │   ├── utils/            # Prisma client + JWT helpers
│   │   └── index.ts          # Express server entry point
│   ├── .env.example
│   ├── package.json
│   └── tsconfig.json
│
└── frontend/                 # Next.js 15 + TypeScript + Tailwind
    ├── src/
    │   ├── app/
    │   │   ├── login/        # Login page
    │   │   ├── admin/        # Admin dashboard + all sub-pages
    │   │   └── student/      # Student dashboard + exam flow
    │   ├── components/ui/    # shadcn/ui components
    │   ├── hooks/            # useAuth context hook
    │   └── lib/
    │       ├── api.ts        # Typed API client
    │       └── utils.ts      # cn() tailwind helper
    ├── .env.local.example
    └── package.json
```

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Next.js 15 (App Router), TypeScript, Tailwind CSS, shadcn/ui |
| Backend | Express.js, TypeScript |
| Database | PostgreSQL + Prisma ORM |
| Auth | JWT + httpOnly Cookies (role-based: ADMIN / STUDENT) |
| Validation | Zod |
| Passwords | bcryptjs |
| Dates | dayjs |

---

## 🚀 Setup & Installation

### Prerequisites

- Node.js 18+
- PostgreSQL (local or remote)
- npm or yarn

---

### 1. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Copy environment file and fill in your values
cp .env.example .env
```

Edit `.env`:
```env
DATABASE_URL="postgresql://USER:PASSWORD@localhost:5432/ftvti_db"
JWT_SECRET="your-super-secret-jwt-key"
PORT=5000
NODE_ENV=development
FRONTEND_URL=http://localhost:3000
```

```bash
# Generate Prisma client
npx prisma generate

# Run database migrations
npx prisma migrate dev --name init

# Seed the database (creates admin user + sample data)
npm run db:seed

# Start development server
npm run dev
```

The backend API will run on **http://localhost:5000**

---

### 2. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Create environment file
cp .env.local.example .env.local
```

`.env.local` contents:
```env
NEXT_PUBLIC_API_URL=http://localhost:5000/api
```

```bash
# Start development server
npm run dev
```

The frontend will run on **http://localhost:3000**

---

## Production Deployment

### 1. Database migration to Neon

The backend uses Prisma with PostgreSQL, so no schema provider change is required for Neon. The production `DATABASE_URL` uses Neon SSL and the Neon pooler. `DIRECT_URL` is not used.

From `backend/`, install dependencies and verify the connection:

```bash
npm install
npx prisma generate
npx prisma migrate deploy
```

Run `npm run db:seed` only when the production database should receive the initial seed data. Never commit `backend/.env`; store the connection string in the hosting provider's environment variables.

### 2. Frontend deployment on Vercel

1. In Vercel, choose **Add New Project**, import the GitHub repository, and select `frontend` as the root directory.
2. Set the production environment variable `NEXT_PUBLIC_API_URL` to `https://<render-service>.onrender.com/api`.
3. Use `npm run build` as the build command. The output directory is `.next` and should be left as Vercel's default for Next.js.
4. Use Node.js 20.x or newer. Redeploy after changing environment variables.

The Vercel project does not need `DATABASE_URL`, `JWT_SECRET`, or `PORT`.

### 3. Backend deployment on Render

1. Create **New > Web Service** in Render and connect the GitHub repository.
2. Set the root directory to `backend`.
3. Use Node.js 20.x or newer, `npm install && npm run build` as the build command, and `npm start` as the start command.
4. The build script runs `prisma migrate deploy`, `prisma generate`, and TypeScript compilation before `npm start` launches the compiled server.
5. Add the backend environment variables listed below. Render provides `PORT` automatically; leave it unset unless you have a specific reason to set it to Render's assigned port.
6. Deploy and verify `https://<render-service>.onrender.com/api/health` returns a successful health response.

Set `FRONTEND_URL` to the exact Vercel origin, such as `https://ftvti-self-test.vercel.app`, without a trailing slash. The Express CORS configuration uses this value and enables credentials for the JWT cookie. If a custom Vercel domain is used, update `FRONTEND_URL` to that domain.

### 4. Environment variables checklist

Vercel (`frontend`):

```env
NEXT_PUBLIC_API_URL=https://<render-service>.onrender.com/api
```

Render (`backend`):

```env
DATABASE_URL=postgresql://neondb_owner:<password>@<neon-host>/neondb?sslmode=require&channel_binding=require
JWT_SECRET=<long-random-production-secret>
FRONTEND_URL=https://<vercel-project>.vercel.app
NODE_ENV=production
# Optional locally; Render supplies PORT automatically
PORT=10000
```

Keep the full Neon connection string in `DATABASE_URL`, including `sslmode=require`. Do not add the old Supabase `DIRECT_URL`. Prisma Client is generated automatically during Render's `npm run build`; it can also be generated manually with `npx prisma generate` when troubleshooting.

---

## 🔐 Default Credentials

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Exam Password | — | `exam2024` |

> ⚠️ Change these in production! Update via Admin → Exam Settings and your database.

---

## 📱 Features

### Admin Panel (`/admin`)
- **Dashboard** — Stats overview: students, questions, exam attempts, average scores
- **Students** — Add students (creates user account + student profile), view all, delete
- **Questions** — Add MCQ questions (4 options + correct answer), view question bank, delete
- **Events** — Create/view/delete events and announcements for students
- **Results** — View all student exam attempts with scores, pass/fail status, duration
- **Feedback** — Read and moderate student feedback comments
- **Exam Settings** — Configure exam access password and exam duration (minutes)

### Student Portal (`/student`)
- **Dashboard** — Welcome page with student profile info and quick navigation
- **Take Exam** — Enter exam password → timed exam with question navigator → instant results with answer review
- **My Results** — History of all past exam attempts with scores and pass/fail status
- **Events** — View upcoming and past events/announcements
- **Feedback** — Submit feedback to the administration

### Exam Flow
1. Student navigates to **Take Exam**
2. Enters **exam password** (obtained from admin)
3. Timer starts (configurable, default 60 minutes)
4. MCQ questions displayed with A/B/C/D options and a visual question navigator
5. On submit (or when time expires): **automatic scoring**
6. Instant result display with percentage, pass/fail, and **detailed answer review** showing correct answers

---

## 🔌 API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Login with username + password |
| POST | `/api/auth/logout` | Clear session cookie |
| GET | `/api/auth/me` | Get current authenticated user |

### Admin (requires ADMIN role)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/stats` | Dashboard statistics |
| GET | `/api/admin/departments` | List all departments |
| GET/POST | `/api/admin/students` | List / create students |
| DELETE | `/api/admin/students/:id` | Delete a student |
| GET/POST | `/api/admin/questions` | List / create questions |
| DELETE | `/api/admin/questions/:id` | Delete a question |
| GET/POST | `/api/admin/events` | List / create events |
| DELETE | `/api/admin/events/:id` | Delete an event |
| GET/PUT | `/api/admin/exam-config` | Get / update exam config |
| GET | `/api/admin/results` | All exam attempts |
| GET | `/api/admin/comments` | All student feedback |
| DELETE | `/api/admin/comments/:id` | Delete a comment |

### Student (requires STUDENT role)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/student/profile` | Own student profile |
| GET | `/api/student/results` | Own exam attempts |
| GET | `/api/student/events` | All events |
| POST | `/api/student/feedback` | Submit feedback |

### Exam (requires STUDENT role)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/exam/verify-password` | Verify password → get questions (no answers) |
| POST | `/api/exam/submit` | Submit answers → get score + detailed results |
| GET | `/api/exam/attempt/:id` | Get specific attempt |

---

## 🗄 Database Schema

Key models: `User`, `Student`, `Department`, `Question`, `ExamAttempt`, `ExamConfig`, `Event`, `Comment`

See `backend/prisma/schema.prisma` for the full schema.

---

## 🏗 Production Deployment

### Backend
```bash
npm run build
NODE_ENV=production node dist/index.js
```

### Frontend
```bash
npm run build
npm start
```

### Environment Variables (Production)
- Set `NODE_ENV=production`
- Use a strong random `JWT_SECRET` (32+ characters)
- Use a managed PostgreSQL instance
- Set `FRONTEND_URL` to your actual frontend domain
- Configure HTTPS (cookies use `secure: true` in production)

---

## 🧑‍💻 Adding Departments

Departments are seeded automatically. To add more:

```bash
# Via Prisma Studio
npm run db:studio

# Or via SQL
INSERT INTO "Department" (id, name) VALUES (gen_random_uuid(), 'Your Department Name');
```

---

## 📝 License

This project is developed for Grade 12 Entrance Exam preparation. All rights reserved.
