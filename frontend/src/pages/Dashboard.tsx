import { useEffect, useId, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import iconOverstock from "../assets/icon1.png";
import iconOutOfStock from "../assets/icon2.png";
import iconLowStock from "../assets/icon3.png";
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

import Navbar from "../layout/navbar";

// ================== TYPES ==================
interface Product {
  id: number;
  name: string;
  stock: number;
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
  const [products, setProducts] = useState<Product[]>([]);
  const [filtered, setFiltered] = useState<Product[]>([]);
  const [query, setQuery] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(true);
  const [searching, setSearching] = useState<boolean>(false);
  const [error, setError] = useState<string>("");
  const [showAll, setShowAll] = useState(false);
  
  

  const navigate = useNavigate();

  const gradientIdIn = useId();
  const gradientIdOut = useId();


  
const handleStockChange = async (historyItem: Product) => {
   setItems(prev => [historyItem, ...prev]); 
  try {
    const res = await api.post(`/inventory/${historyItem.id}/adjust_stock/`, {
      change: historyItem.change,
    });

    const updatedProduct = res.data;
    
    // Update frontend state
    setProducts(prev =>
      prev.map(p =>
        p.id === updatedProduct.product_id
          ? { ...p, stock: updatedProduct.new_quantity }
          : p
      )
    );

    setItems(prev => [
      {
        ...historyItem,
        stock: updatedProduct.new_quantity,
        date: new Date().toISOString(),
      },
      ...prev,
    ]);
  } catch (err) {
    console.error("Failed to update stock", err);
  }
};



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

  // ================== Fetch Items ==================
  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        // ✅ Products
        const prodRes = await api.get("/inventory/");
        const productsData: Product[] = (Array.isArray(prodRes.data) ? prodRes.data : []).map((p: any) => ({
          id: p.id ?? p.product_id,
          name: p.name ?? p.product_name ?? "Unnamed",
           stock: p.quantity ?? 0,
          date: p.created_at ?? "",
          change: 0, // products don’t track change directly
          image: p.image_url ?? "",
          sku: p.sku ?? "",
        }));
        setProducts(productsData);

        // ✅ Stock Transactions (History)
        const txRes = await api.get("/inventory/history/");
        const raw = Array.isArray(txRes.data) ? txRes.data : txRes.data.results || [];
        

        const mapped: Product[] = raw.map((t: any) => ({
          id: t.product ?? t.product_id,
          name: t.product_name ?? "Unknown Product",
          image: t.image_url ?? "",
          sku: t.sku ?? "",
          stock: t.new_quantity ?? t.product_quantity ?? 0,
          change: Number(t.change) || 0,
          date: t.timestamp ?? t.created_at ?? "",
        }));

        setItems(mapped);
        setFiltered(mapped);
      } catch (err: unknown) {
        if (err && typeof err === "object" && "response" in err) {
          console.error("Fetch failed:", (err as any).response?.data);
        } else {
          console.error("Fetch failed:", err);
        }
        setError("Failed to load data");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  // ================== Search Filter ==================
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
  return name.includes(q) || sku.includes(q);
});
      setFiltered(out);
      setSearching(false);
    }, 250);
    return () => clearTimeout(id);
  }, [query, items]);

  // ================== Latest Date ==================
  const latestDate = useMemo<string | null>(() => {
    if (items.length === 0) return null;
    return items.reduce((max, item) => (item.date > max ? item.date : max), items[0]?.date || "");
  }, [items]);

  // ================== Today Changes ==================
  const todayChanges = useMemo<Product[]>(() => {
    if (!latestDate) return [];
    return items.filter((item) => item.date === latestDate);
  }, [items, latestDate]);

  // ================== Weekday Helper ==================
  const getWeekday = (dateStr: string): string => {
    const date = new Date(dateStr);
    return date.toLocaleDateString("en-US", { weekday: "short" });
  };

  // ================== Stock Chart Data ==================
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

  // ================== Logout ==================
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
  if (error) {
    return (
      <div className="h-screen flex items-center justify-center bg-white">
        <p className="text-red-500 text-lg">{error}</p>
      </div>
    );
  }
