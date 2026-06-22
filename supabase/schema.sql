-- ============================================================
-- ChuoBaz – Full PostgreSQL Schema for Supabase
-- Version 1.0
--
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";   -- powers fast ILIKE search


-- ============================================================
-- 1. USERS (mirrors auth.users, populated by trigger)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.users (
  id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email           TEXT NOT NULL,
  username        TEXT UNIQUE NOT NULL,
  display_name    TEXT,
  avatar_url      TEXT,
  bio             TEXT,
  university      TEXT,
  faculty         TEXT,
  department      TEXT,
  academic_level  TEXT,
  phone           TEXT,
  role            TEXT NOT NULL DEFAULT 'member'
                    CHECK (role IN ('super_admin','moderator','member','student','lecturer','alumni')),
  is_verified     BOOLEAN NOT NULL DEFAULT FALSE,
  is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  muted_until     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger: auto-create row in public.users on auth.users INSERT
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.users (id, email, username)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email,'@',1))
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ============================================================
-- 2. COMMUNITIES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.communities (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL,
  description   TEXT,
  level         TEXT NOT NULL DEFAULT 'interest_group'
                  CHECK (level IN ('university','faculty','department','interest_group')),
  avatar_url    TEXT,
  cover_url     TEXT,
  member_count  INTEGER NOT NULL DEFAULT 0,
  created_by    UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.community_members (
  community_id  UUID NOT NULL REFERENCES public.communities(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  joined_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (community_id, user_id)
);

-- Keep member_count denormalised for O(1) reads
CREATE OR REPLACE FUNCTION public.update_community_member_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.communities SET member_count = member_count + 1 WHERE id = NEW.community_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.communities SET member_count = GREATEST(member_count - 1, 0) WHERE id = OLD.community_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_community_member_count ON public.community_members;
CREATE TRIGGER trg_community_member_count
  AFTER INSERT OR DELETE ON public.community_members
  FOR EACH ROW EXECUTE FUNCTION public.update_community_member_count();


-- ============================================================
-- 3. POSTS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.posts (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  community_id    UUID REFERENCES public.communities(id) ON DELETE SET NULL,
  title           TEXT NOT NULL,
  body            TEXT NOT NULL,
  type            TEXT NOT NULL DEFAULT 'discussion'
                    CHECK (type IN ('discussion','question','poll','marketplace')),
  tags            TEXT[] NOT NULL DEFAULT '{}',
  is_anonymous    BOOLEAN NOT NULL DEFAULT FALSE,
  anonymous_alias TEXT,
  is_pinned       BOOLEAN NOT NULL DEFAULT FALSE,
  is_locked       BOOLEAN NOT NULL DEFAULT FALSE,
  is_hidden       BOOLEAN NOT NULL DEFAULT FALSE,
  comment_count   INTEGER NOT NULL DEFAULT 0,
  reaction_counts JSONB NOT NULL DEFAULT '{}',
  media_urls      TEXT[] NOT NULL DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- GIN index for tags array overlap queries
CREATE INDEX IF NOT EXISTS idx_posts_tags ON public.posts USING GIN (tags);
-- Trigram index for fast ILIKE title search
CREATE INDEX IF NOT EXISTS idx_posts_title_trgm ON public.posts USING GIN (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_posts_community ON public.posts (community_id);
CREATE INDEX IF NOT EXISTS idx_posts_author ON public.posts (author_id);
CREATE INDEX IF NOT EXISTS idx_posts_created ON public.posts (created_at DESC);

-- saved_posts pivot table
CREATE TABLE IF NOT EXISTS public.saved_posts (
  post_id    UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (post_id, user_id)
);


-- ============================================================
-- 4. COMMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.comments (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id         UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  author_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  parent_id       UUID REFERENCES public.comments(id) ON DELETE CASCADE,
  body            TEXT NOT NULL,
  is_anonymous    BOOLEAN NOT NULL DEFAULT FALSE,
  anonymous_alias TEXT,
  is_hidden       BOOLEAN NOT NULL DEFAULT FALSE,
  reaction_counts JSONB NOT NULL DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_comments_post ON public.comments (post_id);

-- Keep comment_count on posts denormalised
CREATE OR REPLACE FUNCTION public.update_post_comment_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.posts SET comment_count = comment_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.posts SET comment_count = GREATEST(comment_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_post_comment_count ON public.comments;
CREATE TRIGGER trg_post_comment_count
  AFTER INSERT OR DELETE ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.update_post_comment_count();


-- ============================================================
-- 5. REACTIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.reactions (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  target_id   UUID NOT NULL,
  target_type TEXT NOT NULL CHECK (target_type IN ('post','comment')),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type        TEXT NOT NULL CHECK (type IN ('like','love','helpful','interesting','insightful')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (target_id, target_type, user_id)
);

CREATE INDEX IF NOT EXISTS idx_reactions_target ON public.reactions (target_id, target_type);

-- Update reaction_counts JSONB on posts/comments after upsert/delete
CREATE OR REPLACE FUNCTION public.sync_reaction_counts()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_counts JSONB;
  v_id     UUID;
BEGIN
  v_id := COALESCE(NEW.target_id, OLD.target_id);
  SELECT COALESCE(
    jsonb_object_agg(type, cnt),
    '{}'::JSONB
  ) INTO v_counts
  FROM (
    SELECT type, COUNT(*) AS cnt
    FROM public.reactions
    WHERE target_id = v_id
      AND target_type = COALESCE(NEW.target_type, OLD.target_type)
    GROUP BY type
  ) sub;

  IF COALESCE(NEW.target_type, OLD.target_type) = 'post' THEN
    UPDATE public.posts SET reaction_counts = v_counts WHERE id = v_id;
  ELSE
    UPDATE public.comments SET reaction_counts = v_counts WHERE id = v_id;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_reaction_counts ON public.reactions;
CREATE TRIGGER trg_sync_reaction_counts
  AFTER INSERT OR UPDATE OR DELETE ON public.reactions
  FOR EACH ROW EXECUTE FUNCTION public.sync_reaction_counts();


-- ============================================================
-- 6. ANONYMOUS PROFILES
-- (per-user per-community alias — never exposed to moderators via RLS)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.anonymous_profiles (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE,
  alias        TEXT NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, community_id)
);


-- ============================================================
-- 7. NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type        TEXT NOT NULL CHECK (type IN ('comment','mention','reaction','moderatorAction','marketplace','message')),
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  target_id   UUID,
  target_type TEXT,
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications (user_id, is_read, created_at DESC);


-- ============================================================
-- 8. MARKETPLACE LISTINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.marketplace_listings (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  seller_id   UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  description TEXT NOT NULL,
  price       NUMERIC(12,2) NOT NULL DEFAULT 0,
  category    TEXT NOT NULL DEFAULT 'services'
                CHECK (category IN ('books','hostels','apartments','electronics','tutoring','services')),
  image_urls  TEXT[] NOT NULL DEFAULT '{}',
  location    TEXT,
  is_sold     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_listings_category ON public.marketplace_listings (category);
CREATE INDEX IF NOT EXISTS idx_listings_title_trgm ON public.marketplace_listings USING GIN (title gin_trgm_ops);


-- ============================================================
-- 9. COURSES & ACADEMIC RESOURCES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.courses (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code        TEXT UNIQUE NOT NULL,
  name        TEXT NOT NULL,
  university  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.resources (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uploader_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title          TEXT NOT NULL,
  course_code    TEXT NOT NULL,
  type           TEXT NOT NULL DEFAULT 'study_note'
                   CHECK (type IN ('past_paper','study_note','course_resource','question_bank')),
  description    TEXT,
  file_url       TEXT NOT NULL,
  download_count INTEGER NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_resources_course ON public.resources (course_code);
CREATE INDEX IF NOT EXISTS idx_resources_title_trgm ON public.resources USING GIN (title gin_trgm_ops);

-- RPC to safely increment download_count
CREATE OR REPLACE FUNCTION public.increment_resource_downloads(resource_id UUID)
RETURNS VOID LANGUAGE SQL SECURITY DEFINER AS $$
  UPDATE public.resources SET download_count = download_count + 1 WHERE id = resource_id;
$$;


-- ============================================================
-- 10. MESSAGING
-- ============================================================
CREATE TABLE IF NOT EXISTS public.conversations (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  participant_ids  UUID[] NOT NULL,
  last_message     TEXT,
  last_message_at  TIMESTAMPTZ,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_conversations_participants ON public.conversations USING GIN (participant_ids);

CREATE TABLE IF NOT EXISTS public.messages (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  body            TEXT NOT NULL,
  is_read         BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages (conversation_id, created_at);

-- View that resolves "other user" for each conversation per the calling user.
-- The app queries this as `conversations_with_meta`.
CREATE OR REPLACE VIEW public.conversations_with_meta AS
SELECT
  c.*,
  (
    SELECT jsonb_build_object('id', u.id, 'username', u.username, 'avatar_url', u.avatar_url)
    FROM public.users u
    WHERE u.id = ANY(c.participant_ids)
      AND u.id != auth.uid()
    LIMIT 1
  ) AS other_user,
  EXISTS(
    SELECT 1 FROM public.messages m
    WHERE m.conversation_id = c.id
      AND m.sender_id != auth.uid()
      AND m.is_read = FALSE
  ) AS has_unread
FROM public.conversations c
WHERE auth.uid() = ANY(c.participant_ids);

-- RPC: get existing conversation between two users or create a new one
CREATE OR REPLACE FUNCTION public.get_or_create_conversation(user_a UUID, user_b UUID)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_id UUID;
BEGIN
  SELECT id INTO v_id
  FROM public.conversations
  WHERE participant_ids @> ARRAY[user_a, user_b]
    AND participant_ids <@ ARRAY[user_a, user_b]
  LIMIT 1;

  IF v_id IS NULL THEN
    INSERT INTO public.conversations (participant_ids)
    VALUES (ARRAY[user_a, user_b])
    RETURNING id INTO v_id;
  END IF;
  RETURN v_id;
END;
$$;


-- ============================================================
-- 11. MODERATION
-- ============================================================
CREATE TABLE IF NOT EXISTS public.reports (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  target_id   UUID NOT NULL,
  target_type TEXT NOT NULL CHECK (target_type IN ('post','comment','listing','user')),
  reason      TEXT NOT NULL,
  details     TEXT,
  status      TEXT NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending','reviewed','actioned','dismissed')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.moderators (
  user_id    UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  granted_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.audit_logs (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id    UUID REFERENCES public.users(id) ON DELETE SET NULL,
  action      TEXT NOT NULL,
  target_id   UUID,
  target_type TEXT,
  reason      TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 12. ANALYTICS RPC
-- Returns DAU / MAU / retention for the admin dashboard.
-- Extend with your preferred time-window logic.
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_platform_metrics()
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_dau     INTEGER;
  v_mau     INTEGER;
  v_result  JSONB;
BEGIN
  SELECT COUNT(DISTINCT author_id) INTO v_dau
  FROM public.posts
  WHERE created_at >= NOW() - INTERVAL '1 day';

  SELECT COUNT(DISTINCT author_id) INTO v_mau
  FROM public.posts
  WHERE created_at >= NOW() - INTERVAL '30 days';

  SELECT jsonb_build_object(
    'dau', v_dau,
    'mau', v_mau,
    'retention_rate', CASE WHEN v_mau = 0 THEN 0 ELSE ROUND(v_dau::NUMERIC / v_mau, 2) END,
    'growth_series', (
      SELECT COALESCE(jsonb_agg(r ORDER BY r->>'date'), '[]'::jsonb)
      FROM (
        SELECT jsonb_build_object('date', DATE(created_at)::TEXT, 'count', COUNT(DISTINCT author_id)) AS r
        FROM public.posts
        WHERE created_at >= NOW() - INTERVAL '30 days'
        GROUP BY DATE(created_at)
        ORDER BY DATE(created_at)
      ) sub
    )
  ) INTO v_result;
  RETURN v_result;
END;
$$;

