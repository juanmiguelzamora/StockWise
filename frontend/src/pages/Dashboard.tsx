import { useEffect, useState, useMemo, useId } from "react";
import { useNavigate } from "react-router-dom";
import api from "../services/api"; // ✅ axios instance

import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import LoadingSpinner from "../components/ui/loadingspinner";
import Navbar from "../layout/navbar";

// ================== TYPES ==================
interface Product {
  id: number;
  name: string;
  description: string;
  stock: number;
  price: number;
  date: string; // ISO string from backend
  change: number;
  image?: string;
  sku?: string;
}

interface StockData {
  day: string;
  in: number;
  out: number;
  full: number;
}

// ================== COMPONENT ==================
export default function ProtectedDashboard() {
  const [items, setItems] = useState<Product[]>([]);
  const [filtered, setFiltered] = useState<Product[]>([]);
  const [query, setQuery] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(true);
  const [searching, setSearching] = useState<boolean>(false);
  const [error, setError] = useState<string>("");

  const navigate = useNavigate();

  const gradientIdIn = useId();
  const gradientIdOut = useId();

  // Helper to format date
  const formatDate = (dateStr: string): string => {
    if (!dateStr) return "";
    const date = new Date(dateStr);
    const today = new Date();

    if (
      date.getFullYear() === today.getFullYear() &&
      date.getMonth() === today.getMonth() &&
      date.getDate() === today.getDate()
    ) {
      return "Today " + date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
    }

    return date.toLocaleString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  // Fetch items
 useEffect(() => {
   fetchTransactions();
   }, []);

   const fetchTransactions = async () => {
     setLoading(true); 
    try {
        const res = await api.get("/inventory/transactions/");
       const raw = Array.isArray(res.data) ? res.data : res.data.results || []; 
       const mapped: Product[] = raw.map((t: any) => ({

          id: t.product,
         name: t.product_name,
          description: t.description || "",
           price: t.price || 0,
            image: t.image, 
            sku: t.sku, 
            stock: 0,
             change: t.change,
              date: t.timestamp,
             }));
             setItems(mapped); 
             setFiltered(mapped);

      } catch (err: any) {
         console.error("Fetch transactions failed:", err.response?.data || err); 
         setError("Failed to load stock history");
     } finally {
       setLoading(false);
      }
    };


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
        const name = (it.name || "").toLowerCase();
        const sku = (it.sku || "").toLowerCase();
        const desc = (it.description || "").toLowerCase();
        return name.includes(q) || sku.includes(q) || desc.includes(q);
      });
      setFiltered(out);
      setSearching(false);
    }, 250);
    return () => clearTimeout(id);
  }, [query, items]);

  // Latest date
  const latestDate = useMemo<string | null>(() => {
    if (items.length === 0) return null;
    return items[0] ? items.reduce((max, item) => (item.date > max ? item.date : max), items[0].date) : null;
  }, [items]);

  // Today changes
  const todayChanges = useMemo<Product[]>(() => {
    if (!latestDate) return [];
    return items.filter((item) => item.date === latestDate);
  }, [items, latestDate]);

  // Weekday helper
  const getWeekday = (dateStr: string): string => {
    const date = new Date(dateStr);
    return date.toLocaleDateString("en-US", { weekday: "short" });
  };

  // Prepare stock data grouped by weekdays
  const stockData: StockData[] = useMemo(() => {
    if (!items.length) return [];

    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const grouped: Record<string, { in: number; out: number }> = {};

    weekdays.forEach((day) => {
      grouped[day] = { in: 0, out: 0 };
    });

    items.forEach((item) => {
      const day = getWeekday(item.date);
      if (!grouped[day]) grouped[day] = { in: 0, out: 0 };
      if (item.change > 0) grouped[day].in += item.change;
      if (item.change < 0) grouped[day].out += Math.abs(item.change);
    });

    return weekdays.map((day) => ({
      day,
      in: grouped[day]?.in ?? 0,
      out: grouped[day]?.out ?? 0,
      full: (grouped[day]?.in ?? 0) + (grouped[day]?.out ?? 0),
    }));
  }, [items]);

  const handleLogout = async () => {
    try {
      localStorage.removeItem("access");
      localStorage.removeItem("refresh");
      navigate("/login");
    } catch (err: any) {
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

  // ================== UI ==================
  return (
    <div className="h-screen bg-gray-100 flex flex-col">
     <Navbar onLogout={handleLogout} className="bg-transparent" />


<div className="flex-1 overflow-y-auto lg:overflow-hidden px-6 py-6 max-w-7xl mx-auto w-full pt-20">
 {/* Top Summary Cards */}
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">

  {/* Total + Stock In + Stock Out */}
  <div className="bg-gradient-to-r from-blue-400 to-blue-600 text-white p-4 rounded-xl shadow-lg">

    {/* Latest Change */}
    <div className="text-xs opacity-70 mb-2 text-center">
      Latest Change (
      {(() => {
        if (!items.length) return "N/A";

        const latestDateStr = items.reduce((latest, item) =>
          new Date(item.date) > new Date(latest) ? item.date : latest,
          items[0]?.date ?? ""
        );
        const latestDate = new Date(latestDateStr);
        const today = new Date();
        const yesterday = new Date();
        yesterday.setDate(today.getDate() - 1);

        const isToday =
          latestDate.getFullYear() === today.getFullYear() &&
          latestDate.getMonth() === today.getMonth() &&
          latestDate.getDate() === today.getDate();

        const isYesterday =
          latestDate.getFullYear() === yesterday.getFullYear() &&
          latestDate.getMonth() === yesterday.getMonth() &&
          latestDate.getDate() === yesterday.getDate();

        if (isToday) {
          return `Today ${latestDate.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: true })}`;
        } else if (isYesterday) {
          return `Yesterday ${latestDate.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: true })}`;
        } else {
          return latestDate.toLocaleString("en-US", {
            year: "numeric",
            month: "short",
            day: "numeric",
            hour: "2-digit",
            minute: "2-digit",
            hour12: true,
          });
        }
      })()}
      )
    </div>

    <div className="flex items-center justify-between w-full">
      {/* Total */}
      <div className="flex-1 text-center">
        <p className="text-xl font-bold">{items.reduce((acc, item) => acc + item.stock, 0)}</p>
        <p className="text-xs mt-1">Total</p>
      </div>

      {/* Divider */}
      <div className="w-px bg-white mx-2 h-10 opacity-50"></div>

      {/* Stock In */}
      <div className="flex-1 text-center">
        <p className="text-xl font-bold text-green-200">
          {items.filter(i => i.change > 0).reduce((acc, i) => acc + i.change, 0)}
        </p>
        <p className="text-xs mt-1">Stock In</p>
      </div>

      {/* Divider */}
      <div className="w-px bg-white mx-2 h-10 opacity-50"></div>

      {/* Stock Out */}
      <div className="flex-1 text-center">
        <p className="text-xl font-bold text-red-200">
          {items.filter(i => i.change < 0).reduce((acc, i) => acc + Math.abs(i.change), 0)}
        </p>
        <p className="text-xs mt-1">Stock Out</p>
      </div>
    </div>
  </div>



   {/* Overstock */}
<div className="bg-black text-white p-4 rounded-xl shadow-lg relative flex flex-col items-center justify-center h-[120px]">
  {/* Top-right icon with white circular background */}
  <div className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white flex items-center justify-center">
    <img
      src="/src/assets/icon1.png"
      alt="Icon"
      className="w-4 h-4 object-contain"
    />
  </div>

  <p className="text-xs mb-1">Overstock</p>
  <p className="text-xl font-bold">{items.filter(i => i.stock > 500).length}</p>
</div>


{/* Out of Stock */}
<div className="bg-red-600 text-white p-4 rounded-xl shadow-lg relative flex flex-col items-center justify-center  h-[120px]">
  {/* Top-right icon */}
  <div className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white flex items-center justify-center">
    <img
      src="/src/assets/icon2.png" // replace with your Out of Stock icon
      alt="Out of Stock Icon"
      className="w-4 h-4 object-contain"
    />
  </div>

  <p className="text-xs mb-1">Out of Stock</p>
  <p className="text-xl font-bold">{items.filter(i => i.stock === 0).length}</p>
</div>

{/* Low Stock */}
<div className="bg-yellow-400 text-white p-4 rounded-xl shadow-lg relative flex flex-col items-center justify-center  h-[120px]">
  {/* Top-right icon */}
  <div className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white flex items-center justify-center">
    <img
      src="/src/assets/icon3.png" // replace with your Low Stock icon
      alt="Low Stock Icon"
      className="w-4 h-4 object-contain"
    />
  </div>

  <p className="text-xs mb-1">Low Stock Alert</p>
  <p className="text-xl font-bold">{items.filter(i => i.stock > 0 && i.stock <= 10).length}</p>
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
