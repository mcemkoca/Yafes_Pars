import { Outlet } from 'react-router-dom'
import Navbar from './Navbar'
import TopBar from './TopBar'
import Footer from './Footer'

export default function Layout() {
  return (
    <div className="flex h-screen w-screen overflow-hidden" style={{ backgroundColor: '#F2F4F6' }}>
      {/* Sidebar */}
      <Navbar />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <TopBar />
        <main
          className="flex-1 overflow-auto"
          style={{ padding: '32px', backgroundColor: '#F2F4F6' }}
        >
          <Outlet />
        </main>
        <Footer />
      </div>
    </div>
  )
}
