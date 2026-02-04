-- Mission Objectives Schema
-- Allows admin to manage objectives for Mission Planner

-- Create mission objective types enum
CREATE TYPE mission_objective_type AS ENUM ('primary', 'secondary', 'contingency');

-- Create mission objectives table
CREATE TABLE IF NOT EXISTS mission_objectives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    category TEXT NOT NULL,
    objective_type mission_objective_type NOT NULL,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    user_types TEXT[] DEFAULT ARRAY['all'], -- 'all', 'military', 'veteran', 'youth'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_mission_objectives_type ON mission_objectives(objective_type);
CREATE INDEX idx_mission_objectives_active ON mission_objectives(is_active);
CREATE INDEX idx_mission_objectives_sort ON mission_objectives(sort_order);

-- Enable RLS
ALTER TABLE mission_objectives ENABLE ROW LEVEL SECURITY;

-- Public read access for active objectives
CREATE POLICY "Anyone can read active objectives" ON mission_objectives
    FOR SELECT USING (is_active = true);

-- Admin write access (requires auth)
CREATE POLICY "Authenticated users can manage objectives" ON mission_objectives
    FOR ALL USING (auth.role() = 'authenticated');

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_mission_objectives_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER mission_objectives_updated_at
    BEFORE UPDATE ON mission_objectives
    FOR EACH ROW
    EXECUTE FUNCTION update_mission_objectives_updated_at();

-- Insert default objectives

-- PRIMARY OBJECTIVES
INSERT INTO mission_objectives (text, category, objective_type, sort_order) VALUES
('Complete my main work task', 'Work', 'primary', 1),
('Have an important conversation', 'Communication', 'primary', 2),
('Make a key decision', 'Leadership', 'primary', 3),
('Finish a project milestone', 'Work', 'primary', 4),
('Attend a critical meeting', 'Work', 'primary', 5),
('Solve a pressing problem', 'Problem Solving', 'primary', 6),
('Submit something important', 'Work', 'primary', 7),
('Lead a team activity', 'Leadership', 'primary', 8),
('Complete a training session', 'Development', 'primary', 9),
('Review and approve work', 'Leadership', 'primary', 10),
('Mentor or coach someone', 'Leadership', 'primary', 11),
('Handle a difficult situation', 'Problem Solving', 'primary', 12),
('Prepare for tomorrow', 'Planning', 'primary', 13),
('Clear my inbox/backlog', 'Admin', 'primary', 14),
('Focus on deep work', 'Focus', 'primary', 15),
('Exercise or physical training', 'Health', 'primary', 16),
('Connect with family', 'Personal', 'primary', 17),
('Learn something new', 'Development', 'primary', 18),
('Fix something that''s broken', 'Problem Solving', 'primary', 19),
('Start a new initiative', 'Leadership', 'primary', 20);

-- SECONDARY OBJECTIVES
INSERT INTO mission_objectives (text, category, objective_type, sort_order) VALUES
('Make progress on secondary task', 'Work', 'secondary', 1),
('Prepare for tomorrow', 'Planning', 'secondary', 2),
('Follow up on pending items', 'Admin', 'secondary', 3),
('Clear admin backlog', 'Admin', 'secondary', 4),
('Connect with a colleague', 'Communication', 'secondary', 5),
('Review and plan ahead', 'Planning', 'secondary', 6),
('Handle routine tasks', 'Admin', 'secondary', 7),
('Document or organize', 'Admin', 'secondary', 8),
('Send pending messages', 'Communication', 'secondary', 9),
('Update tracking/logs', 'Admin', 'secondary', 10),
('Research or gather information', 'Planning', 'secondary', 11),
('Clean or organize workspace', 'Environment', 'secondary', 12),
('Review feedback received', 'Development', 'secondary', 13),
('Check in with team members', 'Leadership', 'secondary', 14),
('Catch up on reading/updates', 'Development', 'secondary', 15);

-- CONTINGENCY OBJECTIVES
INSERT INTO mission_objectives (text, category, objective_type, sort_order) VALUES
('At minimum, stay present', 'Mindset', 'contingency', 1),
('Focus on self-care', 'Health', 'contingency', 2),
('Just get through the day', 'Mindset', 'contingency', 3),
('Do one small helpful thing', 'Mindset', 'contingency', 4),
('Rest and recover', 'Health', 'contingency', 5),
('Maintain basic routines', 'Health', 'contingency', 6),
('Stay calm and observant', 'Mindset', 'contingency', 7),
('Protect my energy', 'Mindset', 'contingency', 8),
('Be kind to myself', 'Mindset', 'contingency', 9),
('Ask for help if needed', 'Communication', 'contingency', 10),
('Take things one step at a time', 'Mindset', 'contingency', 11),
('Avoid making things worse', 'Mindset', 'contingency', 12);

-- Objective categories table for admin management
CREATE TABLE IF NOT EXISTS objective_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    color TEXT DEFAULT '#00D9C4',
    icon TEXT DEFAULT 'circle',
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default categories
INSERT INTO objective_categories (name, color, sort_order) VALUES
('Work', '#3B82F6', 1),
('Leadership', '#8B5CF6', 2),
('Communication', '#10B981', 3),
('Problem Solving', '#F59E0B', 4),
('Planning', '#6366F1', 5),
('Admin', '#64748B', 6),
('Development', '#EC4899', 7),
('Health', '#22C55E', 8),
('Personal', '#F43F5E', 9),
('Mindset', '#0EA5E9', 10),
('Focus', '#A855F7', 11),
('Environment', '#14B8A6', 12);

-- Enable RLS on categories
ALTER TABLE objective_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read categories" ON objective_categories
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can manage categories" ON objective_categories
    FOR ALL USING (auth.role() = 'authenticated');
