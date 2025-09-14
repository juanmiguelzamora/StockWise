import { Link } from "react-router-dom";

export default function Navbar() {
  return (
    <nav className="bg-gray-900 text-white px-6 py-3 flex justify-between items-center">
      {/* Left side: Logo */}
      <div className="text-xl font-bold">
        <Link to="/dashboard">StockWise</Link>
      </div>

      {/* Right side: Menu */}
      <div className="flex gap-6">
        <Link to="/dashboard" className="hover:text-blue-400">Dashboard</Link>
        <Link to="/users" className="hover:text-blue-400">Users</Link>
        <Link to="/settings" className="hover:text-blue-400">Settings</Link>
      </div>
    </nav>
  );
}
