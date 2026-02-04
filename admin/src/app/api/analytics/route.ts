import { createClient } from '@supabase/supabase-js';
import { NextResponse } from 'next/server';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const range = searchParams.get('range') || '30'; // Days
    const rangeInt = parseInt(range);

    // Get date range
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - rangeInt);
    const startDateStr = startDate.toISOString().split('T')[0];

    // Total stats
    const { data: totalDevices } = await supabase
      .from('analytics_devices')
      .select('id', { count: 'exact', head: true });

    const { data: activeDevices } = await supabase
      .from('analytics_devices')
      .select('id', { count: 'exact', head: true })
      .gte('last_seen_at', startDate.toISOString());

    const { data: newDevices } = await supabase
      .from('analytics_devices')
      .select('id', { count: 'exact', head: true })
      .gte('first_seen_at', startDate.toISOString());

    const { data: totalSessions } = await supabase
      .from('analytics_sessions')
      .select('id', { count: 'exact', head: true })
      .gte('started_at', startDate.toISOString());

    const { data: totalEvents } = await supabase
      .from('analytics_events')
      .select('id', { count: 'exact', head: true })
      .gte('created_at', startDate.toISOString());

    // Platform breakdown
    const { data: platformStats } = await supabase
      .from('analytics_devices')
      .select('platform')
      .then(({ data }) => {
        const ios = data?.filter(d => d.platform === 'ios').length || 0;
        const android = data?.filter(d => d.platform === 'android').length || 0;
        return { data: { ios, android } };
      });

    // User type breakdown
    const { data: userTypeData } = await supabase
      .from('analytics_devices')
      .select('user_type');

    const userTypeStats: Record<string, number> = {};
    userTypeData?.forEach(d => {
      const type = d.user_type || 'Unknown';
      userTypeStats[type] = (userTypeStats[type] || 0) + 1;
    });

    // Daily active users (last N days)
    const { data: dailyDevices } = await supabase
      .from('analytics_sessions')
      .select('started_at, device_id')
      .gte('started_at', startDate.toISOString())
      .order('started_at', { ascending: true });

    const dailyActiveUsers: Record<string, Set<string>> = {};
    dailyDevices?.forEach(session => {
      const date = new Date(session.started_at).toISOString().split('T')[0];
      if (!dailyActiveUsers[date]) {
        dailyActiveUsers[date] = new Set();
      }
      dailyActiveUsers[date].add(session.device_id);
    });

    const dailyStats = Object.entries(dailyActiveUsers)
      .map(([date, devices]) => ({
        date,
        activeUsers: devices.size,
      }))
      .sort((a, b) => a.date.localeCompare(b.date));

    // Feature usage (event categories)
    const { data: eventData } = await supabase
      .from('analytics_events')
      .select('event_category')
      .gte('created_at', startDate.toISOString())
      .not('event_category', 'is', null);

    const featureStats: Record<string, number> = {};
    eventData?.forEach(e => {
      const category = e.event_category || 'other';
      featureStats[category] = (featureStats[category] || 0) + 1;
    });

    const featureUsage = Object.entries(featureStats)
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count);

    // Session duration stats
    const { data: sessionDurations } = await supabase
      .from('analytics_sessions')
      .select('duration_seconds')
      .gte('started_at', startDate.toISOString())
      .not('duration_seconds', 'is', null);

    const durations = sessionDurations?.map(s => s.duration_seconds) || [];
    const avgDuration = durations.length > 0 
      ? Math.round(durations.reduce((a, b) => a + b, 0) / durations.length)
      : 0;

    // Recent events
    const { data: recentEvents } = await supabase
      .from('analytics_events')
      .select('event_name, event_category, screen_name, created_at')
      .order('created_at', { ascending: false })
      .limit(20);

    // Retention (users who came back)
    const { data: returnUsers } = await supabase
      .from('analytics_devices')
      .select('total_sessions')
      .gte('total_sessions', 2);

    const returningUsersCount = returnUsers?.length || 0;
    const totalUsersCount = (totalDevices as any)?.length || 1;
    const retentionRate = Math.round((returningUsersCount / totalUsersCount) * 100);

    return NextResponse.json({
      summary: {
        totalDevices: (totalDevices as any)?.length || 0,
        activeDevices: (activeDevices as any)?.length || 0,
        newDevices: (newDevices as any)?.length || 0,
        totalSessions: (totalSessions as any)?.length || 0,
        totalEvents: (totalEvents as any)?.length || 0,
        avgSessionDuration: avgDuration,
        retentionRate,
      },
      platforms: platformStats,
      userTypes: userTypeStats,
      dailyStats,
      featureUsage,
      recentEvents: recentEvents || [],
    });
  } catch (error) {
    console.error('Analytics API error:', error);
    return NextResponse.json({ error: 'Failed to fetch analytics' }, { status: 500 });
  }
}
