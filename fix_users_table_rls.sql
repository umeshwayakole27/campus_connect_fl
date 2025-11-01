-- ============================================================================
-- FIX USERS TABLE RLS - Allow reading all user IDs
-- ============================================================================
-- This fixes the issue where faculty can't fetch all user IDs
-- for broadcasting notifications
-- ============================================================================

-- Step 1: Check current RLS status on users table
SELECT 'CURRENT RLS STATUS ON USERS TABLE:' as info;
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'users';

-- Step 2: Check current policies on users table
SELECT 'CURRENT POLICIES ON USERS TABLE:' as info;
SELECT 
  policyname,
  cmd,
  CASE WHEN qual IS NOT NULL THEN LEFT(qual, 150) ELSE 'N/A' END as using_expression,
  CASE WHEN with_check IS NOT NULL THEN LEFT(with_check, 150) ELSE 'N/A' END as with_check_expression
FROM pg_policies
WHERE tablename = 'users'
ORDER BY cmd, policyname;

-- Step 3: Add policy to allow authenticated users to read user IDs
-- This is needed for broadcast notifications

-- Drop existing select policy if it's too restrictive
DROP POLICY IF EXISTS "Users can view all user profiles" ON users;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON users;

-- Create new policy that allows authenticated users to SELECT from users table
-- This is safe because we're only allowing SELECT (read), not INSERT/UPDATE/DELETE
CREATE POLICY "Enable read access for authenticated users"
  ON users
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Step 4: Verify the new policy
SELECT 'NEW POLICY CREATED:' as info;
SELECT 
  policyname,
  cmd,
  CASE WHEN qual IS NOT NULL THEN LEFT(qual, 150) ELSE 'N/A' END as using_expression
FROM pg_policies
WHERE tablename = 'users' AND policyname = 'Enable read access for authenticated users';

-- Step 5: Test if we can now select user IDs
SELECT 'TEST QUERY - Fetching user IDs:' as info;
SELECT id, email, role FROM users LIMIT 5;

-- ============================================================================
-- EXPLANATION:
-- ============================================================================
-- The broadcast function does: SELECT id FROM users
-- If RLS on users table doesn't allow this, the query returns 0 rows
-- Faculty then creates notifications only for themselves
-- 
-- This policy allows ANY authenticated user to read from users table
-- This is safe because:
-- 1. Only SELECT is allowed (no modifications)
-- 2. Users are already authenticated via Supabase Auth
-- 3. We're not exposing sensitive data beyond what's already accessible
-- ============================================================================
