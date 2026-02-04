'use client'

import Link from 'next/link'
import Image from 'next/image'
import { 
  Waves, 
  ArrowRight,
  Smartphone,
  ChevronDown,
  Shield,
  Eye,
  MapPin,
  Camera,
  Mic,
  Wifi,
  MessageSquare,
  Cpu,
  Server,
  User,
  Cloud,
  Bell
} from 'lucide-react'

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-[#8E99AB]">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 bg-[#8E99AB]/90 backdrop-blur-md">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-2">
              <Waves className="w-8 h-8 text-slate-700" />
              <span className="text-xl font-bold text-slate-800">Ocean Insight</span>
            </div>
            <div className="flex items-center gap-4">
              <Link 
                href="/admin" 
                className="text-sm text-slate-600 hover:text-slate-800 transition-colors"
              >
                Admin
              </Link>
              <a 
                href="#download" 
                className="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white text-sm font-medium rounded-full transition-colors"
              >
                Download App
              </a>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-20 pb-4 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-white mb-3 leading-tight drop-shadow-lg">
            Dive Deep Within
          </h1>
          
          <p className="text-lg sm:text-xl text-slate-700 mb-6 max-w-2xl mx-auto">
            Mental wellness grounded in military principles. Built for those who serve—submarines, deployments, and beyond.
          </p>
          
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-4">
            <a 
              href="#download" 
              className="flex items-center gap-2 px-8 py-4 bg-slate-800 hover:bg-slate-900 text-white font-semibold rounded-full transition-all transform hover:scale-105 shadow-lg"
            >
              <Smartphone className="w-5 h-5" />
              Download for iOS
            </a>
            <a 
              href="#features" 
              className="flex items-center gap-2 px-8 py-4 bg-white/20 hover:bg-white/30 text-slate-800 font-semibold rounded-full transition-colors backdrop-blur-sm"
            >
              Learn More
              <ArrowRight className="w-5 h-5" />
            </a>
          </div>

        </div>
      </section>

      {/* App Screenshots Carousel */}
      <section id="features" className="py-12 px-4 sm:px-6 lg:px-8 overflow-hidden">
        <div className="max-w-7xl mx-auto">
          {/* Scrolling screenshots */}
          <div className="flex gap-6 overflow-x-auto pb-8 snap-x snap-mandatory scrollbar-hide" style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}>
            {[
              { src: '/screenshots/01-rituals.png', alt: 'Daily Wellness Rituals' },
              { src: '/screenshots/02-breathing.png', alt: 'Breathing Techniques' },
              { src: '/screenshots/03-affirmations.png', alt: 'Positive Affirmations' },
              { src: '/screenshots/04-sounds.png', alt: 'Calming Soundscapes' },
              { src: '/screenshots/06-privacy.png', alt: 'Privacy First' },
              { src: '/screenshots/07-training.png', alt: 'Decision Training' },
              { src: '/screenshots/08-home.png', alt: 'Align Yourself' },
            ].map((screenshot, index) => (
              <div 
                key={index}
                className="flex-shrink-0 w-72 sm:w-80 snap-center"
              >
                <Image 
                  src={screenshot.src}
                  alt={screenshot.alt}
                  width={400}
                  height={800}
                  className="w-full h-auto rounded-2xl shadow-2xl"
                />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* OPSEC Section */}
      <section className="py-20 px-4 sm:px-6 lg:px-8 bg-[#5C6778]">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-12">
            <div className="inline-flex items-center gap-2 px-4 py-2 bg-emerald-400/20 rounded-full mb-6">
              <Shield className="w-5 h-5 text-emerald-300" />
              <span className="text-sm font-medium text-emerald-300">OPSEC Compliant</span>
            </div>
            <h2 className="text-3xl sm:text-4xl font-bold text-white mb-4">
              Military-Grade Privacy
            </h2>
            <p className="text-slate-200 max-w-2xl mx-auto">
              Designed for operational security. This app knows nothing about you, 
              and that's exactly how it should be.
            </p>
          </div>
          
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <User className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">Doesn't know who you are</h3>
                <p className="text-sm text-slate-300">No account, no sign-up, no personal data collected. Ever.</p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <MapPin className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">Doesn't know where you are</h3>
                <p className="text-sm text-slate-300">No GPS, no location tracking, no geolocation of any kind.</p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <Camera className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">Cannot see through your camera</h3>
                <p className="text-sm text-slate-300">Zero camera permissions. The app never requests camera access.</p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <Mic className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">Cannot hear through your microphone</h3>
                <p className="text-sm text-slate-300">Zero microphone permissions. No audio recording capability.</p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <Server className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">Not linked to any servers</h3>
                <p className="text-sm text-slate-300">No backend servers storing your data. Everything stays on device.</p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <MessageSquare className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">No text input</h3>
                <p className="text-sm text-slate-300">You cannot type anything into this app. No journals, no chat, no input.</p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <Cpu className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">No AI</h3>
                <p className="text-sm text-slate-300">No artificial intelligence, no machine learning, no data analysis.</p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <Wifi className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">Works completely offline</h3>
                <p className="text-sm text-slate-300">No internet connection required. Works in airplane mode indefinitely.</p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <Eye className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">No tracking or analytics</h3>
                <p className="text-sm text-slate-300">No third-party trackers, no usage analytics, no telemetry.</p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <Cloud className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">No cloud sync</h3>
                <p className="text-sm text-slate-300">Your data never leaves your device. Nothing uploaded anywhere.</p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <Bell className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">No push notifications</h3>
                <p className="text-sm text-slate-300">Nothing that could reveal app content on your lock screen.</p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-white/10 rounded-xl border border-white/20">
              <div className="flex-shrink-0 w-10 h-10 bg-emerald-400/20 rounded-lg flex items-center justify-center">
                <Shield className="w-5 h-5 text-emerald-300" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">Safe for secure environments</h3>
                <p className="text-sm text-slate-300">Designed to be acceptable in classified and sensitive locations.</p>
              </div>
            </div>
          </div>

          <div className="mt-12 text-center">
            <p className="text-white/80 text-sm max-w-xl mx-auto">
              Ocean Insight was built by someone who understands operational security. 
              Your mental health tools should never compromise your safety or mission.
            </p>
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="py-16 px-4 sm:px-6 lg:px-8 bg-[#7D8899]">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-3xl sm:text-4xl font-bold text-white mb-4 drop-shadow">
              Built for Those Who Serve
            </h2>
            <p className="text-slate-200 max-w-2xl mx-auto">
              Every feature designed with military discipline and evidence-based psychology.
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              { title: 'Daily Rituals', desc: 'Structured routines for mental strength' },
              { title: 'Breathing', desc: 'Combat-proven stress relief techniques' },
              { title: 'Affirmations', desc: 'Start each day with purpose' },
              { title: 'Soundscapes', desc: 'Calming audio for any environment' },
              { title: 'Decision Training', desc: 'Sharpen judgment under pressure' },
              { title: 'Zen Garden', desc: 'Mindful escape in moments' },
              { title: 'Works Offline', desc: 'No internet required' },
              { title: 'Privacy First', desc: 'Your data stays on your device' },
            ].map((feature, index) => (
              <div 
                key={index}
                className="bg-white/10 backdrop-blur-sm rounded-xl p-6 hover:bg-white/20 transition-colors"
              >
                <h3 className="text-lg font-semibold text-white mb-2">{feature.title}</h3>
                <p className="text-slate-300 text-sm">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Who It's For */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-6xl mx-auto">
          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="w-20 h-20 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-3xl">⚓</span>
              </div>
              <h3 className="text-xl font-semibold text-slate-800 mb-2">Submarine Crews</h3>
              <p className="text-slate-600">
                Purpose-built for life underwater. Manage stress in confined spaces on long deployments.
              </p>
            </div>

            <div className="text-center">
              <div className="w-20 h-20 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-3xl">🛡️</span>
              </div>
              <h3 className="text-xl font-semibold text-slate-800 mb-2">Deployed Personnel</h3>
              <p className="text-slate-600">
                Works completely offline. Access mental health tools anywhere in the world.
              </p>
            </div>

            <div className="text-center">
              <div className="w-20 h-20 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-3xl">🎖️</span>
              </div>
              <h3 className="text-xl font-semibold text-slate-800 mb-2">Veterans</h3>
              <p className="text-slate-600">
                Transition with strength. Military discipline applied to civilian mental wellness.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Pricing */}
      <section className="py-16 px-4 sm:px-6 lg:px-8 bg-white/10">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-3xl font-bold text-slate-800 mb-4">
            Simple, Affordable Pricing
          </h2>
          <p className="text-slate-600 mb-8 max-w-2xl mx-auto">
            Full access to all features. No hidden costs. Cancel anytime.
          </p>
          <div className="flex flex-wrap justify-center gap-6">
            <div className="bg-white/40 backdrop-blur-sm rounded-2xl p-6 min-w-[200px]">
              <p className="text-slate-500 text-sm mb-1">Monthly</p>
              <p className="text-3xl font-bold text-slate-800">£4.99<span className="text-base font-normal text-slate-500">/month</span></p>
            </div>
            <div className="bg-white/40 backdrop-blur-sm rounded-2xl p-6 min-w-[200px] border-2 border-slate-600">
              <p className="text-slate-500 text-sm mb-1">Yearly <span className="text-emerald-600 font-medium">(Save 58%)</span></p>
              <p className="text-3xl font-bold text-slate-800">£24.99<span className="text-base font-normal text-slate-500">/year</span></p>
            </div>
          </div>
          <p className="mt-6 text-sm text-slate-500">
            In-app purchase via App Store
          </p>
        </div>
      </section>

      {/* Download Section */}
      <section id="download" className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-3xl sm:text-4xl font-bold text-white mb-6 drop-shadow">
            Ready to Dive Deep?
          </h2>
          <p className="text-slate-700 mb-10 max-w-xl mx-auto">
            Download Ocean Insight and start building mental resilience grounded in military discipline.
          </p>
          
          <a 
            href="https://apps.apple.com" 
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-3 px-8 py-4 bg-black text-white font-semibold rounded-xl hover:bg-gray-900 transition-colors shadow-lg"
          >
            <svg className="w-8 h-8" viewBox="0 0 24 24" fill="currentColor">
              <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
            </svg>
            <div className="text-left">
              <div className="text-xs opacity-80">Download on the</div>
              <div className="text-lg font-semibold">App Store</div>
            </div>
          </a>
          
          <p className="mt-6 text-sm text-slate-600">
            Available on iOS. Android coming soon.
          </p>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-8 px-4 sm:px-6 lg:px-8 border-t border-white/20">
        <div className="max-w-6xl mx-auto">
          <div className="flex flex-col md:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-2">
              <Waves className="w-6 h-6 text-slate-700" />
              <span className="text-slate-800 font-semibold">Ocean Insight</span>
            </div>
            
            <div className="flex items-center gap-6 text-sm text-slate-600">
              <Link href="/privacy" className="hover:text-slate-800 transition-colors">
                Privacy Policy
              </Link>
              <Link href="/terms" className="hover:text-slate-800 transition-colors">
                Terms of Service
              </Link>
              <Link href="/admin" className="hover:text-slate-800 transition-colors">
                Admin
              </Link>
            </div>
            
            <p className="text-sm text-slate-600">
              © {new Date().getFullYear()} Ocean Insight
            </p>
          </div>
        </div>
      </footer>
    </div>
  )
}
