type NavbarProps = {
    setPage: (page: string) => void;
};

export default function Navbar({ setPage }: NavbarProps) {
    return (
    <header>
      <span>
        <a href="">Logo</a>
      </span>
        <nav>
          <ul>
              <li onClick={() => setPage("dashboard")}>Dashboard</li>
              <li onClick={() => setPage("inventory")}>Inventory</li>
              <li onClick={() => setPage("ai-assistant")}>AI Assistant</li>
              <li onClick={() => setPage("users")}>Users</li>
              <li onClick={() => setPage("profile")}>Profile</li>
          </ul>
        </nav>
      <span>
        <button>Exit</button>
      </span>
    </header>
    );
}