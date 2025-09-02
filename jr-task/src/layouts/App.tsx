import { useState } from 'react'
import Navbar from '../components/navbar'
import Dashboard from '../pages/Dashboard'
import Inventory from '../pages/Inventory'
import AIAssistant from '../pages/AiAssistant'
import Users from '../pages/Users'
import Profile from '../pages/Profile'

export default function App() {
  const [page, setPage] = useState("dashboard");

    return (
        <div className='pt-16 h-screen w-full'>
            <Navbar setPage={setPage} />
            <main>
                {page === "dashboard" && <Dashboard />}
                {page === "inventory" && <Inventory />}
                {page === "ai-assistant" && <AIAssistant />}
                {page === "users" && <Users />}
                {page === "profile" && <Profile />}
            </main>
        </div>
    );
}