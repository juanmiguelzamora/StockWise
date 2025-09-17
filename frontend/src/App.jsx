import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Signup from "./pages/Signup";
import ResetRequest from "./pages/ResetRequest";
import Dashboard from "./pages/Dashboard";
import ResetPassword from "./pages/ResetPassword";
import User from "./layout/user";


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
      </Routes>
  );
}

