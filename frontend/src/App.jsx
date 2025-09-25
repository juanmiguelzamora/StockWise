import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Signup from "./pages/Signup";
import ResetRequest from "./pages/ResetRequest";
import Dashboard from "./pages/Dashboard";
import ResetPassword from "./pages/ResetPassword";
import Profile from "./pages/Profile";
import Inventory from "./pages/Inventory";
import AIAssistant from "./pages/AiAssistant";
import User from "./pages/user";


export default function App() {
  return (
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<Signup />} />
        <Route path="/reset-request" element={<ResetRequest />} />
        <Route path="/reset-password" element={<ResetPassword />} />
         <Route path="/reset" element={<ResetRequest />} />
        <Route path="/dashboard" element={<Dashboard/>} />
         <Route path="/users" element={<User />} />
        <Route path="/profile" element={<Profile />} />
        <Route path="/inventory" element={<Inventory />} />
        <Route path="/ai-assistant" element={<AIAssistant />} />
      </Routes>
  );
}

