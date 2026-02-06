'use client';

import { useState, useEffect } from 'react';
import { 
  Users, 
  Smartphone, 
  Activity, 
  Clock, 
  TrendingUp,
  BarChart3,
  RefreshCw,
  Calendar
} from 'lucide-react';

interface AnalyticsData {
  summary: {
    totalDevices: number;
    activeDevices: number;
    newDevices: number;
    totalSessions: number;
    totalEvents: number;
    avgSessionDuration: number;
    retentionRate: number;
  };
  platforms: {
    ios: number;
    android: number;
  };
  userTypes: Record<string, number>;
  dailyStats: Array<{ date: string; activeUsers: number }>;
  featureUsage: Array<{ name: string; count: number }>;
  recentEvents: Array<{
    event_name: string;
    event_category: string;
    screen_name: string;
    created_at: string;
  }>;
}

export default function AnalyticsPage() {
  const [data, setData] = useState<AnalyticsData | null>(null);
  const [loading, setLoading] = useState(true);
  const [range, setRange] = useState('30');
  const [error, setError] = useState<string | null>(null);

  const fetchAnalytics = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`/api/analytics?range=${range}`);
      if (!response.ok) throw new Error('Failed to fetch analytics');
      const analyticsData = await response.json();
      setData(analyticsData);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAnalytics();
  }, [range]);

  const formatDuration = (seconds: number) => {
    if (seconds < 60) return `${seconds}s`;
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}m ${secs}s`;
  };

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'short',
    });
  };

  const formatRelativeTime = (dateStr: string) => {
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `${diffHours}h ago`;
    const diffDays = Math.floor(diffHours / 24);
    return `${diffDays}d ago`;
  };

  // Calculate max for chart scaling
  const maxDailyUsers = data?.dailyStats 
    ? Math.max(...data.dailyStats.map(d => d.activeUsers), 1)
    : 1;

  const maxFeatureCount = data?.featureUsage?.[0]?.count || 1;

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Analytics Dashboard</h1>
          <p className="text-gray-500 text-sm mt-1">Anonymous usage metrics for Below the Surface</p>
        </div>
        <div className="flex items-center gap-3">
          <select
            value={range}
            onChange={(e) => setRange(e.target.value)}
            className="bg-white border border-gray-200 rounded-lg px-3 py-2 text-sm text-gray-900 focus:border-ocean-500 focus:outline-none"
          >
            <option value="7">Last 7 days</option>
            <option value="30">Last 30 days</option>
            <option value="90">Last 90 days</option>
            <option value="365">Last year</option>
          </select>
          <button
            onClick={fetchAnalytics}
            disabled={loading}
            className="flex items-center gap-2 px-4 py-2 bg-ocean-600 hover:bg-ocean-700 text-white rounded-lg text-sm font-medium transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </button>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 text-red-700">
          {error}
        </div>
      )}

      {loading && !data ? (
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-ocean-500"></div>
        </div>
      ) : data ? (
        <>
          {/* Summary Cards */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <SummaryCard
              icon={<Users className="w-5 h-5" />}
              label="Total Users"
              value={data.summary.totalDevices.toLocaleString()}
              subtext={`+${data.summary.newDevices} new`}
              color="cyan"
            />
            <SummaryCard
              icon={<Activity className="w-5 h-5" />}
              label="Active Users"
              value={data.summary.activeDevices.toLocaleString()}
              subtext={`in last ${range} days`}
              color="green"
            />
            <SummaryCard
              icon={<BarChart3 className="w-5 h-5" />}
              label="Total Sessions"
              value={data.summary.totalSessions.toLocaleString()}
              subtext={`${Math.round(data.summary.totalSessions / Math.max(data.summary.activeDevices, 1) * 10) / 10} per user`}
              color="purple"
            />
            <SummaryCard
              icon={<Clock className="w-5 h-5" />}
              label="Avg Session"
              value={formatDuration(data.summary.avgSessionDuration)}
              subtext={`${data.summary.retentionRate}% retention`}
              color="orange"
            />
          </div>

          {/* Charts Row */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Daily Active Users Chart */}
            <div className="bg-white rounded-xl p-6 border border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-ocean-600" />
                Daily Active Users
              </h2>
              <div className="h-48">
                {data.dailyStats.length > 0 ? (
                  <div className="flex items-end justify-between h-full gap-1">
                    {data.dailyStats.slice(-14).map((day, i) => (
                      <div key={day.date} className="flex-1 flex flex-col items-center gap-1">
                        <div 
                          className="w-full bg-ocean-500 rounded-t hover:bg-ocean-600 transition-colors cursor-pointer"
                          style={{ 
                            height: `${(day.activeUsers / maxDailyUsers) * 100}%`,
                            minHeight: day.activeUsers > 0 ? '4px' : '0'
                          }}
                          title={`${day.date}: ${day.activeUsers} users`}
                        />
                        <span className="text-xs text-gray-500 rotate-45 origin-left whitespace-nowrap">
                          {formatDate(day.date)}
                        </span>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="h-full flex items-center justify-center text-gray-500">
                    No data yet
                  </div>
                )}
              </div>
            </div>

            {/* Feature Usage Chart */}
            <div className="bg-white rounded-xl p-6 border border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <BarChart3 className="w-5 h-5 text-purple-600" />
                Feature Usage
              </h2>
              <div className="space-y-3">
                {data.featureUsage.length > 0 ? (
                  data.featureUsage.slice(0, 8).map((feature) => (
                    <div key={feature.name} className="flex items-center gap-3">
                      <span className="w-24 text-sm text-gray-600 truncate capitalize">
                        {feature.name}
                      </span>
                      <div className="flex-1 h-6 bg-gray-100 rounded-full overflow-hidden">
                        <div 
                          className="h-full bg-gradient-to-r from-purple-500 to-pink-500 rounded-full transition-all duration-500"
                          style={{ width: `${(feature.count / maxFeatureCount) * 100}%` }}
                        />
                      </div>
                      <span className="w-12 text-right text-sm font-medium text-gray-900">
                        {feature.count}
                      </span>
                    </div>
                  ))
                ) : (
                  <div className="h-32 flex items-center justify-center text-gray-500">
                    No feature data yet
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Bottom Row */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Platform Distribution */}
            <div className="bg-white rounded-xl p-6 border border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <Smartphone className="w-5 h-5 text-green-600" />
                Platforms
              </h2>
              <div className="space-y-4">
                <PlatformBar 
                  label="iOS" 
                  count={data.platforms.ios} 
                  total={data.platforms.ios + data.platforms.android}
                  color="from-blue-500 to-cyan-500"
                />
                <PlatformBar 
                  label="Android" 
                  count={data.platforms.android} 
                  total={data.platforms.ios + data.platforms.android}
                  color="from-green-500 to-emerald-500"
                />
              </div>
            </div>

            {/* User Types */}
            <div className="bg-white rounded-xl p-6 border border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <Users className="w-5 h-5 text-orange-600" />
                User Types
              </h2>
              <div className="space-y-2">
                {Object.entries(data.userTypes).length > 0 ? (
                  Object.entries(data.userTypes)
                    .sort((a, b) => b[1] - a[1])
                    .slice(0, 6)
                    .map(([type, count]) => (
                      <div key={type} className="flex justify-between items-center py-1">
                        <span className="text-sm text-gray-600">{type}</span>
                        <span className="text-sm font-medium text-gray-900">{count}</span>
                      </div>
                    ))
                ) : (
                  <div className="text-gray-500 text-sm">No user type data yet</div>
                )}
              </div>
            </div>

            {/* Recent Events */}
            <div className="bg-white rounded-xl p-6 border border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <Activity className="w-5 h-5 text-pink-600" />
                Recent Activity
              </h2>
              <div className="space-y-2 max-h-48 overflow-y-auto">
                {data.recentEvents.length > 0 ? (
                  data.recentEvents.slice(0, 10).map((event, i) => (
                    <div key={i} className="flex justify-between items-center py-1 border-b border-gray-100 last:border-0">
                      <div>
                        <span className="text-sm text-gray-900 capitalize">
                          {event.event_name?.replace(/_/g, ' ')}
                        </span>
                        {event.screen_name && (
                          <span className="text-xs text-gray-500 ml-2">
                            {event.screen_name}
                          </span>
                        )}
                      </div>
                      <span className="text-xs text-gray-500">
                        {formatRelativeTime(event.created_at)}
                      </span>
                    </div>
                  ))
                ) : (
                  <div className="text-gray-500 text-sm">No events yet</div>
                )}
              </div>
            </div>
          </div>
        </>
      ) : null}
    </div>
  );
}

function SummaryCard({ 
  icon, 
  label, 
  value, 
  subtext, 
  color 
}: { 
  icon: React.ReactNode; 
  label: string; 
  value: string; 
  subtext: string;
  color: 'cyan' | 'green' | 'purple' | 'orange';
}) {
  const colorClasses = {
    cyan: 'text-ocean-600 bg-ocean-50',
    green: 'text-green-600 bg-green-50',
    purple: 'text-purple-600 bg-purple-50',
    orange: 'text-orange-600 bg-orange-50',
  };

  return (
    <div className="bg-white rounded-xl p-5 border border-gray-200">
      <div className="flex items-center gap-3 mb-3">
        <div className={`p-2 rounded-lg ${colorClasses[color]}`}>
          {icon}
        </div>
        <span className="text-gray-600 text-sm">{label}</span>
      </div>
      <div className="text-2xl font-bold text-gray-900">{value}</div>
      <div className="text-sm text-gray-500 mt-1">{subtext}</div>
    </div>
  );
}

function PlatformBar({ 
  label, 
  count, 
  total, 
  color 
}: { 
  label: string; 
  count: number; 
  total: number;
  color: string;
}) {
  const percentage = total > 0 ? Math.round((count / total) * 100) : 0;
  
  return (
    <div>
      <div className="flex justify-between items-center mb-1">
        <span className="text-sm text-gray-600">{label}</span>
        <span className="text-sm font-medium text-gray-900">{count} ({percentage}%)</span>
      </div>
      <div className="h-3 bg-gray-100 rounded-full overflow-hidden">
        <div 
          className={`h-full bg-gradient-to-r ${color} rounded-full transition-all duration-500`}
          style={{ width: `${percentage}%` }}
        />
      </div>
    </div>
  );
}
