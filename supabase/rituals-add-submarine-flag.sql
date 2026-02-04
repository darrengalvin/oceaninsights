-- ============================================
-- ADD SUBMARINE-COMPATIBLE FLAG TO TOPICS
-- Shows a submarine icon on topics suitable for deployment
-- ============================================

-- Add the submarine_compatible column
ALTER TABLE ritual_topics 
ADD COLUMN IF NOT EXISTS is_submarine_compatible BOOLEAN DEFAULT false;

-- Mark submarine-compatible topics (can be done during deployment)
-- These are all the mental/internal practices that don't require external resources

-- RELATIONSHIPS (some work)
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'self-love-first';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'healing-heartbreak';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'better-communication';

-- CAREER (most work - preparing for future)
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'career-transition';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'work-life-balance';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'finding-purpose';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'leadership-growth';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'interview-prep';

-- MENTAL WELLNESS (all work!)
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'anxiety-management';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'stress-relief';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'building-resilience';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'confidence-building';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'overthinking-control';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'depression-support';

-- HEALTH & HABITS (some work)
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'better-sleep';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'breaking-bad-habits';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'energy-boost';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'fitness-start'; -- Can do bodyweight exercises

-- LIFE TRANSITIONS (some work)
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'post-breakup';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'major-change';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'grief-loss';

-- GROWTH & MINDFULNESS (all work!)
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'gratitude-practice';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'present-moment';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'saying-no';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'financial-wellness';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'letting-go';
UPDATE ritual_topics SET is_submarine_compatible = true WHERE slug = 'daily-meditation';

-- SOCIAL CONNECTION (limited)
-- Most social topics need external interaction, so left as false

-- Re-publish any topics we might have unpublished earlier
UPDATE ritual_topics SET is_published = true WHERE is_published = false;

-- Verify the results:
-- SELECT name, is_submarine_compatible FROM ritual_topics ORDER BY is_submarine_compatible DESC, name;
