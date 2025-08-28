import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Login from "./Login";
import Signup from "./Signup";
import ResetRequest from "./ResetRequest";
import Dashboard from "./Dashboard";
import ResetPassword from "./ResetPassword";

export default function App() {
  return (
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<Signup />} />
        <Route path="/reset-request" element={<ResetRequest />} />
        <Route path="/reset-password" element={<ResetPassword />} />
         <Route path="/reset" element={<ResetRequest />} />
        <Route path="/Dashboard" element={<Dashboard/>} />
      </Routes>
  );
}
