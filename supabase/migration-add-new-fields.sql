-- Migration: Add new fields to content_details
-- Run this in Supabase SQL Editor

ALTER TABLE content_details
ADD COLUMN IF NOT EXISTS understand_examples TEXT,
ADD COLUMN IF NOT EXISTS grow_obstacles TEXT,
ADD COLUMN IF NOT EXISTS when_to_seek_help TEXT;

-- Add comments for documentation
COMMENT ON COLUMN content_details.understand_examples IS 'Real-world examples to make concepts tangible';
COMMENT ON COLUMN content_details.grow_obstacles IS 'Common obstacles people might face when applying the grow steps';
COMMENT ON COLUMN content_details.when_to_seek_help IS 'Guidance on when professional help is needed (for sensitive items)';

