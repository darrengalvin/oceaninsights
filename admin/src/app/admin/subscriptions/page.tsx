'use client'

import { useState, useEffect } from 'react'
import { 
  CreditCard, 
  TrendingUp, 
  TrendingDown, 
  RefreshCw,
  AlertCircle,
  CheckCircle,
  XCircle,
  Clock
} from 'lucide-react'

interface AppleNotification {
  id: string
  notification_type: string
  subtype?: string
  product_id?: string
  environment: string
  created_at: string
}

interface DailyStat {
  date: string
  subscriptions_started: number
  subscriptions_renewed: number
  subscriptions_cancelled: number
  subscriptions_expired: number
  refunds: number
  billing_issues: number
  estimated_revenue: number
}

interface Summary {
  totalNotifications: number
  todayRevenue: number
  totalRevenue: number
  recentCancellations: number
  recentRefunds: number
}

export default function SubscriptionsPage() {
  const [loading, setLoading] = useState(true)
  const [summary, setSummary] = useState<Summary | null>(null)
  const [byType, setByType] = useState<Record<string, number>>({})
  const [stats, setStats] = useState<DailyStat[]>([])
  const [notifications, setNotifications] = useState<AppleNotification[]>([])

  useEffect(() => {
    fetchData()
  }, [])

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await fetch('/api/apple-notifications')
      const data = await res.json()
      
      setSummary(data.summary)
      setByType(data.byType || {})
      setStats(data.stats || [])
      setNotifications(data.recentNotifications || [])
    } catch (error) {
      console.error('Error fetching data:', error)
    } finally {
      setLoading(false)
    }
  }

  const getNotificationIcon = (type: string) => {
    switch (type) {
      case 'SUBSCRIBED':
      case 'DID_RENEW':
        return <CheckCircle className="w-4 h-4 text-green-500" />
      case 'EXPIRED':
      case 'DID_CHANGE_RENEWAL_STATUS':
        return <XCircle className="w-4 h-4 text-red-500" />
      case 'REFUND':
        return <TrendingDown className="w-4 h-4 text-orange-500" />
      case 'DID_FAIL_TO_RENEW':
        return <AlertCircle className="w-4 h-4 text-yellow-500" />
      default:
        return <Clock className="w-4 h-4 text-gray-500" />
    }
  }

  const getNotificationLabel = (type: string) => {
    const labels: Record<string, string> = {
      'SUBSCRIBED': 'New Subscription',
      'DID_RENEW': 'Renewed',
      'DID_CHANGE_RENEWAL_STATUS': 'Cancelled Auto-Renew',
      'EXPIRED': 'Expired',
      'REFUND': 'Refunded',
      'DID_FAIL_TO_RENEW': 'Billing Issue',
      'GRACE_PERIOD_EXPIRED': 'Grace Period Ended',
      'TEST': 'Test Notification',
    }
    return labels[type] || type
  }

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit',
    })
  }

  const formatCurrency = (amount: number) => {
    return `£${amount.toFixed(2)}`
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <RefreshCw className="w-8 h-8 animate-spin text-ocean-500" />
      </div>
    )
  }

  return (
    <div className="p-8 space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Subscriptions & Revenue</h1>
          <p className="text-gray-500 mt-1">
            Apple App Store notification events
          </p>
        </div>
        <button
          onClick={fetchData}
          className="flex items-center gap-2 px-4 py-2 bg-ocean-600 text-white rounded-lg hover:bg-ocean-700"
        >
          <RefreshCw className="w-4 h-4" />
          Refresh
        </button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-6 rounded-xl border border-gray-200">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-green-100 rounded-lg">
              <TrendingUp className="w-5 h-5 text-green-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Total Revenue</p>
              <p className="text-2xl font-bold">{formatCurrency(summary?.totalRevenue || 0)}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl border border-gray-200">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-blue-100 rounded-lg">
              <CreditCard className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Today</p>
              <p className="text-2xl font-bold">{formatCurrency(summary?.todayRevenue || 0)}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl border border-gray-200">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-red-100 rounded-lg">
              <XCircle className="w-5 h-5 text-red-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Recent Cancellations</p>
              <p className="text-2xl font-bold">{summary?.recentCancellations || 0}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl border border-gray-200">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-orange-100 rounded-lg">
              <TrendingDown className="w-5 h-5 text-orange-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Refunds</p>
              <p className="text-2xl font-bold">{summary?.recentRefunds || 0}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Events by Type */}
      {Object.keys(byType).length > 0 && (
        <div className="bg-white p-6 rounded-xl border border-gray-200">
          <h2 className="text-lg font-semibold mb-4">Events by Type</h2>
          <div className="flex flex-wrap gap-3">
            {Object.entries(byType).map(([type, count]) => (
              <div 
                key={type}
                className="flex items-center gap-2 px-3 py-2 bg-gray-100 rounded-lg"
              >
                {getNotificationIcon(type)}
                <span className="text-sm">{getNotificationLabel(type)}</span>
                <span className="text-sm font-bold text-gray-700">{count}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Recent Notifications */}
      <div className="bg-white rounded-xl border border-gray-200">
        <div className="p-4 border-b">
          <h2 className="text-lg font-semibold">Recent Events</h2>
        </div>
        
        {notifications.length === 0 ? (
          <div className="p-8 text-center text-gray-500">
            <CreditCard className="w-12 h-12 mx-auto mb-3 opacity-50" />
            <p>No Apple notifications received yet.</p>
            <p className="text-sm mt-1">
              Events will appear here when users make purchases or subscriptions change.
            </p>
          </div>
        ) : (
          <div className="divide-y">
            {notifications.map((notification) => (
              <div key={notification.id} className="p-4 hover:bg-gray-50">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    {getNotificationIcon(notification.notification_type)}
                    <div>
                      <p className="font-medium">
                        {getNotificationLabel(notification.notification_type)}
                      </p>
                      <p className="text-sm text-gray-500">
                        {notification.product_id || 'Unknown product'}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm text-gray-500">
                      {formatDate(notification.created_at)}
                    </p>
                    <span className={`text-xs px-2 py-1 rounded ${
                      notification.environment === 'Production' 
                        ? 'bg-green-100 text-green-700'
                        : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {notification.environment}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Daily Stats Table */}
      {stats.length > 0 && (
        <div className="bg-white rounded-xl border border-gray-200">
          <div className="p-4 border-b">
            <h2 className="text-lg font-semibold">Daily Summary</h2>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left text-sm font-medium text-gray-600">Date</th>
                  <th className="px-4 py-3 text-center text-sm font-medium text-gray-600">Started</th>
                  <th className="px-4 py-3 text-center text-sm font-medium text-gray-600">Renewed</th>
                  <th className="px-4 py-3 text-center text-sm font-medium text-gray-600">Cancelled</th>
                  <th className="px-4 py-3 text-center text-sm font-medium text-gray-600">Expired</th>
                  <th className="px-4 py-3 text-center text-sm font-medium text-gray-600">Refunds</th>
                  <th className="px-4 py-3 text-right text-sm font-medium text-gray-600">Revenue</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {stats.map((stat) => (
                  <tr key={stat.date} className="hover:bg-gray-50">
                    <td className="px-4 py-3 text-sm">{stat.date}</td>
                    <td className="px-4 py-3 text-center text-sm text-green-600">{stat.subscriptions_started}</td>
                    <td className="px-4 py-3 text-center text-sm text-blue-600">{stat.subscriptions_renewed}</td>
                    <td className="px-4 py-3 text-center text-sm text-red-600">{stat.subscriptions_cancelled}</td>
                    <td className="px-4 py-3 text-center text-sm text-gray-600">{stat.subscriptions_expired}</td>
                    <td className="px-4 py-3 text-center text-sm text-orange-600">{stat.refunds}</td>
                    <td className="px-4 py-3 text-right text-sm font-medium">{formatCurrency(Number(stat.estimated_revenue))}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
