-- ═══════════════════════════════════════════════════════════════
-- LGBTQ+ Support Module — Supabase schema + seed data
-- ═══════════════════════════════════════════════════════════════

-- 1. Timeline events
CREATE TABLE IF NOT EXISTS lgbtq_timeline (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year        text    NOT NULL,
  event       text    NOT NULL,
  detail      text    NOT NULL,
  sort_order  int     NOT NULL DEFAULT 0,
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE lgbtq_timeline ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read_lgbtq_timeline" ON lgbtq_timeline FOR SELECT USING (true);
CREATE POLICY "auth_write_lgbtq_timeline" ON lgbtq_timeline FOR ALL USING (auth.role() = 'authenticated');

-- 2. Myth Buster questions
CREATE TABLE IF NOT EXISTS lgbtq_myths (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  myth          text    NOT NULL,
  is_true       boolean NOT NULL DEFAULT false,
  explanation   text    NOT NULL,
  sort_order    int     NOT NULL DEFAULT 0,
  created_at    timestamptz DEFAULT now()
);

ALTER TABLE lgbtq_myths ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read_lgbtq_myths" ON lgbtq_myths FOR SELECT USING (true);
CREATE POLICY "auth_write_lgbtq_myths" ON lgbtq_myths FOR ALL USING (auth.role() = 'authenticated');

-- 3. Terminology
CREATE TABLE IF NOT EXISTS lgbtq_terms (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  term        text NOT NULL,
  meaning     text NOT NULL,
  sort_order  int  NOT NULL DEFAULT 0,
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE lgbtq_terms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read_lgbtq_terms" ON lgbtq_terms FOR SELECT USING (true);
CREATE POLICY "auth_write_lgbtq_terms" ON lgbtq_terms FOR ALL USING (auth.role() = 'authenticated');

-- 4. Ally scenarios
CREATE TABLE IF NOT EXISTS lgbtq_ally_scenarios (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario      text NOT NULL,
  best_option   int  NOT NULL DEFAULT 0,
  explanation   text NOT NULL,
  sort_order    int  NOT NULL DEFAULT 0,
  created_at    timestamptz DEFAULT now()
);

ALTER TABLE lgbtq_ally_scenarios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read_lgbtq_ally_scenarios" ON lgbtq_ally_scenarios FOR SELECT USING (true);
CREATE POLICY "auth_write_lgbtq_ally_scenarios" ON lgbtq_ally_scenarios FOR ALL USING (auth.role() = 'authenticated');

-- 5. Ally scenario options
CREATE TABLE IF NOT EXISTS lgbtq_ally_options (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id   uuid REFERENCES lgbtq_ally_scenarios(id) ON DELETE CASCADE,
  option_text   text NOT NULL,
  option_index  int  NOT NULL DEFAULT 0,
  created_at    timestamptz DEFAULT now()
);

ALTER TABLE lgbtq_ally_options ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read_lgbtq_ally_options" ON lgbtq_ally_options FOR SELECT USING (true);
CREATE POLICY "auth_write_lgbtq_ally_options" ON lgbtq_ally_options FOR ALL USING (auth.role() = 'authenticated');

-- 6. Deployment safety regions
CREATE TABLE IF NOT EXISTS lgbtq_deploy_regions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  region      text NOT NULL,
  color_hex   text NOT NULL DEFAULT '#E74C3C',
  icon_name   text NOT NULL DEFAULT 'warning_rounded',
  countries   text NOT NULL,
  advice      text NOT NULL,
  sort_order  int  NOT NULL DEFAULT 0,
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE lgbtq_deploy_regions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read_lgbtq_deploy_regions" ON lgbtq_deploy_regions FOR SELECT USING (true);
CREATE POLICY "auth_write_lgbtq_deploy_regions" ON lgbtq_deploy_regions FOR ALL USING (auth.role() = 'authenticated');

-- 7. Support organisations
CREATE TABLE IF NOT EXISTS lgbtq_support_orgs (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  description text NOT NULL,
  contact     text NOT NULL,
  website     text NOT NULL,
  emoji       text NOT NULL DEFAULT '💜',
  sort_order  int  NOT NULL DEFAULT 0,
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE lgbtq_support_orgs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read_lgbtq_support_orgs" ON lgbtq_support_orgs FOR SELECT USING (true);
CREATE POLICY "auth_write_lgbtq_support_orgs" ON lgbtq_support_orgs FOR ALL USING (auth.role() = 'authenticated');

-- 8. Affirmations
CREATE TABLE IF NOT EXISTS lgbtq_affirmations (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  text        text NOT NULL,
  sort_order  int  NOT NULL DEFAULT 0,
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE lgbtq_affirmations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read_lgbtq_affirmations" ON lgbtq_affirmations FOR SELECT USING (true);
CREATE POLICY "auth_write_lgbtq_affirmations" ON lgbtq_affirmations FOR ALL USING (auth.role() = 'authenticated');

-- ═══════════════════════════════════════════════════════════════
-- Seed Data
-- ═══════════════════════════════════════════════════════════════

INSERT INTO lgbtq_timeline (year, event, detail, sort_order) VALUES
  ('1967', 'Homosexuality partially decriminalised in England & Wales', 'The Sexual Offences Act decriminalised private homosexual acts between men over 21, but the military remained exempt.', 1),
  ('1994', 'Age of consent lowered to 18 for gay men', 'Still not equal — the heterosexual age of consent was 16. The military continued to discharge LGBTQ+ personnel.', 2),
  ('2000', 'UK Armed Forces ban on LGBTQ+ service lifted', 'Following the European Court of Human Rights ruling in Smith and Grady v UK, the blanket ban was lifted on 12 January 2000. Thousands had already been dismissed.', 3),
  ('2004', 'Civil Partnership Act passed', 'Same-sex couples gained legal recognition. Military families began to access some partner benefits for the first time.', 4),
  ('2010', 'Equality Act becomes law', 'Comprehensive protection against discrimination based on sexual orientation and gender reassignment in all areas, including the military.', 5),
  ('2014', 'Same-sex marriage legalised in England & Wales', 'Full marriage equality. Military chaplains were not compelled to perform ceremonies but same-sex married couples received equal benefits.', 6),
  ('2017', 'UK Government apologises for historical treatment', 'A formal apology was issued, acknowledging the suffering caused by the ban. Many veterans were still waiting for pardons and recognition.', 7),
  ('2023', 'LGBT Veterans Independent Review (Etherton Review)', 'Lord Etherton''s independent review examined the impact of the ban. The government accepted all recommendations and committed to restorative measures.', 8),
  ('2025', 'US reinstates transgender military ban', 'Executive order bars transgender people from enlisting and serving openly. The Supreme Court allows it to take effect. This does not affect UK forces, but affects allied operations.', 9);

INSERT INTO lgbtq_myths (myth, is_true, explanation, sort_order) VALUES
  ('LGBTQ+ people can''t handle the pressure of military life.', false, 'LGBTQ+ people have served with distinction throughout history — often while hiding their identity, which required extraordinary resilience on top of their duties.', 1),
  ('The UK lifted its ban on LGBTQ+ military service in 2000.', true, 'The ban was lifted on 12 January 2000 after the European Court of Human Rights ruled it a violation of human rights. Before this, an estimated 5,000+ people were dismissed.', 2),
  ('Being LGBTQ+ is accepted worldwide.', false, 'As of 2025, 65 countries still criminalise same-sex activity. In some, the penalty is death. Service members deployed to these regions face real danger if their identity is discovered.', 3),
  ('LGBTQ+ veterans have the same mental health outcomes as other veterans.', false, 'Research shows LGBTQ+ veterans face significantly higher rates of depression, anxiety, and suicidal ideation — not because of their identity, but because of stigma, discrimination, and isolation.', 4),
  ('If someone hasn''t "come out" they''re probably not LGBTQ+.', false, 'Many people don''t feel safe to come out, especially in military environments. Someone''s silence about their identity doesn''t mean it doesn''t exist — it often means they don''t feel safe.', 5),
  ('Allies aren''t important — it''s up to LGBTQ+ people to support themselves.', false, 'Allies are vital. Research shows that even one supportive person can dramatically reduce the risk of depression and suicide in LGBTQ+ individuals. Your support literally saves lives.', 6),
  ('The UK military is now fully inclusive — the work is done.', false, 'While huge progress has been made, many LGBTQ+ veterans who were dismissed before 2000 are still waiting for full recognition and support. And serving members can still face day-to-day prejudice.', 7),
  ('Gender identity and sexual orientation are the same thing.', false, 'Sexual orientation is about who you''re attracted to. Gender identity is about who you are. A transgender person can be straight, gay, bisexual, or any other orientation.', 8);

INSERT INTO lgbtq_terms (term, meaning, sort_order) VALUES
  ('LGBTQ+', 'Lesbian, Gay, Bisexual, Transgender, Queer/Questioning, and more. The "+" recognises the spectrum of identities beyond these.', 1),
  ('Transgender', 'A person whose gender identity differs from the sex they were assigned at birth. This is about identity, not sexual orientation.', 2),
  ('Non-binary', 'A person who doesn''t identify exclusively as male or female. Some use they/them pronouns but not all.', 3),
  ('Cisgender', 'A person whose gender identity matches the sex they were assigned at birth. Most people are cisgender.', 4),
  ('Coming Out', 'The process of sharing one''s sexual orientation or gender identity with others. It''s deeply personal and should never be forced or done on someone else''s behalf.', 5),
  ('Ally', 'Someone who supports LGBTQ+ people. You don''t have to be LGBTQ+ to stand up for equality and inclusion.', 6),
  ('Deadnaming', 'Using a transgender person''s birth name after they''ve changed it. This can be deeply hurtful, even if unintentional.', 7),
  ('Intersex', 'A person born with physical sex characteristics that don''t fit typical definitions of male or female. More common than many realise — about 1.7% of people.', 8);

INSERT INTO lgbtq_deploy_regions (region, color_hex, icon_name, countries, advice, sort_order) VALUES
  ('Severe Risk — Death Penalty', '#E74C3C', 'dangerous_rounded', 'Afghanistan, Brunei, Iran, Mauritania, Nigeria (north), Pakistan, Qatar, Saudi Arabia, Somalia, UAE, Yemen', 'Same-sex activity can carry the death penalty. Absolute discretion is essential. No digital evidence, no disclosure to locals, no LGBTQ+ apps on personal devices.', 1),
  ('High Risk — Imprisonment', '#E67E22', 'warning_rounded', 'Egypt, Kenya, Malaysia, Myanmar, Oman, Singapore, Sri Lanka, Tanzania, Uganda, and 20+ others', 'Imprisonment of 10+ years for same-sex activity. Exercise extreme caution. Avoid any public display of affection or disclosure. Be aware of local informant culture.', 2),
  ('Elevated Risk — Criminalised', '#F39C12', 'shield_rounded', 'Jamaica, Trinidad & Tobago, Ghana, Cameroon, Morocco, Tunisia, and others', 'Same-sex activity is illegal with varying enforcement. Stay vigilant. Laws may be selectively enforced against foreigners.', 3),
  ('Caution — Social Hostility', '#3498DB', 'info_rounded', 'Russia, Hungary, Poland (some regions), Turkey, Indonesia', 'Not criminalised but significant social hostility exists. Pride events banned in some areas. Avoid public displays of affection and be aware of surveillance.', 4),
  ('Generally Safe — Legal Protections', '#00B894', 'check_circle_rounded', 'UK, most EU nations, Canada, Australia, New Zealand, and others', 'Legal protections in place. Same-sex marriage recognised. Still exercise normal personal security awareness.', 5);

INSERT INTO lgbtq_support_orgs (name, description, contact, website, emoji, sort_order) VALUES
  ('Fighting With Pride', 'The UK Armed Forces LGBTQ+ charity. Support for serving personnel, veterans, and families. Founded by those who experienced the ban.', '020 3981 3810', 'fightingwithpride.org.uk', '🏳️‍🌈', 1),
  ('Op COURAGE', 'NHS veteran mental health and wellbeing service. Confidential, free, and designed for veterans. Available across England.', 'Via GP or self-referral', 'nhs.uk/opcourage', '💚', 2),
  ('Samaritans', 'Available 24/7 for anyone struggling. You don''t have to be suicidal to call. They listen without judgement.', '116 123 (free, 24/7)', 'samaritans.org', '📞', 3),
  ('Switchboard LGBT+ Helpline', 'A safe space for anyone to discuss anything, including sexuality, gender identity, and emotional wellbeing.', '0800 0119 100', 'switchboard.lgbt', '💜', 4),
  ('Mermaids', 'Support for transgender, non-binary, and gender-diverse young people and their families.', '0808 801 0400', 'mermaidsuk.org.uk', '🧜', 5),
  ('Modern Military Association (US/International)', 'The largest US advocacy group for LGBTQ+ military and veterans. Resources, legal support, and community.', 'Via website', 'modernmilitary.org', '🇺🇸', 6);

INSERT INTO lgbtq_affirmations (text, sort_order) VALUES
  ('Your identity is not a weakness — it''s part of your strength.', 1),
  ('You deserve to serve as your full self.', 2),
  ('You are not alone. There are people who understand and care.', 3),
  ('Your courage to be yourself in a uniform is extraordinary.', 4),
  ('Being different in a world that demands conformity is bravery.', 5),
  ('You matter. Your wellbeing matters. Reach out if you need to.', 6),
  ('The people who came before you fought so you could be here.', 7),
  ('It gets better. And you deserve to be here when it does.', 8);

-- Seed ally scenarios with options
DO $$
DECLARE
  s1 uuid; s2 uuid; s3 uuid; s4 uuid; s5 uuid; s6 uuid;
BEGIN
  INSERT INTO lgbtq_ally_scenarios (scenario, best_option, explanation, sort_order) VALUES
    ('In the mess, someone makes a homophobic joke. Everyone laughs. A colleague you suspect is gay goes quiet.', 2, 'Calling it out in the moment — even briefly — sends a powerful signal. "That''s not on" is enough. Silence is interpreted as agreement. Checking privately is good too, but it doesn''t change the culture.', 1)
    RETURNING id INTO s1;
  INSERT INTO lgbtq_ally_options (scenario_id, option_text, option_index) VALUES
    (s1, 'Laugh along — it''s just banter', 0),
    (s1, 'Say nothing but check on them later', 1),
    (s1, 'Call it out calmly — "That''s not on"', 2);

  INSERT INTO lgbtq_ally_scenarios (scenario, best_option, explanation, sort_order) VALUES
    ('A colleague comes out to you privately. You''re the first person they''ve told in the military.', 0, 'The most powerful thing you can say is that it doesn''t change your respect for them. Don''t probe for details — let them share what they want, when they want. Coming out is their choice, not yours to manage.', 2)
    RETURNING id INTO s2;
  INSERT INTO lgbtq_ally_options (scenario_id, option_text, option_index) VALUES
    (s2, 'Tell them it doesn''t change anything between you', 0),
    (s2, 'Ask lots of questions about their personal life', 1),
    (s2, 'Suggest they tell the chain of command', 2);

  INSERT INTO lgbtq_ally_scenarios (scenario, best_option, explanation, sort_order) VALUES
    ('You hear someone referring to a transgender colleague by their old name (deadnaming) behind their back.', 1, 'A gentle correction normalises using the right name. It doesn''t need to be a big deal — that''s what makes it effective. If it becomes a pattern of harassment, then escalation is appropriate.', 3)
    RETURNING id INTO s3;
  INSERT INTO lgbtq_ally_options (scenario_id, option_text, option_index) VALUES
    (s3, 'It''s not your business', 0),
    (s3, 'Correct them gently — "They go by [correct name] now"', 1),
    (s3, 'Report it to the chain of command immediately', 2);

  INSERT INTO lgbtq_ally_scenarios (scenario, best_option, explanation, sort_order) VALUES
    ('Your unit is deploying to a country where being LGBTQ+ is illegal. You know a colleague is gay.', 1, 'A quiet, private conversation shows you care without outing them. They likely already know, but knowing someone has their back is incredibly reassuring. Never out someone publicly, even with good intentions.', 4)
    RETURNING id INTO s4;
  INSERT INTO lgbtq_ally_options (scenario_id, option_text, option_index) VALUES
    (s4, 'Warn them publicly so everyone is careful', 0),
    (s4, 'Have a quiet word — ask if they''re aware and if they need support', 1),
    (s4, 'It''s their problem to manage', 2);

  INSERT INTO lgbtq_ally_scenarios (scenario, best_option, explanation, sort_order) VALUES
    ('During Pride Month, rainbow lanyards appear on base. A colleague scoffs and says "Why do they need special treatment?"', 1, 'Visibility matters. For decades, LGBTQ+ service members served in silence and fear. Visible support signals that they belong. It''s not special treatment — it''s catching up on years of exclusion.', 5)
    RETURNING id INTO s5;
  INSERT INTO lgbtq_ally_options (scenario_id, option_text, option_index) VALUES
    (s5, 'Agree — it does seem like special treatment', 0),
    (s5, 'Explain that visibility isn''t special treatment, it''s about safety and belonging', 1),
    (s5, 'Change the subject', 2);

  INSERT INTO lgbtq_ally_scenarios (scenario, best_option, explanation, sort_order) VALUES
    ('You''re filling out a form that asks for "next of kin." A colleague asks if they can put their same-sex partner.', 1, 'Under UK law, same-sex partners (married or civil partners) have identical legal standing. There should be zero hesitation. The confidence of your "yes" matters — it tells them they''re fully equal.', 6)
    RETURNING id INTO s6;
  INSERT INTO lgbtq_ally_options (scenario_id, option_text, option_index) VALUES
    (s6, 'Say "I don''t know, check with admin"', 0),
    (s6, 'Confirm yes — same-sex partners are legally recognised for all purposes', 1),
    (s6, 'Suggest they put a family member instead to avoid complications', 2);
END $$;
