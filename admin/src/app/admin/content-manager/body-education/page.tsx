'use client';

import { useState, useEffect } from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Link from 'next/link';

interface BodyTopic {
  id: string;
  tab: 'female' | 'male';
  title: string;
  subtitle: string;
  emoji: string;
  colour: string;
  content: string;
  normal_range: string | null;
  sort_order: number;
  is_active: boolean;
}

interface QuizQuestion {
  id: string;
  statement: string;
  is_fact: boolean;
  explanation: string;
  sort_order: number;
  is_active: boolean;
}

type TabType = 'female' | 'male' | 'quiz';

export default function BodyEducationPage() {
  const [activeTab, setActiveTab] = useState<TabType>('female');
  const [topics, setTopics] = useState<BodyTopic[]>([]);
  const [quiz, setQuiz] = useState<QuizQuestion[]>([]);
  const [loading, setLoading] = useState(true);

  const [showAddTopic, setShowAddTopic] = useState(false);
  const [showAddQuiz, setShowAddQuiz] = useState(false);
  const [editingTopic, setEditingTopic] = useState<BodyTopic | null>(null);
  const [editingQuiz, setEditingQuiz] = useState<QuizQuestion | null>(null);

  const [newTopic, setNewTopic] = useState({
    tab: 'female' as 'female' | 'male', title: '', subtitle: '', emoji: '📘',
    colour: '#60A5FA', content: '', normal_range: '',
  });
  const [newQuiz, setNewQuiz] = useState({
    statement: '', is_fact: true, explanation: '',
  });

  useEffect(() => { fetchAll(); }, []);

  async function fetchAll() {
    setLoading(true);
    const [topicsRes, quizRes] = await Promise.all([
      supabaseAdmin.from('body_education_topics').select('*').order('sort_order'),
      supabaseAdmin.from('body_education_quiz').select('*').order('sort_order'),
    ]);
    if (topicsRes.data) setTopics(topicsRes.data);
    if (quizRes.data) setQuiz(quizRes.data);
    setLoading(false);
  }

  async function saveTopic() {
    const data = editingTopic || newTopic;
    if (!data.title.trim() || !data.content.trim()) return;

    const payload = {
      tab: data.tab,
      title: data.title,
      subtitle: data.subtitle,
      emoji: data.emoji,
      colour: data.colour,
      content: data.content,
      normal_range: data.normal_range || null,
      sort_order: editingTopic ? editingTopic.sort_order : topics.filter(t => t.tab === data.tab).length,
      is_active: editingTopic ? editingTopic.is_active : true,
    };

    if (editingTopic) {
      await supabaseAdmin.from('body_education_topics').update(payload).eq('id', editingTopic.id);
    } else {
      await supabaseAdmin.from('body_education_topics').insert(payload);
    }

    fetchAll();
    setEditingTopic(null);
    setShowAddTopic(false);
    setNewTopic({ tab: 'female', title: '', subtitle: '', emoji: '📘', colour: '#60A5FA', content: '', normal_range: '' });
  }

  async function saveQuiz() {
    const data = editingQuiz || newQuiz;
    if (!data.statement.trim() || !data.explanation.trim()) return;

    const payload = {
      statement: data.statement,
      is_fact: data.is_fact,
      explanation: data.explanation,
      sort_order: editingQuiz ? editingQuiz.sort_order : quiz.length,
      is_active: editingQuiz ? editingQuiz.is_active : true,
    };

    if (editingQuiz) {
      await supabaseAdmin.from('body_education_quiz').update(payload).eq('id', editingQuiz.id);
    } else {
      await supabaseAdmin.from('body_education_quiz').insert(payload);
    }

    fetchAll();
    setEditingQuiz(null);
    setShowAddQuiz(false);
    setNewQuiz({ statement: '', is_fact: true, explanation: '' });
  }

  async function toggleActive(table: string, id: string, current: boolean) {
    await supabaseAdmin.from(table).update({ is_active: !current }).eq('id', id);
    fetchAll();
  }

  async function deleteItem(table: string, id: string, label: string) {
    if (!confirm(`Delete "${label}"?`)) return;
    await supabaseAdmin.from(table).delete().eq('id', id);
    fetchAll();
  }

  if (loading) {
    return <div className="p-8"><div className="animate-pulse h-64 bg-gray-200 rounded"></div></div>;
  }

  const femaleTopics = topics.filter(t => t.tab === 'female');
  const maleTopics = topics.filter(t => t.tab === 'male');

  const tabs = [
    { id: 'female' as const, label: 'Female Body', count: femaleTopics.length, icon: '♀️' },
    { id: 'male' as const, label: 'Male Body', count: maleTopics.length, icon: '♂️' },
    { id: 'quiz' as const, label: 'Myth or Fact Quiz', count: quiz.length, icon: '❓' },
  ];

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <Link href="/admin/content-manager" className="text-cyan-600 hover:text-cyan-800 text-sm flex items-center gap-1">
          ← Back to Content Manager
        </Link>
      </div>

      <div className="mb-8">
        <div className="flex items-center gap-3 mb-2">
          <span className="text-3xl">🧬</span>
          <h1 className="text-3xl font-bold text-gray-900">Body Education</h1>
        </div>
        <p className="text-gray-600">Manage puberty & body education content for young people.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mb-6">
        {tabs.map(t => (
          <div key={t.id} className="bg-white rounded-xl p-4 border border-gray-200">
            <div className="text-2xl font-bold text-gray-900">{t.count}</div>
            <div className="text-sm text-gray-500">{t.icon} {t.label}</div>
          </div>
        ))}
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-6">
        {tabs.map(t => (
          <button
            key={t.id}
            onClick={() => setActiveTab(t.id)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition ${
              activeTab === t.id ? 'bg-cyan-600 text-white' : 'bg-white text-gray-600 border hover:bg-gray-50'
            }`}
          >
            {t.icon} {t.label} ({t.count})
          </button>
        ))}
      </div>

      {/* Content */}
      {(activeTab === 'female' || activeTab === 'male') && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">{activeTab === 'female' ? '♀️ Female' : '♂️ Male'} Body Topics</h2>
            <button
              onClick={() => { setNewTopic({ ...newTopic, tab: activeTab }); setShowAddTopic(true); setEditingTopic(null); }}
              className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700"
            >
              + Add Topic
            </button>
          </div>

          {(showAddTopic || editingTopic) && (
            <div className="bg-white border rounded-xl p-6 mb-4 space-y-4">
              <h3 className="font-semibold">{editingTopic ? 'Edit' : 'Add'} Topic</h3>
              <div className="grid grid-cols-2 gap-4">
                <input placeholder="Title" value={editingTopic?.title ?? newTopic.title}
                  onChange={e => editingTopic ? setEditingTopic({...editingTopic, title: e.target.value}) : setNewTopic({...newTopic, title: e.target.value})}
                  className="border rounded-lg px-3 py-2 text-sm" />
                <input placeholder="Subtitle" value={editingTopic?.subtitle ?? newTopic.subtitle}
                  onChange={e => editingTopic ? setEditingTopic({...editingTopic, subtitle: e.target.value}) : setNewTopic({...newTopic, subtitle: e.target.value})}
                  className="border rounded-lg px-3 py-2 text-sm" />
                <input placeholder="Emoji" value={editingTopic?.emoji ?? newTopic.emoji}
                  onChange={e => editingTopic ? setEditingTopic({...editingTopic, emoji: e.target.value}) : setNewTopic({...newTopic, emoji: e.target.value})}
                  className="border rounded-lg px-3 py-2 text-sm w-20" />
                <input placeholder="Colour (#hex)" value={editingTopic?.colour ?? newTopic.colour}
                  onChange={e => editingTopic ? setEditingTopic({...editingTopic, colour: e.target.value}) : setNewTopic({...newTopic, colour: e.target.value})}
                  className="border rounded-lg px-3 py-2 text-sm" />
              </div>
              <textarea placeholder="Main content (use \n for line breaks)" rows={6}
                value={editingTopic?.content ?? newTopic.content}
                onChange={e => editingTopic ? setEditingTopic({...editingTopic, content: e.target.value}) : setNewTopic({...newTopic, content: e.target.value})}
                className="border rounded-lg px-3 py-2 text-sm w-full" />
              <input placeholder="Normal range note (optional)" value={editingTopic?.normal_range ?? newTopic.normal_range}
                onChange={e => editingTopic ? setEditingTopic({...editingTopic, normal_range: e.target.value}) : setNewTopic({...newTopic, normal_range: e.target.value})}
                className="border rounded-lg px-3 py-2 text-sm w-full" />
              <div className="flex gap-2">
                <button onClick={saveTopic} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
                <button onClick={() => { setShowAddTopic(false); setEditingTopic(null); }} className="bg-gray-200 px-4 py-2 rounded-lg text-sm">Cancel</button>
              </div>
            </div>
          )}

          <div className="space-y-3">
            {(activeTab === 'female' ? femaleTopics : maleTopics).map(topic => (
              <div key={topic.id} className={`bg-white border rounded-xl p-4 ${!topic.is_active ? 'opacity-50' : ''}`}>
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    <span className="text-2xl">{topic.emoji}</span>
                    <div>
                      <h3 className="font-semibold text-gray-900">{topic.title}</h3>
                      <p className="text-sm text-gray-500">{topic.subtitle}</p>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => { setEditingTopic(topic); setShowAddTopic(false); }} className="text-cyan-600 text-sm hover:underline">Edit</button>
                    <button onClick={() => toggleActive('body_education_topics', topic.id, topic.is_active)} className="text-sm text-gray-500 hover:underline">
                      {topic.is_active ? 'Disable' : 'Enable'}
                    </button>
                    <button onClick={() => deleteItem('body_education_topics', topic.id, topic.title)} className="text-red-500 text-sm hover:underline">Delete</button>
                  </div>
                </div>
                <p className="text-sm text-gray-600 mt-2 line-clamp-2">{topic.content}</p>
                {topic.normal_range && <p className="text-xs text-gray-400 mt-1 italic">{topic.normal_range}</p>}
              </div>
            ))}
          </div>
        </div>
      )}

      {activeTab === 'quiz' && (
        <div>
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">❓ Myth or Fact Quiz Questions</h2>
            <button
              onClick={() => { setShowAddQuiz(true); setEditingQuiz(null); }}
              className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700"
            >
              + Add Question
            </button>
          </div>

          {(showAddQuiz || editingQuiz) && (
            <div className="bg-white border rounded-xl p-6 mb-4 space-y-4">
              <h3 className="font-semibold">{editingQuiz ? 'Edit' : 'Add'} Question</h3>
              <input placeholder="Statement" value={editingQuiz?.statement ?? newQuiz.statement}
                onChange={e => editingQuiz ? setEditingQuiz({...editingQuiz, statement: e.target.value}) : setNewQuiz({...newQuiz, statement: e.target.value})}
                className="border rounded-lg px-3 py-2 text-sm w-full" />
              <div className="flex items-center gap-4">
                <label className="flex items-center gap-2 text-sm">
                  <input type="radio" checked={editingQuiz ? editingQuiz.is_fact : newQuiz.is_fact}
                    onChange={() => editingQuiz ? setEditingQuiz({...editingQuiz, is_fact: true}) : setNewQuiz({...newQuiz, is_fact: true})} />
                  Fact ✅
                </label>
                <label className="flex items-center gap-2 text-sm">
                  <input type="radio" checked={editingQuiz ? !editingQuiz.is_fact : !newQuiz.is_fact}
                    onChange={() => editingQuiz ? setEditingQuiz({...editingQuiz, is_fact: false}) : setNewQuiz({...newQuiz, is_fact: false})} />
                  Myth ❌
                </label>
              </div>
              <textarea placeholder="Explanation (shown after answering)" rows={3}
                value={editingQuiz?.explanation ?? newQuiz.explanation}
                onChange={e => editingQuiz ? setEditingQuiz({...editingQuiz, explanation: e.target.value}) : setNewQuiz({...newQuiz, explanation: e.target.value})}
                className="border rounded-lg px-3 py-2 text-sm w-full" />
              <div className="flex gap-2">
                <button onClick={saveQuiz} className="bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm">Save</button>
                <button onClick={() => { setShowAddQuiz(false); setEditingQuiz(null); }} className="bg-gray-200 px-4 py-2 rounded-lg text-sm">Cancel</button>
              </div>
            </div>
          )}

          <div className="space-y-3">
            {quiz.map((q, i) => (
              <div key={q.id} className={`bg-white border rounded-xl p-4 ${!q.is_active ? 'opacity-50' : ''}`}>
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-medium text-gray-400">Q{i + 1}</span>
                      <span className={`text-xs px-2 py-0.5 rounded ${q.is_fact ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                        {q.is_fact ? 'FACT' : 'MYTH'}
                      </span>
                    </div>
                    <p className="font-medium text-gray-900 mt-1">{q.statement}</p>
                    <p className="text-sm text-gray-500 mt-1">{q.explanation}</p>
                  </div>
                  <div className="flex gap-2 ml-4">
                    <button onClick={() => { setEditingQuiz(q); setShowAddQuiz(false); }} className="text-cyan-600 text-sm hover:underline">Edit</button>
                    <button onClick={() => toggleActive('body_education_quiz', q.id, q.is_active)} className="text-sm text-gray-500 hover:underline">
                      {q.is_active ? 'Disable' : 'Enable'}
                    </button>
                    <button onClick={() => deleteItem('body_education_quiz', q.id, q.statement.slice(0, 30))} className="text-red-500 text-sm hover:underline">Delete</button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
