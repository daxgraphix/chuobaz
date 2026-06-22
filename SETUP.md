# ChuoBaz – Setup Guide

## 1. Supabase Project

1. Create a free project at https://supabase.com
2. In **SQL Editor → New Query**, run:
   - `supabase/schema.sql`       ← Tables, triggers, views, functions
   - `supabase/rls_policies.sql` ← Row Level Security
   - `supabase/seed_communities.sql` ← Sample communities & courses
3. Go to **Project Settings → API** and copy your:
   - Project URL (e.g. `https://abcdefgh.supabase.co`)
   - Anon/public key

## 2. Configure the App

Open `lib/core/config/app_config.dart` and replace the placeholder values:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

## 3. Supabase Storage Buckets

Create these four buckets in **Supabase Dashboard → Storage → New bucket**:

| Bucket name        | Public |
|--------------------|--------|
| `avatars`          | ✅ Yes  |
| `post-media`       | ✅ Yes  |
| `marketplace-media`| ✅ Yes  |
| `academic-resources`| ✅ Yes |

## 4. Authentication Providers (optional)

- **Google**: Supabase Dashboard → Authentication → Providers → Google
- **Apple**: Requires Apple Developer account + Sign in with Apple capability in Xcode

## 5. Firebase Cloud Messaging (push notifications)

1. Create a Firebase project at https://console.firebase.google.com
2. Download `google-services.json` → place in `android/app/`
3. Download `GoogleService-Info.plist` → place in `ios/Runner/`

## 6. Run the App

```bash
flutter pub get
flutter run
```

That's it. No `build_runner`, no code generation — just `pub get` + `run`.

---

## Architecture Overview

```
lib/
├── core/
│   ├── config/       ← Supabase config + app constants
│   ├── constants/    ← UserRole, PostType, ListingCategory enums
│   ├── database/     ← LocalCache (Hive, no build_runner)
│   ├── network/      ← Supabase client providers, connectivity
│   ├── router/       ← GoRouter + StatefulShellRoute (5 tabs)
│   ├── theme/        ← Light/dark themes, colors, text styles
│   ├── errors/       ← Failure classes + exceptions
│   ├── usecase/      ← Abstract UseCase base
│   ├── utils/        ← Validators, date formatter, alias generator
│   └── widgets/      ← Shared: Avatar, RoleBadge, PostCard, etc.
│
└── features/         ← 15 modules, each with:
    │                    data/ domain/ presentation/
    ├── auth/
    ├── profile/
    ├── feed/
    ├── communities/
    ├── posts/
    ├── comments/
    ├── anonymous/
    ├── notifications/
    ├── marketplace/
    ├── academic/
    ├── search/
    ├── moderation/
    ├── messaging/
    ├── analytics/
    ├── settings/
    └── admin/
```

## Anonymous Posting Privacy

Aliases (e.g. `Engineering_57`) are:
- Generated per **user + community** pair and stored in `anonymous_profiles`
- Consistent within a community (same user always gets the same alias per community)
- **Moderators cannot see** who is behind an alias (RLS enforces this)
- Only **Super Admins** can access the `anonymous_profiles` table for audit purposes

## Role System

| Role        | Description                              |
|-------------|------------------------------------------|
| super_admin | Full platform access + audit logs        |
| moderator   | Hide/lock/pin posts, review reports      |
| lecturer    | Verified expert badge + resource upload  |
| student     | Verified student + academic communities  |
| alumni      | Mentorship + career opportunity access   |
| member      | Standard authenticated user              |

