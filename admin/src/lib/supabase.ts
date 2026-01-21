import { createClient } from '@supabase/supabase-js'

// Client-side Supabase client (uses anon key)
export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

// Server-side Supabase client with service role (full access)
export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
)

// Types for our database
export interface Domain {
  id: string
  slug: string
  name: string
  description: string | null
  icon: string
  display_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface ContentItem {
  id: string
  slug: string
  domain_id: string
  pillar: 'understand' | 'reflect' | 'grow' | 'support'
  label: string
  microcopy: string | null
  audience: 'any' | 'service_member' | 'veteran' | 'partner_family'
  sensitivity: 'normal' | 'sensitive' | 'urgent'
  disclosure_level: 1 | 2 | 3
  keywords: string[]
  is_published: boolean
  view_count: number
  created_at: string
  updated_at: string
}

export interface ContentDetails {
  id: string
  content_item_id: string
  understand_title: string | null
  understand_body: string | null
  understand_insights: string[]
  reflect_prompts: string[]
  grow_title: string | null
  grow_steps: Array<{ action: string; detail: string }>
  support_intro: string | null
  support_resources: Array<{ name: string; description: string; contact?: string }>
  affirmation: string | null
  created_at: string
  updated_at: string
}

export interface ContentFull extends ContentItem {
  domain_slug: string
  domain_name: string
  domain_icon: string
  understand_title: string | null
  understand_body: string | null
  understand_insights: string[]
  reflect_prompts: string[]
  grow_title: string | null
  grow_steps: Array<{ action: string; detail: string }>
  support_intro: string | null
  support_resources: Array<{ name: string; description: string; contact?: string }>
  affirmation: string | null
}

export interface Journey {
  id: string
  slug: string
  title: string
  description: string | null
  audience: 'any' | 'service_member' | 'veteran' | 'partner_family'
  item_sequence: string[]
  is_published: boolean
  created_at: string
  updated_at: string
}

