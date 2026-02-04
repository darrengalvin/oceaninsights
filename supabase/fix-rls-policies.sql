-- ============================================================
-- FIX RLS POLICIES FOR ADMIN CONTENT TABLES
-- Run this after app-content-schema.sql
-- ============================================================

-- Drop existing restrictive policies and create permissive ones
-- This allows the admin panel to write to content tables

DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN 
        SELECT unnest(ARRAY[
            'mission_objectives', 'objective_categories',
            'mood_reasons', 'mood_responses',
            'daily_brief_energy_levels', 'daily_brief_objectives', 'daily_brief_challenges',
            'aar_went_well_options', 'aar_improve_options', 'aar_takeaway_options',
            'military_roles', 'civilian_jobs', 'role_job_mappings',
            'feelings', 'coping_tools',
            'quizzes', 'quiz_questions', 'quiz_options', 'quiz_results',
            'career_paths',
            'tip_categories', 'tips',
            'checklist_templates', 'checklist_sections', 'checklist_items',
            'resource_categories', 'resource_sections', 'resources',
            'learning_styles', 'study_strategies',
            'affirmations', 'confidence_challenges', 'confidence_actions',
            'interest_categories', 'interest_activities'
        ])
    LOOP
        -- Check if table exists before modifying
        IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = t) THEN
            -- Drop existing policies
            EXECUTE format('DROP POLICY IF EXISTS "Public read access" ON %I', t);
            EXECUTE format('DROP POLICY IF EXISTS "Authenticated write access" ON %I', t);
            EXECUTE format('DROP POLICY IF EXISTS "Allow all operations" ON %I', t);
            
            -- Create permissive policy for all operations
            EXECUTE format('CREATE POLICY "Allow all operations" ON %I FOR ALL USING (true) WITH CHECK (true)', t);
            
            RAISE NOTICE 'Fixed RLS for table: %', t;
        ELSE
            RAISE NOTICE 'Table does not exist (skipping): %', t;
        END IF;
    END LOOP;
END $$;

-- Verify RLS is enabled but permissive
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('aar_went_well_options', 'mood_reasons', 'mission_objectives')
ORDER BY tablename;
