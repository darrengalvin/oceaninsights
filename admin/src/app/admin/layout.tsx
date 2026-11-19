import Sidebar from '@/components/Sidebar'
import SectionBar from '@/components/content/SectionBar'
import { ToastProvider } from '@/components/content/Toast'

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <ToastProvider>
      <div className="flex flex-col lg:flex-row min-h-screen bg-gray-50">
        <Sidebar />
        <main className="flex-1 min-w-0 overflow-auto">
          <SectionBar />
          {children}
        </main>
      </div>
    </ToastProvider>
  )
}
