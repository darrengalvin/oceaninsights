'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface MilitaryRole {
  id: string;
  title: string;
  branch: string;
  description: string;
  sort_order: number;
  is_active: boolean;
}

interface CivilianJob {
  id: string;
  title: string;
  description: string;
  salary_range: string;
  growth_outlook: string;
  key_skills: string[];
  sort_order: number;
  is_active: boolean;
}

type TabType = 'roles' | 'jobs';

export default function SkillsTranslatorPage() {
  const [activeTab, setActiveTab] = useState<TabType>('roles');
  const [roles, setRoles] = useState<MilitaryRole[]>([]);
  const [jobs, setJobs] = useState<CivilianJob[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newRole, setNewRole] = useState({ title: '', branch: 'All', description: '' });
  const [newJob, setNewJob] = useState({ title: '', description: '', salary_range: '', growth_outlook: 'Medium', key_skills: '' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [rolesRes, jobsRes] = await Promise.all([
      supabaseAdmin.from('military_roles').select('*').order('sort_order'),
      supabaseAdmin.from('civilian_jobs').select('*').order('sort_order'),
    ]);

    if (rolesRes.data) setRoles(rolesRes.data);
    if (jobsRes.data) setJobs(jobsRes.data);
    setLoading(false);
  }

  async function addRole() {
    if (!newRole.title.trim()) return;
    const maxOrder = roles.reduce((max, r) => Math.max(max, r.sort_order), 0);
    
    const { error } = await supabaseAdmin.from('military_roles').insert({
      ...newRole,
      sort_order: maxOrder + 1,
      is_active: true,
    });

    if (!error) {
      fetchData();
      setNewRole({ title: '', branch: 'All', description: '' });
      setShowAddForm(false);
    }
  }

  async function addJob() {
    if (!newJob.title.trim()) return;
    const maxOrder = jobs.reduce((max, j) => Math.max(max, j.sort_order), 0);
    
    const { error } = await supabaseAdmin.from('civilian_jobs').insert({
      title: newJob.title,
      description: newJob.description,
      salary_range: newJob.salary_range,
      growth_outlook: newJob.growth_outlook,
      key_skills: newJob.key_skills.split(',').map(s => s.trim()).filter(Boolean),
      sort_order: maxOrder + 1,
      is_active: true,
    });

    if (!error) {
      fetchData();
      setNewJob({ title: '', description: '', salary_range: '', growth_outlook: 'Medium', key_skills: '' });
      setShowAddForm(false);
    }
  }

  async function deleteItem(table: string, id: string) {
    if (!confirm('Delete this item?')) return;
    await supabaseAdmin.from(table).delete().eq('id', id);
    fetchData();
  }

  async function toggleActive(table: string, id: string, current: boolean) {
    await supabaseAdmin.from(table).update({ is_active: !current }).eq('id', id);
    fetchData();
  }

  const growthColors = {
    High: 'bg-green-100 text-green-700',
    Medium: 'bg-yellow-100 text-yellow-700',
    Low: 'bg-red-100 text-red-700',
  };

  if (loading) {
    return (
      <div className="p-8">
        <div className="animate-pulse space-y-4">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="h-64 bg-gray-200 rounded"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <Link href="/admin/content-manager" className="text-cyan-600 hover:text-cyan-800 text-sm flex items-center gap-1">
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          Back to Content Manager
        </Link>
      </div>

      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Skills Translator</h1>
          <p className="text-gray-600 mt-1">Military roles and civilian job mappings</p>
        </div>
        <button
          onClick={() => setShowAddForm(!showAddForm)}
          className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700 transition flex items-center gap-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add {activeTab === 'roles' ? 'Military Role' : 'Civilian Job'}
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-white rounded-xl p-5 border border-gray-200">
          <div className="flex items-center gap-3">
            <span className="text-3xl">🎖️</span>
            <div>
              <div className="text-3xl font-bold text-gray-900">{roles.length}</div>
              <div className="text-gray-500">Military Roles</div>
            </div>
          </div>
        </div>
        <div className="bg-white rounded-xl p-5 border border-gray-200">
          <div className="flex items-center gap-3">
            <span className="text-3xl">💼</span>
            <div>
              <div className="text-3xl font-bold text-gray-900">{jobs.length}</div>
              <div className="text-gray-500">Civilian Jobs</div>
            </div>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-6">
        <button
          onClick={() => { setActiveTab('roles'); setShowAddForm(false); }}
          className={`px-4 py-2 rounded-lg font-medium transition flex items-center gap-2 ${
            activeTab === 'roles'
              ? 'bg-green-600'
              : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
          }`}
        >
          🎖️ Military Roles ({roles.length})
        </button>
        <button
          onClick={() => { setActiveTab('jobs'); setShowAddForm(false); }}
          className={`px-4 py-2 rounded-lg font-medium transition flex items-center gap-2 ${
            activeTab === 'jobs'
              ? 'bg-blue-600'
              : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
          }`}
        >
          💼 Civilian Jobs ({jobs.length})
        </button>
      </div>

      {/* Add Form */}
      {showAddForm && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">
            Add New {activeTab === 'roles' ? 'Military Role' : 'Civilian Job'}
          </h2>
          
          {activeTab === 'roles' ? (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                <input
                  type="text"
                  value={newRole.title}
                  onChange={(e) => setNewRole({ ...newRole, title: e.target.value })}
                  placeholder="e.g., Infantry"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Branch</label>
                <select
                  value={newRole.branch}
                  onChange={(e) => setNewRole({ ...newRole, branch: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                >
                  <option value="All">All Branches</option>
                  <option value="Army">Army</option>
                  <option value="Navy">Navy</option>
                  <option value="Air Force">Air Force</option>
                  <option value="Marines">Marines</option>
                  <option value="Coast Guard">Coast Guard</option>
                  <option value="Space Force">Space Force</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <input
                  type="text"
                  value={newRole.description}
                  onChange={(e) => setNewRole({ ...newRole, description: e.target.value })}
                  placeholder="Optional description"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                />
              </div>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                <input
                  type="text"
                  value={newJob.title}
                  onChange={(e) => setNewJob({ ...newJob, title: e.target.value })}
                  placeholder="e.g., Project Manager"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Salary Range</label>
                <input
                  type="text"
                  value={newJob.salary_range}
                  onChange={(e) => setNewJob({ ...newJob, salary_range: e.target.value })}
                  placeholder="$60K-$100K"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                />
              </div>
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <input
                  type="text"
                  value={newJob.description}
                  onChange={(e) => setNewJob({ ...newJob, description: e.target.value })}
                  placeholder="What this job involves"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Key Skills (comma separated)</label>
                <input
                  type="text"
                  value={newJob.key_skills}
                  onChange={(e) => setNewJob({ ...newJob, key_skills: e.target.value })}
                  placeholder="Leadership, Communication, Planning"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Growth Outlook</label>
                <select
                  value={newJob.growth_outlook}
                  onChange={(e) => setNewJob({ ...newJob, growth_outlook: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cyan-500"
                >
                  <option value="High">High</option>
                  <option value="Medium">Medium</option>
                  <option value="Low">Low</option>
                </select>
              </div>
            </div>
          )}
          
          <div className="flex justify-end gap-3 mt-6">
            <button onClick={() => setShowAddForm(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button
              onClick={activeTab === 'roles' ? addRole : addJob}
              className="px-4 py-2 bg-cyan-600 rounded-lg hover:bg-cyan-700"
            >
              Add {activeTab === 'roles' ? 'Role' : 'Job'}
            </button>
          </div>
        </div>
      )}

      {/* Content */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        {activeTab === 'roles' && (
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Role</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Branch</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-right text-xs font-semibold text-gray-500 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {roles.map((role) => (
                <tr key={role.id} className={!role.is_active ? 'opacity-50' : ''}>
                  <td className="px-6 py-4">
                    <div className="font-medium text-gray-900">{role.title}</div>
                    {role.description && <div className="text-sm text-gray-500">{role.description}</div>}
                  </td>
                  <td className="px-6 py-4 text-gray-600">{role.branch}</td>
                  <td className="px-6 py-4">
                    <button
                      onClick={() => toggleActive('military_roles', role.id, role.is_active)}
                      className={`text-xs px-2 py-1 rounded-full ${role.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'}`}
                    >
                      {role.is_active ? 'Active' : 'Inactive'}
                    </button>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button
                      onClick={() => deleteItem('military_roles', role.id)}
                      className="text-red-600 hover:text-red-800 text-sm"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {activeTab === 'jobs' && (
          <div className="divide-y divide-gray-200">
            {jobs.map((job) => (
              <div key={job.id} className={`p-5 ${!job.is_active ? 'opacity-50' : ''}`}>
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <h3 className="font-semibold text-gray-900">{job.title}</h3>
                      <span className={`text-xs px-2 py-1 rounded-full ${growthColors[job.growth_outlook as keyof typeof growthColors] || growthColors.Medium}`}>
                        {job.growth_outlook} Growth
                      </span>
                      <span className="text-sm font-medium text-green-600">{job.salary_range}</span>
                    </div>
                    <p className="text-sm text-gray-600 mb-2">{job.description}</p>
                    <div className="flex flex-wrap gap-1">
                      {job.key_skills?.map((skill, i) => (
                        <span key={i} className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded">
                          {skill}
                        </span>
                      ))}
                    </div>
                  </div>
                  <div className="flex items-center gap-2 ml-4">
                    <button
                      onClick={() => toggleActive('civilian_jobs', job.id, job.is_active)}
                      className={`text-xs px-2 py-1 rounded ${job.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'}`}
                    >
                      {job.is_active ? 'Active' : 'Inactive'}
                    </button>
                    <button
                      onClick={() => deleteItem('civilian_jobs', job.id)}
                      className="text-red-600 hover:text-red-800 text-sm"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
