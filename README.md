<p align="center">
  <img src="assets/images/logo_full.png" width="460" alt="Age Calculator App - Track your journey" style="border-radius: 18px;"/>
</p>

# Age Calculator (Flutter + Supabase)

Track your journey with **Age Calculator** — a premium, modern Flutter application that calculates exact age metrics down to the minute, displays astrological zodiac signs, tracks upcoming birthdays, and syncs calculations in real-time with **Supabase**.

---

## ✨ Features

- **Precise Age Calculation**: Computes exact years, months, days, total days, hours, and minutes lived.
- **Astrological Zodiac Card**: Automatically determines your Western Zodiac sign, element, and symbol (including accurate handling for leap years such as `2000-02-29`).
- **Next Birthday Countdown**: Shows days remaining until your next celebration with birthday cake animations.
- **Day of the Week Born**: Displays the exact weekday you arrived in the world.
- **Supabase Authentication**:
  - Secure email/password Sign Up and Sign In.
  - Reactive `AuthGate` that directs users seamlessly between the `LoginScreen` and the main calculator.
  - Logout functionality with instant session cleanup.
- **Supabase Database Cloud Sync**:
  - Future birth date validation (rejects invalid dates).
  - Upsert capability on unique `(user_id, birth_date)`.
  - Offline & network error detection with user-friendly alerts.
  - Dedicated **History Screen** with swipe-to-delete (`Dismissible`), loading indicators, empty states, and error handling.
- **Ergonomic Floating Action Button**:
  - Centered extended FAB (`FloatingActionButtonLocation.centerFloat`) with 90px bottom scroll padding so content is never obstructed.

---

## 🚀 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.12+ / Dart 3.12+)
- A [Supabase](https://supabase.com) project

### 2. Environment Configuration
Copy the sample environment file to create your local environment:

```bash
cp assets/.env.example assets/.env.local
```

Open `assets/.env.local` and add your project details:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-or-publishable-key
```

> **Note**: Both `assets/.env.local` and compile-time flags (`--dart-define=SUPABASE_URL=...`) are supported. The app strictly enforces that these keys exist and will throw a descriptive startup error if they are missing.

---

## 🗄️ Supabase Database Setup

Run the following SQL in your **Supabase Dashboard SQL Editor**:

```sql
-- 1. Create calculations table
CREATE TABLE IF NOT EXISTS public.calculations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid(),
    birth_date DATE NOT NULL,
    years INT NOT NULL,
    months INT NOT NULL,
    days INT NOT NULL,
    total_days BIGINT NOT NULL,
    total_hours BIGINT NOT NULL,
    total_minutes BIGINT NOT NULL,
    day_of_week_born TEXT NOT NULL,
    label TEXT,
    calculated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT user_birth_date_unique UNIQUE (user_id, birth_date)
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.calculations ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies for authenticated users
CREATE POLICY "Users can view their own calculations"
ON public.calculations
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert or upsert their own calculations"
ON public.calculations
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own calculations"
ON public.calculations
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own calculations"
ON public.calculations
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);
```

### Enable Supabase Email Auth
1. Go to **Authentication** > **Providers** > **Email**.
2. Ensure **Email provider** is **Enabled**.
3. (Optional) Turn off *Confirm email* in local/test development for instantaneous sign-in.

---

## 📱 Running the Application

### Run on Web (Chrome):
```bash
flutter run -d chrome
```

### Run on Windows Desktop:
```bash
flutter run -d windows
```

### Run on Mobile (Android / iOS):
```bash
flutter run -d android
# or
flutter run -d ios
```

---

## 🧪 Running Tests

Run the test suite including Zodiac calculation tests and widget tests:

```bash
flutter test
```

Unit tests cover:
- All 12 zodiac signs and date boundaries
- Leap year leap day calculation (`2000-02-29` -> Pisces ♓)
- Age calculations and birthday boundaries
- Authentication and screen widget verification

---

## 📂 Project Architecture

```
lib/
├── main.dart                  # App entry point, theme, AuthGate & AgeCalculatorHome
├── models/
│   └── zodiac.dart            # ZodiacSign model & astrological calculation logic
├── screens/
│   ├── login_screen.dart      # Email/password authentication & state handling
│   └── history_screen.dart    # Cloud calculation history & swipe-to-delete
├── services/
│   ├── auth_service.dart      # Supabase Auth singleton (signIn, signUp, signOut)
│   └── supabase_service.dart  # Supabase Database client (upsert, getHistory, delete)
└── theme/
    └── brand_colors.dart      # Brand color palette, gradients & shadows
tools/
└── make_icon.py               # Generates app_icon.png from logo_full.png
```