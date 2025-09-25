import { Link, useLocation, useNavigate } from "react-router-dom";
import { useState, useEffect, useRef } from "react";
import { motion } from "framer-motion";
import ExitIcon from "../assets/Exit.png";
import TopLogo from "../assets/toplogo.png";

const navItems = [
  { key: "dashboard", label: "Dashboard", path: "/dashboard" },
  { key: "inventory", label: "Inventory", path: "/inventory" },
  { key: "ai-assistant", label: "AI Assistant", path: "/ai-assistant" },
  { key: "users", label: "Users", path: "/users" },
  { key: "profile", label: "Profile", path: "/profile" },
];

export default function Navbar() {
  const location = useLocation();
  const navigate = useNavigate();
  const [active, setActive] = useState("dashboard");
  const [isOpen, setIsOpen] = useState(false);
  const [pill, setPill] = useState({ left: 0, width: 0, opacity: 0 });
  const refs = useRef({});

  // Set active page and initialize pill
  useEffect(() => {
    const current = navItems.find((item) => item.path === location.pathname);
    if (current) setActive(current.key);

    // Delay to ensure refs are available
    setTimeout(() => {
      const el = refs.current[current?.key];
      if (el) {
        setPill({ left: el.offsetLeft, width: el.offsetWidth, opacity: 1 });
      }
    }, 50);
  }, [location]);

  const handleLogout = () => {
    localStorage.removeItem("access");
    localStorage.removeItem("refresh");
    navigate("/login");
  };

  const handleMouseEnter = (key) => {
    const el = refs.current[key];
    if (!el) return;
    setPill({ left: el.offsetLeft, width: el.offsetWidth, opacity: 1 });
  };

  const handleMouseLeave = () => {
    const el = refs.current[active];
    if (!el) return;
    setPill({ left: el.offsetLeft, width: el.offsetWidth, opacity: 1 });
  };

  return (
    <header className="fixed top-0 left-0 w-full z-50  shadow-none">
      <div className="max-w-6xl mx-auto flex items-center justify-between h-16 px-4">
        {/* Left: Logo */}
       <Link to="/dashboard" className="flex items-center no-underline">
  <img 
    src={TopLogo} 
    alt="Logo" 
    className="h-20 w-auto flex-shrink-0 " 
  />
</Link>
        {/* Center: Nav items */}
        <nav className="hidden md:flex flex-1 justify-center">
  <ul
    className="relative flex items-center gap-6 px-6 py-2 bg-white rounded-full shadow"
    onMouseLeave={handleMouseLeave}
  >
    {navItems.map((item) => (
      <li
        key={item.key}
        ref={(el) => (refs.current[item.key] = el)}
        onMouseEnter={() => handleMouseEnter(item.key)}
        className="relative z-10 cursor-pointer text-sm font-medium transition-colors duration-200"
      >
        <Link
          to={item.path}
          className={`block px-4 py-2 rounded-full ${
            active === item.key
              ? "text-slate-600"
              : "text-gray-600 hover:text-gray-900"
          }`}
          onClick={() => setActive(item.key)}
        >
          {item.label}
        </Link>
      </li>
    ))}

    {/* Sliding pill */}
    <motion.li
      className="absolute z-0 h-10 top-1/2 -translate-y-1/2 rounded-full bg-blue-500"
      animate={{
        left: pill.left,
        width: pill.width,
        opacity: pill.opacity,
      }}
      transition={{ type: "spring", stiffness: 300, damping: 30 }}
    />
  </ul>
</nav>


        {/* Right: Logout */}
        <button
          onClick={handleLogout}
          className="hidden md:flex w-9 h-9 items-center justify-center rounded-full cursor-pointer hover:bg-red-100 transition"
          title="Logout"
        >
          <img src={ExitIcon} alt="Exit" className="h-5 w-5" />
        </button>

        {/* Mobile Hamburger */}
        <button
          onClick={() => setIsOpen(!isOpen)}
          className="md:hidden flex flex-col gap-1 w-8 h-8 justify-center items-center"
        >
          <span className="w-6 h-0.5 bg-gray-700"></span>
          <span className="w-6 h-0.5 bg-gray-700"></span>
          <span className="w-6 h-0.5 bg-gray-700"></span>
        </button>
      </div>

      {/* Mobile Dropdown */}
      {isOpen && (
        <div className="md:hidden bg-white shadow px-4 py-3">
          <ul className="flex flex-col gap-2">
            {navItems.map((item) => (
              <li key={item.key}>
                <Link
                  to={item.path}
                  onClick={() => {
                    setIsOpen(false);
                    setActive(item.key);
                  }}
                  className={`block px-4 py-2 rounded-lg font-medium text-sm transition-all duration-200 ${
                    active === item.key
                      ? "bg-blue-500 text-white"
                      : "text-gray-600 hover:text-gray-900"
                  }`}
                >
                  {item.label}
                </Link>
              </li>
            ))}
            <li>
              <button
                onClick={() => {
                  setIsOpen(false);
                  handleLogout();
                }}
                className="flex items-center gap-2 px-4 py-2 rounded-lg font-medium text-sm text-red-600 hover:bg-red-50 transition"
              >
                <img src={ExitIcon} alt="Exit" className="h-5 w-5" />
                Logout
              </button>
            </li>
          </ul>
        </div>
      )}
    </header>
  );
}