const totalFromHistory = items.reduce((acc, i) => acc + i.change, 0);
  // ================== UI ==================
  return (
    <div className="h-screen bg-gray-100 flex flex-col">
     <Navbar onLogout={handleLogout} className="bg-transparent" />


{/* Desktop View */}
  <div className="hidden lg:block flex-1 overflow-y-auto lg:overflow-hidden px-6 py-6 max-w-7xl mx-auto w-full pt-20">

 {/* Top Summary Cards */}
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-1 mb-6">

  {/* Total + Stock In + Stock Out */}
  <div className="bg-gradient-to-r from-blue-500 to-blue-600 text-white p-3 rounded-2xl shadow-md border-[6px] border-blue-200">
    
    {/* Latest Change */}
    <div className="text-[10px] opacity-70 mb-2 text-left">
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

    {/* Values */}
    <div className="flex items-center justify-between">
      {/* Total */}
      <div className="flex-1 text-center">
        <p className="text-lg font-bold">{totalFromHistory}</p>
        <p className="text-[11px] opacity-70">Total</p>
      </div>

      {/* Divider */}
      <div className="w-px bg-white mx-1 h-8 opacity-50"></div>

      {/* Stock In */}
      <div className="flex-1 text-center">
        <p className="text-lg font-bold text-green-200">
          {items.filter(i => i.change > 0).reduce((acc, i) => acc + i.change, 0)}
        </p>
        <p className="text-[11px] opacity-70">Stock In</p>
      </div>

      {/* Divider */}
      <div className="w-px bg-white mx-1 h-8 opacity-50"></div>

      {/* Stock Out */}
      <div className="flex-1 text-center">
        <p className="text-lg font-bold text-red-200">
          {items.filter(i => i.change < 0).reduce((acc, i) => acc + Math.abs(i.change), 0)}
        </p>
        <p className="text-[11px] opacity-70">Stock Out</p>
      </div>
    </div>
  </div>

{/* Stock Status Cards - Row Layout */}
<div className="flex flex-row gap-2 ">

   {/* Overstock */}
  <div className="relative bg-[#242424] rounded-[20px] border-[5px] border-[#D4D4D4] 
                  w-[250px] h-[110px] shadow-md flex-shrink-0">
    <p className="absolute left-[15px] top-[25px] text-[16px] leading-[18px] font-normal text-white/80">
      Overstock
    </p>
    <p className="absolute left-[15px] top-[63px] text-[28px] leading-[20px] font-normal text-white">
      {products.filter((p) => p.stock > 200).length}
    </p>
    <div className="absolute right-[12px] top-[12px] w-[35px] h-[35px] rounded-full bg-white flex items-center justify-center">
      <img
        src={iconOverstock}
        alt="Overstock Icon"
        className="w-[16px] h-[18px] object-contain"
      />
    </div>
  </div>

  {/* Out of Stock */}
   <div className="relative bg-red-600 rounded-[20px] border-[5px] border-red-300 
                  w-[250px] h-[110px] shadow-md flex-shrink-0 flex flex-col items-center justify-center">
    <div className="absolute top-[12px] right-[12px] w-[35px] h-[35px] rounded-full bg-white flex items-center justify-center">
      <img
        src={iconOutOfStock}
        alt="Out of Stock Icon"
        className="w-[16px] h-[16px] object-contain"
      />
    </div>
    <p className="absolute left-[15px] top-[25px] text-[16px] leading-[18px] font-normal text-white/80">Out of Stock</p>
    <p className="absolute left-[15px] top-[63px] text-[28px] leading-[20px] font-normal text-white">
      {products.filter((p) => p.stock === 0).length}
    </p>
  </div>

  {/* Low Stock */}
   <div className="relative bg-yellow-400 rounded-[20px] border-[5px] border-yellow-200 
                  w-[250px] h-[110px] shadow-md flex-shrink-0 flex flex-col items-center justify-center">
    <div className="absolute top-[12px] right-[12px] w-[35px] h-[35px] rounded-full bg-white flex items-center justify-center">
      <img
        src={iconLowStock}
        alt="Low Stock Icon"
        className="w-[16px] h-[16px] object-contain"
      />
    </div>
    <p className="absolute left-[15px] top-[25px] text-[16px] leading-[18px] font-normal text-white/80">Low Stock</p>
    <p className="absolute left-[15px] top-[63px] text-[28px] leading-[20px] font-normal text-white">
      {products.filter((p) => p.stock > 0 && p.stock <= 10).length}
    </p>
  </div>
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


{/* Mobile View */}
<div className="block lg:hidden bg-gray-100 min-h-screen px-5 py-6 pt-20">
  {/* Top Summary Section */}
<div className="bg-gradient-to-r from-blue-500 to-blue-600 text-white p-3 rounded-2xl shadow-md border-[6px] border-blue-200">
    <div className="flex justify-between text-xs opacity-80 mb-2">
      <span>{new Date().toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}</span>
      <span className="font-semibold">Today</span>
    </div>
    
  <div className="grid grid-cols-3 text-center divide-x divide-gray-300">
      <div>
        <p className="text-2xl font-bold">{totalFromHistory}</p>
        <p className="text-xs opacity-80">Total</p>
      </div>
      <div>
        <p className="text-2xl font-bold text-green-200">
          {items.filter(i => i.change > 0).reduce((a, b) => a + b.change, 0)}
        </p>
        <p className="text-xs opacity-80">Stock In</p>
      </div>
      <div>
        <p className="text-2xl font-bold text-red-200">
          {items.filter(i => i.change < 0).reduce((a, b) => a + Math.abs(b.change), 0)}
        </p>
        <p className="text-xs opacity-80">Stock Out</p>
      </div>
    </div>
  </div>

  

  {/* Stock Summary Cards */}
<div className="grid grid-cols-3 gap-3 mb-6">
  {/* Overstock */}
  <div className="bg-black text-white p-4 rounded-xl shadow-lg relative flex flex-col items-center justify-center h-[120px]">
    <div className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white flex items-center justify-center">
     <img src={iconOverstock} alt="Overstock Icon" className="w-4 h-4 object-contain" />
    </div>
    <p className="text-xs mb-1 opacity-80">Overstock</p>
    <p className="text-xl font-bold">
      {products.filter((p) => p.stock > 200).length}
    </p>
  </div>

  {/* Out of Stock */}
  <div className="bg-red-600 text-white p-4 rounded-xl shadow-lg relative flex flex-col items-center justify-center h-[120px]">
    <div className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white flex items-center justify-center">
    <img src={iconOutOfStock} alt="Out of Stock Icon" className="w-4 h-4 object-contain" />
    </div>
    <p className="text-xs mb-1 opacity-80">Out of Stock</p>
    <p className="text-xl font-bold">
      {products.filter((p) => p.stock === 0).length}
    </p>
  </div>

  {/* Low Stock */}
  <div className="bg-yellow-400 text-white p-4 rounded-xl shadow-lg relative flex flex-col items-center justify-center h-[120px]">
    <div className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white flex items-center justify-center">
     <img src={iconLowStock} alt="Low Stock Icon" className="w-4 h-4 object-contain" />

    </div>
    <p className="text-xs mb-1 opacity-80">Low Stock</p>
    <p className="text-xl font-bold">
      {products.filter((p) => p.stock > 0 && p.stock <= 10).length}
    </p>
  </div>
</div>

  {/* Stock Movement Chart */}
  <div className="bg-white rounded-xl p-5 shadow-lg mb-6">
    <h2 className="text-md font-semibold text-gray-800 mb-4">Stock Movement</h2>
    <div className="h-[220px]">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={stockData} barCategoryGap="30%">
          <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
          <XAxis dataKey="day" stroke="#9ca3af" />
          <YAxis stroke="#9ca3af" />
          <Tooltip contentStyle={{ borderRadius: "8px" }} />
          <defs>
            <linearGradient id="stockInMobile" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#22c55e" stopOpacity={0.8} />
              <stop offset="100%" stopColor="#22c55e" stopOpacity={0.2} />
            </linearGradient>
            <linearGradient id="stockOutMobile" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#ef4444" stopOpacity={0.8} />
              <stop offset="100%" stopColor="#ef4444" stopOpacity={0.2} />
            </linearGradient>
          </defs>
          <Bar dataKey="in" radius={[6, 6, 0, 0]} fill="url(#stockInMobile)" />
          <Bar dataKey="out" radius={[6, 6, 0, 0]} fill="url(#stockOutMobile)" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  </div>



  {/* History Section */}
  <div className="bg-white rounded-xl p-5 shadow-lg">
    <div className="flex justify-between items-center mb-3">
      <h2 className="text-md font-semibold text-gray-800">History</h2>
      <button
        className="text-blue-500 text-sm hover:underline sm:hidden"
        onClick={() => setShowAll(prev => !prev)}
      >
        {showAll ? "See less" : "See all"}
      </button>
    </div>

    <ul className="space-y-4">
      {(showAll ? filtered : filtered.slice(0, 3)).map(item => (
        <li
          key={`${item.id}-${item.date}`}
          className="flex justify-between items-center text-sm border-b border-gray-100 pb-2 last:border-none"
        >
          <div className="flex items-center gap-3">
            {item.image && (
              <img
                src={item.image}
                alt={item.name}
                className="w-10 h-10 object-cover rounded-md"
              />
            )}
            <div>
              <p className="font-medium text-gray-700">{item.name}</p>
              <p className="text-xs text-gray-500">Stock: {item.stock}</p>
            </div>
          </div>
          <span
            className={`font-semibold ${
              item.change > 0 ? "text-green-500" : "text-red-500"
            }`}
          >
            {item.change > 0 ? `+${item.change}` : item.change}
          </span>
        </li>
      ))}
    </ul>
    </div>
  </div>
</div>
);
}
