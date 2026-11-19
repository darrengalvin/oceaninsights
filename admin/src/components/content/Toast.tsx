'use client'

import { createContext, useCallback, useContext, useState } from 'react'
import { CheckCircle2, XCircle, X } from 'lucide-react'

type Kind = 'success' | 'error'
interface Item { id: number; kind: Kind; text: string }
interface Api { success: (text: string) => void; error: (text: string) => void }

const Ctx = createContext<Api | null>(null)

// Small, consistent "Saved" / "Not saved" messages, so a failed save is
// never silent. Errors stay until dismissed; successes fade after 4 seconds.
export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [items, setItems] = useState<Item[]>([])
  const dismiss = (id: number) => setItems((xs) => xs.filter((x) => x.id !== id))
  const push = useCallback((kind: Kind, text: string) => {
    const id = Date.now() + Math.random()
    setItems((xs) => [...xs, { id, kind, text }])
    if (kind === 'success') setTimeout(() => dismiss(id), 4000)
  }, [])
  const api: Api = { success: (t) => push('success', t), error: (t) => push('error', t) }

  return (
    <Ctx.Provider value={api}>
      {children}
      <div className="fixed bottom-4 right-4 left-4 sm:left-auto z-[100] flex flex-col gap-2 sm:w-96" aria-live="polite">
        {items.map((t) => (
          <div
            key={t.id}
            role={t.kind === 'error' ? 'alert' : 'status'}
            className={`flex items-start gap-3 p-3 rounded-xl shadow-lg border text-sm ${
              t.kind === 'success' ? 'bg-white border-green-200 text-gray-900' : 'bg-red-50 border-red-200 text-red-900'
            }`}
          >
            {t.kind === 'success' ? <CheckCircle2 className="w-5 h-5 text-green-600 flex-shrink-0" /> : <XCircle className="w-5 h-5 text-red-600 flex-shrink-0" />}
            <p className="flex-1">{t.text}</p>
            <button onClick={() => dismiss(t.id)} aria-label="Dismiss" className="text-gray-400 hover:text-gray-700"><X className="w-4 h-4" /></button>
          </div>
        ))}
      </div>
    </Ctx.Provider>
  )
}

export function useToast(): Api {
  const ctx = useContext(Ctx)
  if (ctx) return ctx
  // Outside a provider, fall back to the browser's own message box.
  return { success: () => {}, error: (t) => window.alert(t) }
}
