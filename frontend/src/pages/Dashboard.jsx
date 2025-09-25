import { useEffect, useState, useMemo, useId } from "react";
import { useNavigate } from "react-router-dom";
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import LoadingSpinner from "../components/ui/LoadingSpinner";
import Navbar from "../layout/navbar";

export default function ProtectedDashboard() {
  const [items, setItems] = useState([]);
  const [filtered, setFiltered] = useState([]);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [searching, setSearching] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const gradientIdIn = useId();
  const gradientIdOut = useId();

  // Helper to format date: Today or YYYY-MM-DD
  const formatDate = (dateStr) => {
    if (!dateStr) return "";
    const date = new Date(dateStr);
    const today = new Date();
    if (
      date.getFullYear() === today.getFullYear() &&
      date.getMonth() === today.getMonth() &&
      date.getDate() === today.getDate()
    ) {
      return "Today";
    }
    return dateStr;
  };

  // Fetch items
  useEffect(() => {
    let mounted = true;
    const fetchItems = async () => {
      setLoading(true);
      setError("");
      try {
        const res = await fetch("/items.json");
        const data = await res.json();
        if (!mounted) return;
        setItems(data || []);
        setFiltered(data || []);
      } catch (err) {
        console.error(err);
        setError("Failed to load items");
      } finally {
        if (mounted) setLoading(false);
      }
    };
    fetchItems();
    return () => { mounted = false; };
  }, []);

  // Search filter
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

  // Get latest date from items
  const latestDate = useMemo(() => {
    if (items.length === 0) return null;
    return items.reduce((max, item) => (item.date > max ? item.date : max), items[0].date);
  }, [items]);

  // Filter items for latest date
  const todayChanges = useMemo(() => {
    if (!latestDate) return [];
    return items.filter(item => item.date === latestDate);
  }, [items, latestDate]);

  // Helper to get weekday name from date
 // Helper to get weekday name
const getWeekday = (dateStr) => {
  const date = new Date(dateStr);
  return date.toLocaleDateString("en-US", { weekday: "short" }); // Mon, Tue, ...
};

// Prepare stock data grouped by weekdays (Mon–Sun)
const stockData = useMemo(() => {
  if (!items.length) return [];

  const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  const grouped = {};

  // Initialize all days with 0
  weekdays.forEach(day => {
    grouped[day] = { in: 0, out: 0 };
  });

  // Sum values by weekday
  items.forEach(item => {
    const day = getWeekday(item.date);
    if (!grouped[day]) grouped[day] = { in: 0, out: 0 };
    if (item.change > 0) grouped[day].in += item.change;
    if (item.change < 0) grouped[day].out += Math.abs(item.change);
  });

  // Return ordered data Mon → Sun
  return weekdays.map(day => ({
    day,
    in: grouped[day].in,
    out: grouped[day].out,
    full: grouped[day].in + grouped[day].out,
  }));
}, [items]);

  const handleLogout = async () => {
    try {
      localStorage.removeItem("access");
      localStorage.removeItem("refresh");
      navigate("/login");
    } catch (err) {
      console.error("Logout error:", err);
      setError("Failed to log out");
    }
  };

  if (loading) {
    return (
      <div className="h-screen flex items-center justify-center bg-white">
        <LoadingSpinner size="lg" text="Loading items..." />
      </div>
    );
  }

  if (error) {
    return (
      <div className="h-screen flex items-center justify-center bg-white">
        <p className="text-red-500 text-lg">{error}</p>
      </div>
    );
  }

  return (
    <div className="h-screen bg-gray-100 flex flex-col">
      <Navbar
        onLogout={handleLogout}
        className="bg-white shadow-sm border-b border-gray-200"
      />

<div className="flex-1 overflow-y-auto lg:overflow-hidden px-6 py-6 max-w-7xl mx-auto w-full pt-20">
        {/* Top Summary Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-gradient-to-r from-green-400 to-green-500 text-white p-5 rounded-xl flex flex-col">
            <p className="text-sm opacity-90">
              Latest Change ({formatDate(latestDate)})
            </p>
            <h3 className="text-3xl font-bold mt-2">
              {todayChanges.reduce((acc, item) => acc + (item.change || 0), 0)}
            </h3>
            <p className="text-xs opacity-80">Total Change</p>
          </div>

          <div className="bg-gradient-to-r from-blue-400 to-blue-500 text-white p-5 rounded-xl flex flex-col">
            <p className="text-sm opacity-90">Total Items</p>
            <h3 className="text-3xl font-bold mt-2">{items.length}</h3>
            <p className="text-xs opacity-80">All Products</p>
          </div>

          <div className="bg-black text-white p-5 rounded-xl flex flex-col">
            <p className="text-sm opacity-90">Overstock</p>
            <h3 className="text-3xl font-bold mt-2">
              {items.filter(i => i.stock > 500).length}
            </h3>
            <p className="text-xs opacity-80">High Stock</p>
          </div>

          <div className="bg-gradient-to-r from-yellow-400 to-yellow-500 text-white p-5 rounded-xl flex flex-col">
            <p className="text-sm opacity-90">Low Stock Alert</p>
            <h3 className="text-3xl font-bold mt-2">
              {items.filter(i => i.stock > 0 && i.stock <= 10).length}
            </h3>
            <p className="text-xs opacity-80">Critical</p>
          </div>
        </div>

        {/* Chart + History */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 bg-white p-6 rounded-xl shadow-sm">
            <h2 className="text-lg font-semibold text-black mb-4">Stock Movement</h2>
            <div className="h-[260px] sm:h-[300px] lg:h-[360px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={stockData} barCategoryGap="30%">
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis dataKey="day" stroke="#9ca3af" />
                  <YAxis stroke="#9ca3af" />
                  <Tooltip contentStyle={{ borderRadius: "8px" }} />
                  <defs>
                    <linearGradient id="stockIn" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#22c55e" stopOpacity={0.8} />
                      <stop offset="100%" stopColor="#22c55e" stopOpacity={0.2} />
                    </linearGradient>
                    <linearGradient id="stockOut" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#ef4444" stopOpacity={0.8} />
                      <stop offset="100%" stopColor="#ef4444" stopOpacity={0.2} />
                    </linearGradient>
                  </defs>
                  <Bar dataKey="in" radius={[6, 6, 0, 0]} fill="url(#stockIn)" />
                  <Bar dataKey="out" radius={[6, 6, 0, 0]} fill="url(#stockOut)" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-sm max-h-[400px] overflow-y-auto">
            <h2 className="text-lg font-semibold text-gray-800 mb-4">History</h2>
            <ul className="space-y-4">
              {filtered.map((item) => (
                <li key={`${item.id}-${item.date}`} className="flex justify-between items-center text-sm">
                  <div className="flex items-center gap-3">
                    {item.image && (
                      <img
                        src={item.image}
                        alt={item.name}
                        className="w-10 h-10 object-cover rounded"
                      />
                    )}
                    <span className="text-gray-700 font-medium">
                      {item.name} ({formatDate(item.date)})
                    </span>
                  </div>
                  <span className={`font-bold ${item.change > 0 ? "text-green-500" : "text-red-500"}`}>
                    {item.change > 0 ? `+${item.change}` : item.change}
                  </span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
