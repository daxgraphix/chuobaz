-- ============================================================
-- ChuoBaz – Row Level Security Policies
-- Run AFTER schema.sql in the Supabase SQL Editor
-- ============================================================

-- Helper: is the current user a moderator or super_admin?
CREATE OR REPLACE FUNCTION public.is_moderator()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT role IN ('moderator','super_admin') FROM public.users WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT role = 'super_admin' FROM public.users WHERE id = auth.uid();
$$;

-- ── USERS ────────────────────────────────────────────────────
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users: public read" ON public.users FOR SELECT USING (TRUE);
CREATE POLICY "Users: self update" ON public.users FOR UPDATE USING (auth.uid() = id);

-- ── COMMUNITIES ──────────────────────────────────────────────
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Communities: public read" ON public.communities FOR SELECT USING (TRUE);
CREATE POLICY "Communities: super_admin manage" ON public.communities
  FOR ALL USING (public.is_super_admin());

-- ── COMMUNITY_MEMBERS ────────────────────────────────────────
ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "CommunityMembers: public read" ON public.community_members FOR SELECT USING (TRUE);
CREATE POLICY "CommunityMembers: join self" ON public.community_members
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "CommunityMembers: leave self" ON public.community_members
  FOR DELETE USING (auth.uid() = user_id);

-- ── POSTS ────────────────────────────────────────────────────
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Posts: read visible" ON public.posts FOR SELECT
  USING (is_hidden = FALSE OR public.is_moderator());

CREATE POLICY "Posts: insert authenticated" ON public.posts
  FOR INSERT WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Posts: update own" ON public.posts
  FOR UPDATE USING (auth.uid() = author_id OR public.is_moderator());

CREATE POLICY "Posts: delete own or moderator" ON public.posts
  FOR DELETE USING (auth.uid() = author_id OR public.is_moderator());

-- ── SAVED_POSTS ───────────────────────────────────────────────
ALTER TABLE public.saved_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "SavedPosts: self only" ON public.saved_posts
  FOR ALL USING (auth.uid() = user_id);

-- ── COMMENTS ─────────────────────────────────────────────────
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Comments: read visible" ON public.comments FOR SELECT
  USING (is_hidden = FALSE OR public.is_moderator());

CREATE POLICY "Comments: insert authenticated" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Comments: update own" ON public.comments
  FOR UPDATE USING (auth.uid() = author_id OR public.is_moderator());

CREATE POLICY "Comments: delete own or moderator" ON public.comments
  FOR DELETE USING (auth.uid() = author_id OR public.is_moderator());

-- ── REACTIONS ────────────────────────────────────────────────
ALTER TABLE public.reactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Reactions: public read" ON public.reactions FOR SELECT USING (TRUE);
CREATE POLICY "Reactions: insert authenticated" ON public.reactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Reactions: delete own" ON public.reactions
  FOR DELETE USING (auth.uid() = user_id);

-- ── ANONYMOUS PROFILES ───────────────────────────────────────
-- CRITICAL: Only the owning user + super_admins can read an alias mapping.
-- Moderators CANNOT see who posted anonymously.
ALTER TABLE public.anonymous_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "AnonProfiles: self read/write" ON public.anonymous_profiles
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "AnonProfiles: super_admin audit" ON public.anonymous_profiles
  FOR SELECT USING (public.is_super_admin());

-- ── NOTIFICATIONS ────────────────────────────────────────────
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Notifications: self only" ON public.notifications
  FOR ALL USING (auth.uid() = user_id);

-- ── MARKETPLACE LISTINGS ─────────────────────────────────────
ALTER TABLE public.marketplace_listings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Listings: public read" ON public.marketplace_listings FOR SELECT USING (TRUE);
CREATE POLICY "Listings: insert own" ON public.marketplace_listings
  FOR INSERT WITH CHECK (auth.uid() = seller_id);
CREATE POLICY "Listings: update own or mod" ON public.marketplace_listings
  FOR UPDATE USING (auth.uid() = seller_id OR public.is_moderator());
CREATE POLICY "Listings: delete own or mod" ON public.marketplace_listings
  FOR DELETE USING (auth.uid() = seller_id OR public.is_moderator());

-- ── COURSES ──────────────────────────────────────────────────
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Courses: public read" ON public.courses FOR SELECT USING (TRUE);
CREATE POLICY "Courses: super_admin manage" ON public.courses
  FOR ALL USING (public.is_super_admin());

-- ── RESOURCES ────────────────────────────────────────────────
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Resources: public read" ON public.resources FOR SELECT USING (TRUE);
CREATE POLICY "Resources: insert authenticated" ON public.resources
  FOR INSERT WITH CHECK (auth.uid() = uploader_id);
CREATE POLICY "Resources: delete own or mod" ON public.resources
  FOR DELETE USING (auth.uid() = uploader_id OR public.is_moderator());

-- ── CONVERSATIONS ────────────────────────────────────────────
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Conversations: participants only" ON public.conversations
  FOR ALL USING (auth.uid() = ANY(participant_ids));

-- ── MESSAGES ─────────────────────────────────────────────────
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Messages: participants only" ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = conversation_id AND auth.uid() = ANY(c.participant_ids)
    )
  );

CREATE POLICY "Messages: send as self" ON public.messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- ── REPORTS ──────────────────────────────────────────────────
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Reports: moderator read" ON public.reports
  FOR SELECT USING (public.is_moderator());
CREATE POLICY "Reports: authenticated insert" ON public.reports
  FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "Reports: moderator update" ON public.reports
  FOR UPDATE USING (public.is_moderator());

-- ── MODERATORS ───────────────────────────────────────────────
ALTER TABLE public.moderators ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Moderators: public read" ON public.moderators FOR SELECT USING (TRUE);
CREATE POLICY "Moderators: super_admin manage" ON public.moderators
  FOR ALL USING (public.is_super_admin());

-- ── AUDIT LOGS ────────────────────────────────────────────────
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "AuditLogs: super_admin only" ON public.audit_logs
  FOR ALL USING (public.is_super_admin());

