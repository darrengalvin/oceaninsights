/// Supabase Configuration
/// 
/// The anon key is designed to be public - security is handled via
/// Row Level Security (RLS) policies on the Supabase side.
/// 
/// This means:
/// - App can only READ published content
/// - App cannot write/update/delete anything
/// - Admin panel uses service_role key (server-side only)
class SupabaseConfig {
  static const String url = 'https://vecclmzkzrwsrtokkclr.supabase.co';
  
  // This is the anon/public key - safe to include in app
  // Security is enforced by RLS policies, not by hiding this key
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZlY2NsbXprenJ3c3J0b2trY2xyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg5MjQ0MjEsImV4cCI6MjA4NDUwMDQyMX0.S0Iskt-OzYc_CCTJBAOimYmvv5Ef9J8HupX2IRZwwAk';
}



