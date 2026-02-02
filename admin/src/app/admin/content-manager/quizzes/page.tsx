'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';

interface Quiz {
  id: string;
  slug: string;
  title: string;
  description: string;
  icon: string;
  target_audience: string;
  is_active: boolean;
}

interface QuizQuestion {
  id: string;
  quiz_id: string;
  question_text: string;
  sort_order: number;
}

interface QuizOption {
  id: string;
  question_id: string;
  option_text: string;
  result_key: string;
}

interface QuizResult {
  id: string;
  quiz_id: string;
  result_key: string;
  title: string;
  emoji: string;
  description: string;
  strengths: string[];
  growth_areas: string[];
}

export default function QuizzesContentPage() {
  const [quizzes, setQuizzes] = useState<Quiz[]>([]);
  const [questions, setQuestions] = useState<QuizQuestion[]>([]);
  const [options, setOptions] = useState<QuizOption[]>([]);
  const [results, setResults] = useState<QuizResult[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedQuiz, setSelectedQuiz] = useState<string | null>(null);
  const [showAddQuiz, setShowAddQuiz] = useState(false);
  const [newQuiz, setNewQuiz] = useState({ slug: '', title: '', description: '', target_audience: 'all' });

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    const [qzRes, qnRes, optRes, resRes] = await Promise.all([
      supabase.from('quizzes').select('*').order('created_at'),
      supabase.from('quiz_questions').select('*').order('sort_order'),
      supabase.from('quiz_options').select('*').order('sort_order'),
      supabase.from('quiz_results').select('*'),
    ]);

    if (qzRes.data) setQuizzes(qzRes.data);
    if (qnRes.data) setQuestions(qnRes.data);
    if (optRes.data) setOptions(optRes.data);
    if (resRes.data) setResults(resRes.data);
    setLoading(false);
  }

  async function addQuiz() {
    if (!newQuiz.title.trim() || !newQuiz.slug.trim()) return;
    
    await supabase.from('quizzes').insert({
      ...newQuiz,
      is_active: true,
    });
    
    fetchData();
    setNewQuiz({ slug: '', title: '', description: '', target_audience: 'all' });
    setShowAddQuiz(false);
  }

  async function deleteQuiz(id: string) {
    if (!confirm('Delete this quiz and all its questions?')) return;
    await supabase.from('quizzes').delete().eq('id', id);
    fetchData();
  }

  async function toggleActive(id: string, current: boolean) {
    await supabase.from('quizzes').update({ is_active: !current }).eq('id', id);
    fetchData();
  }

  if (loading) {
    return <div className="p-8"><div className="animate-pulse h-64 bg-gray-200 rounded"></div></div>;
  }

  const selectedQuizData = selectedQuiz ? quizzes.find(q => q.id === selectedQuiz) : null;
  const quizQuestions = questions.filter(q => q.quiz_id === selectedQuiz);
  const quizResults = results.filter(r => r.quiz_id === selectedQuiz);

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
          <h1 className="text-3xl font-bold text-gray-900">Quizzes</h1>
          <p className="text-gray-600 mt-1">Interactive quizzes like "Who Am I?"</p>
        </div>
        <button onClick={() => setShowAddQuiz(true)} className="px-4 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700">
          + Add Quiz
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        <div className="bg-indigo-50 rounded-xl p-4 border border-indigo-200">
          <div className="text-2xl font-bold text-indigo-700">{quizzes.length}</div>
          <div className="text-sm text-indigo-600">Quizzes</div>
        </div>
        <div className="bg-purple-50 rounded-xl p-4 border border-purple-200">
          <div className="text-2xl font-bold text-purple-700">{questions.length}</div>
          <div className="text-sm text-purple-600">Questions</div>
        </div>
        <div className="bg-pink-50 rounded-xl p-4 border border-pink-200">
          <div className="text-2xl font-bold text-pink-700">{options.length}</div>
          <div className="text-sm text-pink-600">Options</div>
        </div>
        <div className="bg-cyan-50 rounded-xl p-4 border border-cyan-200">
          <div className="text-2xl font-bold text-cyan-700">{results.length}</div>
          <div className="text-sm text-cyan-600">Result Types</div>
        </div>
      </div>

      {/* Add Quiz Form */}
      {showAddQuiz && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">Add New Quiz</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input type="text" value={newQuiz.slug} onChange={(e) => setNewQuiz({ ...newQuiz, slug: e.target.value })} placeholder="Slug (e.g., who-am-i)" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newQuiz.title} onChange={(e) => setNewQuiz({ ...newQuiz, title: e.target.value })} placeholder="Title" className="px-4 py-2 border rounded-lg" />
            <input type="text" value={newQuiz.description} onChange={(e) => setNewQuiz({ ...newQuiz, description: e.target.value })} placeholder="Description" className="px-4 py-2 border rounded-lg" />
            <select value={newQuiz.target_audience} onChange={(e) => setNewQuiz({ ...newQuiz, target_audience: e.target.value })} className="px-4 py-2 border rounded-lg">
              <option value="all">All</option>
              <option value="youth">Youth</option>
              <option value="military">Military</option>
              <option value="veteran">Veteran</option>
            </select>
          </div>
          <div className="flex justify-end gap-3 mt-4">
            <button onClick={() => setShowAddQuiz(false)} className="px-4 py-2 text-gray-600">Cancel</button>
            <button onClick={addQuiz} className="px-4 py-2 bg-cyan-600 text-white rounded-lg">Add Quiz</button>
          </div>
        </div>
      )}

      {/* Quizzes List */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        {quizzes.map((quiz) => (
          <div
            key={quiz.id}
            onClick={() => setSelectedQuiz(quiz.id === selectedQuiz ? null : quiz.id)}
            className={`bg-white rounded-xl shadow-sm border-2 p-5 cursor-pointer transition ${
              selectedQuiz === quiz.id ? 'border-cyan-500 ring-2 ring-cyan-200' : 'border-gray-200 hover:border-gray-300'
            } ${!quiz.is_active ? 'opacity-50' : ''}`}
          >
            <div className="flex items-start justify-between">
              <div>
                <h3 className="font-semibold text-gray-900">{quiz.title}</h3>
                <p className="text-sm text-gray-500 mt-1">{quiz.description}</p>
                <div className="flex gap-2 mt-2">
                  <span className="text-xs bg-gray-100 px-2 py-1 rounded">{quiz.slug}</span>
                  <span className="text-xs bg-indigo-100 text-indigo-700 px-2 py-1 rounded">{quiz.target_audience}</span>
                </div>
              </div>
              <div className="flex gap-1">
                <button onClick={(e) => { e.stopPropagation(); toggleActive(quiz.id, quiz.is_active); }} className={`text-xs px-2 py-1 rounded ${quiz.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100'}`}>
                  {quiz.is_active ? 'Active' : 'Inactive'}
                </button>
                <button onClick={(e) => { e.stopPropagation(); deleteQuiz(quiz.id); }} className="text-xs px-2 py-1 text-red-600">Delete</button>
              </div>
            </div>
            <div className="mt-3 pt-3 border-t text-sm text-gray-500">
              {questions.filter(q => q.quiz_id === quiz.id).length} questions • {results.filter(r => r.quiz_id === quiz.id).length} results
            </div>
          </div>
        ))}
      </div>

      {/* Selected Quiz Details */}
      {selectedQuizData && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 className="text-xl font-bold mb-4">{selectedQuizData.title} - Details</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h3 className="font-semibold text-gray-700 mb-3">Questions ({quizQuestions.length})</h3>
              {quizQuestions.map((q, i) => (
                <div key={q.id} className="bg-gray-50 rounded-lg p-3 mb-2">
                  <div className="text-sm font-medium">Q{i + 1}: {q.question_text}</div>
                  <div className="text-xs text-gray-500 mt-1">
                    {options.filter(o => o.question_id === q.id).length} options
                  </div>
                </div>
              ))}
              {quizQuestions.length === 0 && <p className="text-gray-500 text-sm">No questions yet</p>}
            </div>
            
            <div>
              <h3 className="font-semibold text-gray-700 mb-3">Result Types ({quizResults.length})</h3>
              {quizResults.map((r) => (
                <div key={r.id} className="bg-gray-50 rounded-lg p-3 mb-2">
                  <div className="flex items-center gap-2">
                    <span className="text-xl">{r.emoji}</span>
                    <span className="font-medium">{r.title}</span>
                  </div>
                  <div className="text-xs text-gray-500 mt-1">{r.result_key}</div>
                </div>
              ))}
              {quizResults.length === 0 && <p className="text-gray-500 text-sm">No results defined</p>}
            </div>
          </div>
          
          <div className="mt-4 p-4 bg-amber-50 border border-amber-200 rounded-lg">
            <p className="text-amber-700 text-sm">
              💡 To add questions, options, and results, use the Supabase dashboard or create a dedicated quiz editor.
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
