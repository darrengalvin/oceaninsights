-- Learn Articles Schema
-- Educational content organized by category

-- Create enum for article categories
CREATE TYPE article_category AS ENUM ('brain_science', 'psychology', 'life_situation');

-- Main articles table
CREATE TABLE learn_articles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug TEXT UNIQUE NOT NULL,
  
  -- Basic info
  title TEXT NOT NULL,
  summary TEXT NOT NULL,
  category article_category NOT NULL,
  read_time_minutes INTEGER NOT NULL DEFAULT 5,
  
  -- Filtering
  age_brackets TEXT[], -- e.g., ['18-24', '25-34']
  audience TEXT DEFAULT 'any', -- any, service_member, veteran, partner_family
  
  -- Publishing
  is_published BOOLEAN DEFAULT FALSE,
  view_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Article content details (separate for flexibility)
CREATE TABLE learn_article_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  article_id UUID REFERENCES learn_articles(id) ON DELETE CASCADE UNIQUE,
  
  -- Structured content
  sections JSONB NOT NULL, -- Array of {heading, content, tip}
  key_takeaways TEXT[] NOT NULL,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_learn_articles_category ON learn_articles(category);
CREATE INDEX idx_learn_articles_published ON learn_articles(is_published);
CREATE INDEX idx_learn_articles_created ON learn_articles(created_at DESC);

-- Row Level Security
ALTER TABLE learn_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE learn_article_content ENABLE ROW LEVEL SECURITY;

-- Public read access for published articles
CREATE POLICY "Public can read published articles"
  ON learn_articles
  FOR SELECT
  USING (is_published = true);

CREATE POLICY "Public can read published article content"
  ON learn_article_content
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM learn_articles
      WHERE learn_articles.id = learn_article_content.article_id
      AND learn_articles.is_published = true
    )
  );

-- Admin full access (authenticated users for now)
CREATE POLICY "Authenticated users can do everything with articles"
  ON learn_articles
  FOR ALL
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can do everything with article content"
  ON learn_article_content
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_learn_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_learn_articles_updated_at
  BEFORE UPDATE ON learn_articles
  FOR EACH ROW
  EXECUTE FUNCTION update_learn_updated_at();

CREATE TRIGGER update_learn_article_content_updated_at
  BEFORE UPDATE ON learn_article_content
  FOR EACH ROW
  EXECUTE FUNCTION update_learn_updated_at();



