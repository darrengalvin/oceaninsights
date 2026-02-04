import { NextResponse } from 'next/server'
import { supabase } from '@/lib/supabase'

export async function GET() {
  try {
    // Get recent notifications
    const { data: notifications, error: notifError } = await supabase
      .from('apple_notifications')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(50)

    if (notifError) {
      console.error('Error fetching notifications:', notifError)
    }

    // Get daily stats for last 30 days
    const { data: stats, error: statsError } = await supabase
      .from('apple_notification_stats')
      .select('*')
      .order('date', { ascending: false })
      .limit(30)

    if (statsError) {
      console.error('Error fetching stats:', statsError)
    }

    // Calculate summary
    const summary = {
      totalNotifications: notifications?.length || 0,
      todayRevenue: stats?.[0]?.estimated_revenue || 0,
      totalRevenue: stats?.reduce((sum, s) => sum + (Number(s.estimated_revenue) || 0), 0) || 0,
      activeSubscriptions: 0, // Would need more complex query
      recentCancellations: notifications?.filter(n => 
        n.notification_type === 'DID_CHANGE_RENEWAL_STATUS' || 
        n.notification_type === 'EXPIRED'
      ).length || 0,
      recentRefunds: notifications?.filter(n => n.notification_type === 'REFUND').length || 0,
    }

    // Count by type
    const byType: Record<string, number> = {}
    notifications?.forEach(n => {
      byType[n.notification_type] = (byType[n.notification_type] || 0) + 1
    })

    return NextResponse.json({
      summary,
      byType,
      stats: stats || [],
      recentNotifications: notifications || [],
    })
  } catch (error) {
    console.error('API error:', error)
    return NextResponse.json(
      { error: 'Failed to fetch Apple notifications' },
      { status: 500 }
    )
  }
}
