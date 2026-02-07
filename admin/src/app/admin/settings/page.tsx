'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';

interface AppSetting {
  key: string;
  value: string;
  description: string | null;
  is_secret: boolean;
  updated_at: string;
}

export default function AppSettingsPage() {
  const [settings, setSettings] = useState<AppSetting[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState<string | null>(null);
  const [editValues, setEditValues] = useState<Record<string, string>>({});
  const [showSecrets, setShowSecrets] = useState(false);

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabaseAdmin
        .from('app_settings')
        .select('*')
        .order('key');

      if (error) throw error;
      
      setSettings(data || []);
      
      // Initialize edit values
      const values: Record<string, string> = {};
      data?.forEach(s => {
        values[s.key] = s.value;
      });
      setEditValues(values);
    } catch (error) {
      console.error('Error fetching settings:', error);
    } finally {
      setLoading(false);
    }
  };

  const saveSetting = async (key: string) => {
    setSaving(key);
    try {
      const { error } = await supabaseAdmin
        .from('app_settings')
        .update({ 
          value: editValues[key],
          updated_at: new Date().toISOString()
        })
        .eq('key', key);

      if (error) throw error;
      
      // Refresh settings
      await fetchSettings();
    } catch (error) {
      console.error('Error saving setting:', error);
      alert('Failed to save setting');
    } finally {
      setSaving(null);
    }
  };

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleString();
  };

  if (loading) {
    return (
      <div className="p-8">
        <div className="animate-pulse">Loading settings...</div>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-4xl mx-auto">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">App Settings</h1>
          <p className="text-gray-600 mt-1">
            Configure app-wide settings including the developer access phrase
          </p>
        </div>
        <button
          onClick={() => setShowSecrets(!showSecrets)}
          className="px-4 py-2 text-sm bg-gray-100 hover:bg-gray-200 rounded-lg transition"
        >
          {showSecrets ? '🙈 Hide Secrets' : '👁️ Show Secrets'}
        </button>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50 border-b border-gray-200">
            <tr>
              <th className="text-left py-3 px-4 font-medium text-gray-600">Setting</th>
              <th className="text-left py-3 px-4 font-medium text-gray-600">Value</th>
              <th className="text-left py-3 px-4 font-medium text-gray-600">Last Updated</th>
              <th className="py-3 px-4"></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {settings.map((setting) => (
              <tr key={setting.key} className="hover:bg-gray-50">
                <td className="py-4 px-4">
                  <div className="font-medium text-gray-900">
                    {setting.key}
                    {setting.is_secret && (
                      <span className="ml-2 text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded">
                        Secret
                      </span>
                    )}
                  </div>
                  {setting.description && (
                    <div className="text-sm text-gray-500 mt-1">
                      {setting.description}
                    </div>
                  )}
                </td>
                <td className="py-4 px-4">
                  <input
                    type={setting.is_secret && !showSecrets ? 'password' : 'text'}
                    value={editValues[setting.key] || ''}
                    onChange={(e) => setEditValues({
                      ...editValues,
                      [setting.key]: e.target.value
                    })}
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </td>
                <td className="py-4 px-4 text-sm text-gray-500">
                  {formatDate(setting.updated_at)}
                </td>
                <td className="py-4 px-4">
                  <button
                    onClick={() => saveSetting(setting.key)}
                    disabled={saving === setting.key || editValues[setting.key] === setting.value}
                    className={`px-4 py-2 text-sm rounded-lg transition ${
                      editValues[setting.key] !== setting.value
                        ? 'bg-blue-600 text-white hover:bg-blue-700'
                        : 'bg-gray-100 text-gray-400 cursor-not-allowed'
                    }`}
                  >
                    {saving === setting.key ? 'Saving...' : 'Save'}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="mt-8 p-4 bg-amber-50 border border-amber-200 rounded-lg">
        <h3 className="font-medium text-amber-800">🔐 Developer Access</h3>
        <p className="text-sm text-amber-700 mt-1">
          The <strong>developer_phrase</strong> is used for secret developer access in the app. 
          Users tap the version number 7 times, then enter this phrase to toggle premium mode for testing.
          Change it here if the phrase is ever leaked.
        </p>
      </div>
    </div>
  );
}
