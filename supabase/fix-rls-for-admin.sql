-- Fix RLS policies for admin panel access
-- The admin panel uses the service role key, which should bypass RLS
-- But if RLS is enabled, we need policies

-- Disable RLS for these tables (since admin panel uses service role)
ALTER TABLE scenarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE scenario_options DISABLE ROW LEVEL SECURITY;
ALTER TABLE protocols DISABLE ROW LEVEL SECURITY;
ALTER TABLE content_packs DISABLE ROW LEVEL SECURITY;
ALTER TABLE perspective_shifts DISABLE ROW LEVEL SECURITY;
ALTER TABLE journeys DISABLE ROW LEVEL SECURITY;
ALTER TABLE domains DISABLE ROW LEVEL SECURITY;
ALTER TABLE content_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE navigate_content DISABLE ROW LEVEL SECURITY;

-- Alternatively, if you want to keep RLS enabled but allow service role:
-- (Uncomment these if you prefer to keep RLS on)

/*
-- Enable RLS
ALTER TABLE scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE scenario_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE protocols ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_packs ENABLE ROW LEVEL SECURITY;
ALTER TABLE perspective_shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE journeys ENABLE ROW LEVEL SECURITY;
ALTER TABLE domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE navigate_content ENABLE ROW LEVEL SECURITY;

-- Create policies that allow all operations (since these are admin-only tables)
CREATE POLICY "Allow all on scenarios" ON scenarios FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on scenario_options" ON scenario_options FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on protocols" ON protocols FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on content_packs" ON content_packs FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on perspective_shifts" ON perspective_shifts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on journeys" ON journeys FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on domains" ON domains FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on content_items" ON content_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on navigate_content" ON navigate_content FOR ALL USING (true) WITH CHECK (true);
*/

