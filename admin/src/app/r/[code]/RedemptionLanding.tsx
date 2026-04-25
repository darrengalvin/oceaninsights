'use client'

import { useEffect, useState } from 'react'

interface Props {
  code: string
  organizationName: string
  recipientIdentifier: string | null
  recipientName: string | null
  alreadyRedeemed: boolean
  appStoreUrl: string
  appSchemeUrl: string
}

export default function RedemptionLanding(props: Props) {
  const [copied, setCopied] = useState(false)
  const [platform, setPlatform] = useState<'ios' | 'android' | 'desktop'>('desktop')

  useEffect(() => {
    if (typeof navigator === 'undefined') return
    const ua = navigator.userAgent.toLowerCase()
    if (/iphone|ipad|ipod/.test(ua)) setPlatform('ios')
    else if (/android/.test(ua)) setPlatform('android')
  }, [])

  useEffect(() => {
    if (platform === 'ios') {
      const t = setTimeout(() => {
        window.location.href = props.appSchemeUrl
      }, 200)
      return () => clearTimeout(t)
    }
  }, [platform, props.appSchemeUrl])

  async function copyCode() {
    try {
      await navigator.clipboard.writeText(props.code)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch {
      // ignore
    }
  }

  return (
    <main className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-900 to-cyan-950 text-white">
      <div className="max-w-md mx-auto px-6 py-12">
        <div className="text-center mb-8">
          <div className="text-xs uppercase tracking-[0.2em] text-cyan-300/80 mb-2">
            Below the Surface
          </div>
          <h1 className="text-3xl font-bold leading-tight">
            {props.alreadyRedeemed
              ? "You've already activated"
              : 'Your access is ready'}
          </h1>
        </div>

        <div className="bg-gradient-to-br from-cyan-500/15 to-cyan-400/5 backdrop-blur border border-cyan-300/20 rounded-2xl p-6 mb-6">
          <div className="text-xs uppercase tracking-wider text-cyan-300/80 mb-1">
            Sponsored by
          </div>
          <div className="text-2xl font-semibold mb-4">{props.organizationName}</div>

          {props.recipientIdentifier && (
            <div className="text-sm text-slate-300 border-t border-white/10 pt-4">
              Issued to:{' '}
              <code className="bg-black/30 px-2 py-0.5 rounded text-cyan-200 font-mono">
                {props.recipientIdentifier}
              </code>
              {props.recipientName && (
                <span className="block mt-1 text-slate-400">{props.recipientName}</span>
              )}
            </div>
          )}
        </div>

        <div className="bg-white/5 backdrop-blur border border-white/10 rounded-2xl p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">
            {platform === 'ios' ? 'Activating in the app...' : 'Get the app'}
          </h2>

          {platform === 'ios' && (
            <p className="text-sm text-slate-300 mb-4">
              If the app didn't open automatically, tap below to install it from the App Store -
              your code will be ready when you open the app.
            </p>
          )}

          <a
            href={props.appStoreUrl}
            className="flex items-center justify-center gap-2 w-full bg-white text-slate-900 font-semibold rounded-xl py-3 px-4 hover:bg-slate-100 transition"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
              <path d="M17.5 12.5c0-2.4 1.9-3.5 2-3.6-1.1-1.6-2.8-1.8-3.4-1.8-1.4-.1-2.8.9-3.5.9s-1.8-.9-3-.9c-1.5 0-3 .9-3.8 2.3-1.6 2.8-.4 7 1.2 9.3.8 1.1 1.7 2.4 2.9 2.3 1.2 0 1.6-.7 3-.7s1.8.7 3 .7c1.2 0 2-1.1 2.8-2.3.9-1.3 1.2-2.6 1.3-2.7-.1 0-2.5-1-2.5-3.5zm-2.4-6.4c.6-.8 1.1-1.9 1-3-1 0-2.1.7-2.8 1.4-.6.7-1.2 1.8-1 2.9 1.1.1 2.2-.6 2.8-1.3z" />
            </svg>
            Download on the App Store
          </a>
        </div>

        <div className="bg-white/5 backdrop-blur border border-white/10 rounded-2xl p-6 mb-6">
          <div className="text-xs uppercase tracking-wider text-slate-400 mb-3">
            Your access code
          </div>
          <div className="flex items-center justify-between gap-3">
            <code className="text-xl font-mono font-bold tracking-wider text-cyan-300 select-all">
              {props.code}
            </code>
            <button
              onClick={copyCode}
              className="px-3 py-1.5 text-sm bg-cyan-500/20 hover:bg-cyan-500/30 border border-cyan-400/30 rounded-lg transition"
            >
              {copied ? 'Copied' : 'Copy'}
            </button>
          </div>
          <p className="text-xs text-slate-400 mt-3">
            Open the app, tap "I have an access code" on the paywall, and paste this in.
          </p>
        </div>

        <div className="bg-emerald-500/10 border border-emerald-400/20 rounded-2xl p-5 mb-8">
          <div className="flex items-start gap-3">
            <div className="w-8 h-8 rounded-lg bg-emerald-500/20 flex items-center justify-center flex-shrink-0">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#34d399" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <rect x="3" y="11" width="18" height="11" rx="2" />
                <path d="M7 11V7a5 5 0 0110 0v4" />
              </svg>
            </div>
            <div className="text-sm">
              <div className="font-semibold text-emerald-100 mb-1">Your privacy is protected</div>
              <div className="text-emerald-100/80 leading-relaxed">
                <strong>{props.organizationName}</strong> will never see what you do in this app.
                They paid for your access - that's it.
              </div>
            </div>
          </div>
        </div>

        <p className="text-center text-xs text-slate-400 leading-relaxed">
          This code is for you alone. Sharing it with others is against your sponsor's terms
          and may result in your access being revoked.
        </p>
      </div>
    </main>
  )
}
