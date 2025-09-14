import { useEffect, useState, useMemo } from "react";
import { useNavigate } from "react-router-dom";

import LoadingSpinner from "./components/ui/LoadingSpinner";
import api, { getCSRFToken } from "./api";
import Navbar from "./navbar/navbar";


export default function Protected() {
  const [items, setItems] = useState([]);
  const [filtered, setFiltered] = useState([]);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [searching, setSearching] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();

  // Fetch items from backend
  useEffect(() => {
    let mounted = true;
    const fetchItems = async () => {
      setLoading(true);
      setError("");
      try {
        const token = await auth.currentUser?.getIdToken(true);
        const res = await api.get("/api/items/", {
          headers: token ? { Authorization: `Bearer ${token}` } : {},
        });
        if (!mounted) return;
        setItems(res.data || []);
        setFiltered(res.data || []);
      } catch (err) {
        console.error(err);
        setError("Failed to load items");
      } finally {
        if (mounted) setLoading(false);
      }
    };
    fetchItems();
    return () => {
      mounted = false;
    };
  }, []);

  // Debounced filter
  useEffect(() => {
    if (query === "") {
      setFiltered(items);
      return;
    }
    setSearching(true);
    const id = setTimeout(() => {
      const q = query.trim().toLowerCase();
      const out = items.filter((it) => {
        const name = (it.name || it.title || "").toLowerCase();
        const sku = (it.sku || "").toLowerCase();
        const desc = (it.description || "").toLowerCase();
        return name.includes(q) || sku.includes(q) || desc.includes(q);
      });
      setFiltered(out);
      setSearching(false);
    }, 250);
    return () => clearTimeout(id);
  }, [query, items]);

  const total = useMemo(() => items.length, [items]);
  const visible = useMemo(() => filtered.length, [filtered]);

  const handleBackendLogout = async () => {
    try {
      try {
        const token = await auth.currentUser?.getIdToken(true);
        const csrf = await getCSRFToken();
        await api.post(
          "/auth/logout/",
          { idToken: token },
          { headers: { "Content-Type": "application/json", "X-CSRFToken": csrf } }
        );
      } catch (err) {
        console.warn("Backend logout failed:", err);
      }
      await signOut(auth);
      navigate("/login");
    } catch (err) {
      console.error("Logout error:", err);
      setError("Failed to log out");
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <LoadingSpinner size="lg" text="Loading items..." />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Navbar at the top */}
      <Navbar onLogout={handleBackendLogout} />

      <div className="py-8 px-4 sm:px-6 lg:px-8 max-w-6xl mx-auto">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">StockWises Dashboard</h1>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            {visible} of {total} items shown
          </p>
        </div>

        {/* Search box */}
        <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-5 mb-6">
          <div className="flex flex-col sm:flex-row sm:items-center gap-4">
            <label className="sr-only" htmlFor="search">Search items</label>
            <div className="relative flex-1">
              <input
                id="search"
                type="search"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Search by name, SKU or description..."
                className="w-full border border-gray-200 dark:border-gray-700 rounded-md py-2 px-3 focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white dark:bg-gray-900 text-gray-900 dark:text-white"
              />
              {searching && (
                <div className="absolute right-2 top-1/2 -translate-y-1/2 text-sm text-gray-500">Searching…</div>
              )}
            </div>
            <button
              onClick={() => { setQuery(""); setFiltered(items); }}
              className="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-md"
            >
              Clear
            </button>
          </div>
        </div>

        {/* Error message */}
        {error && (
          <div className="mb-4 p-3 rounded-md bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-700">
            {error}
          </div>
        )}

        {/* Items grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.length ? (
            filtered.map((item) => (
              <div key={item.id || item.pk || item.sku || Math.random()} className="bg-white dark:bg-gray-800 shadow rounded-lg p-4">
                <div className="flex items-start justify-between">
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                      {item.name || item.title || "Untitled"}
                    </h3>
                    <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
                      {item.description ? item.description.slice(0, 120) : "No description"}
                    </p>
                    <div className="mt-3 text-sm text-gray-600 dark:text-gray-300">
                      <span className="font-medium">SKU:</span> {item.sku || "—"}
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-lg font-semibold text-gray-900 dark:text-white">
                      {item.quantity ?? item.stock ?? 0}
                    </div>
                    <div className="text-sm text-gray-500 dark:text-gray-400">in stock</div>
                  </div>
                </div>

                <div className="mt-4 flex items-center justify-between gap-2">
                  <div className="text-sm text-gray-700 dark:text-gray-300 font-medium">
                    ${Number(item.price ?? item.unit_price ?? 0).toFixed(2)}
                  </div>
                  <div className="flex gap-2">
                    <button className="px-3 py-1 text-sm bg-blue-600 hover:bg-blue-700 text-white rounded-md">View</button>
                    <button className="px-3 py-1 text-sm bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-md">Edit</button>
                  </div>
                </div>
              </div>
            ))
          ) : (
            <div className="col-span-full bg-white dark:bg-gray-800 shadow rounded-lg p-6 text-center text-gray-600 dark:text-gray-400">
              No items match your search.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
