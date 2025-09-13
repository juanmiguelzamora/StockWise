import { useState } from "react";

type NavbarProps = {
  readonly setPage: (page: string) => void;
};

const navItems = [
  { key: "dashboard", label: "Dashboard" },
  { key: "inventory", label: "Inventory" },
  { key: "ai-assistant", label: "AI Assistant" },
  { key: "users", label: "Users" },
  { key: "profile", label: "Profile" },
];

export default function Navbar({ setPage }: NavbarProps) {
  const [active, setActive] = useState<string>("dashboard");

  const handleClick = (key: string) => {
    setActive(key);
    setPage(key);
  };

  return (
    <header
      style={{
        width: "100%",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        position: "fixed",
        top: 0,
        left: 0,
        background: "#ffffff",
        zIndex: 1000,
        padding: "0.55rem 0",
      }}
    >
      <div
        style={{
          display: "flex",
          alignItems: "center",
          width: "100%",
          maxWidth: 1200,
          justifyContent: "space-between",
          padding: "0 2rem",
        }}
      >
        {/* Logo */}
        <a
          href="/"
          style={{
            display: "flex",
            alignItems: "center",
            textDecoration: "none",
          }}
        >
          <img src="/src/assets/Logo.png" alt="Logo" style={{ height: "60px" }} />
        </a>

        {/* Navigation */}
        <nav>
          <ul
            style={{
              display: "flex",
              alignItems: "center",
              gap: "0.5rem",
              listStyle: "none",
              margin: 0,
              padding: "0.25rem",
              backgroundColor: "#ffffff",
              borderRadius: "9999px",
              boxShadow: "0 2px 6px rgba(0, 0, 0, 0.05)",
            }}
          >
            {navItems.map((item) => (
              <li key={item.key}>
                <button
                  type="button"
                  onClick={() => handleClick(item.key)}
                  style={{
                    backgroundColor: active === item.key ? "#3b82f6" : "transparent", // blue-500
                    color: active === item.key ? "#ffffff" : "#6b7280", // gray-500
                    fontFamily: "Sf Pro Text, sans-serif",
                    textDecoration: "none",
                    fontWeight: "bold",
                    border: "none",
                    fontSize: "0.95rem",
                    cursor: "pointer",
                    padding: "0.5rem 1rem",
                    borderRadius: "9999px",
                    transition: "all 0.2s ease-in-out",
                  }}
                >
                  {item.label}
                </button>
              </li>
            ))}
          </ul>
        </nav>

        {/* Exit Button */}
        <button
          type="button"
          style={{
            width: "36px",
            height: "36px",
            background: "#fee2e2",
            border: "none",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            borderRadius: "8px",
            cursor: "pointer",
          }}
          title="Exit"
        >
            <img src="/src/assets/Exit.png" alt="Exit" style={{ height: "20px", width: "20px" }} />
        
        </button>
      </div>
    </header>
  );
}
