-- ============================================================
-- ChuoBaz – Sample Seed Data
-- Run AFTER schema.sql + rls_policies.sql
-- This seeds example communities so the app shows content
-- immediately after you first sign in.
-- ============================================================

INSERT INTO public.communities (name, description, level) VALUES
  ('University of Dar es Salaam', 'Official UDSM student community', 'university'),
  ('Ardhi University', 'ARU campus community', 'university'),
  ('Muhimbili University', 'MUHAS campus community', 'university'),
  ('Faculty of Engineering (UDSM)', 'All engineering students at UDSM', 'faculty'),
  ('Faculty of Law (UDSM)', 'Law students and discussions', 'faculty'),
  ('Faculty of Science (UDSM)', 'Science faculty hub', 'faculty'),
  ('Computer Science Dept', 'CS students, projects & discussions', 'department'),
  ('BBA Department', 'Business Administration students', 'department'),
  ('Medical Students Forum', 'Pre-med and med students', 'department'),
  ('Campus Memes & Fun 🔥', 'Campus humor, memes & viral content', 'interest_group'),
  ('Student Entrepreneurs', 'Startups, hustles, business ideas', 'interest_group'),
  ('Sports & Fitness', 'Campus sports teams and fitness', 'interest_group'),
  ('Tech Talk Africa', 'Software, hardware, AI discussions', 'interest_group'),
  ('Career & Internships', 'Job listings, CV tips, internships', 'interest_group'),
  ('Campus Housing & Hostels', 'Find rooms, share costs, housing tips', 'interest_group')
ON CONFLICT DO NOTHING;

-- Seed popular courses
INSERT INTO public.courses (code, name) VALUES
  ('CS101', 'Introduction to Computer Science'),
  ('CS102', 'Data Structures & Algorithms'),
  ('CS201', 'Database Systems'),
  ('CS301', 'Software Engineering'),
  ('CS302', 'Computer Networks'),
  ('CS401', 'Artificial Intelligence'),
  ('LAW101', 'Introduction to Law'),
  ('LAW201', 'Constitutional Law'),
  ('LAW301', 'Criminal Law'),
  ('BBA101', 'Principles of Management'),
  ('BBA211', 'Financial Accounting'),
  ('BBA301', 'Marketing Management'),
  ('MED101', 'Human Anatomy'),
  ('MED201', 'Physiology'),
  ('ENG101', 'Engineering Mathematics'),
  ('ENG201', 'Thermodynamics')
ON CONFLICT (code) DO NOTHING;

