import { useEffect, useState, useMemo, useId } from "react";
import { useNavigate } from "react-router-dom";
import api from "../services/api";
import iconOverstock from "../assets/icon1.png";
import iconOutOfStock from "../assets/icon2.png";
import iconLowStock from "../assets/icon3.png";

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
interface BackendProduct {
  id: number;
  sku: string;
  name: string;
  description?: string;
  category: string;
  image_url?: string;
  updated_at?: string; // ISO date string
  inventory: {
    stock_in: number;
    stock_out: number;
    total_stock: number;
    average_daily_sales?: number;
    stock_status: "out_of_stock" | "low_stock" | "in_stock";
  };
}

interface HistoryItem {
  id: number;
  product_name: string;
  sku: string;
  image: string;
  category?: string; // Optional: Enrich from products if needed
  units_sold: number;
  date: string;
  change: number;
}

interface StockData {
  day: string;
  sales: number; // Renamed from "out" for clarity (since only sales data)
  adjustments: number; // Placeholder for future "in" if added
}

// ================== COMPONENT ==================
export default function ProtectedDashboard() {
  const [products, setProducts] = useState<BackendProduct[]>([]);
  const [historyItems, setHistoryItems] = useState<HistoryItem[]>([]);
  const [filtered, setFiltered] = useState<HistoryItem[]>([]);
  const [query, setQuery] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(true);
  const [searching, setSearching] = useState<boolean>(false);
  const [error, setError] = useState<string>("");
  const [showAll, setShowAll] = useState(false);

  const navigate = useNavigate();
  const gradientIdIn = useId();
  const gradientIdOut = useId();

 // ================== Fetch Data from Backend ==================
useEffect(() => {
  const fetchData = async () => {
    setLoading(true);
    try {
      // Single fetch: Use products API with ordering by -updated_at for history timeline
      const prodRes = await api.get("/products/?ordering=-updated_at");
      const productsData: BackendProduct[] = prodRes.data;
      setProducts(productsData);

      // Derive history from products: Use updated_at as date, stock_out as units_sold (cumulative sales per product)
      // Limit to top 50 most recently updated for "recent history"
      const historyData: HistoryItem[] = productsData.slice(0, 50).map((p) => ({
        id: p.id,
        product_name: p.name?.trim() || "Unknown",
        sku: p.sku ?? "",
        image: p.image_url ?? "",
        category: p.category, // For future filters
        units_sold: p.inventory.stock_out ?? 0,
        date: p.updated_at ?? "", // Assumes updated_at is added to ProductSerializer (ISO string)
        change: -(p.inventory.stock_out ?? 0), // Negative for "out/sales"
      }));

      setHistoryItems(historyData);
      setFiltered(historyData);
    } catch (err: any) {
      console.error(
        "Error fetching dashboard data:",
        err.response?.data || err
      );
      setError("Failed to load data from server");
    } finally {
      setLoading(false);
    }
  };

  fetchData();
}, []);
  // ================== Computed Totals ==================
  const totalStock = useMemo(
    () => products.reduce((acc, p) => acc + p.inventory.total_stock, 0),
    [products]
  );

  const totalIn = useMemo(
    () => products.reduce((acc, p) => acc + p.inventory.stock_in, 0),
    [products]
  );

  const totalOut = useMemo(
    () => products.reduce((acc, p) => acc + p.inventory.stock_out, 0),
    [products]
  );

  // ================== Search Filter ==================
  useEffect(() => {
    if (query === "") {
      setFiltered(historyItems);
      return;
    }
    setSearching(true);
    const id = setTimeout(() => {
      const q = query.trim().toLowerCase();
      const out = historyItems.filter((it) => {
        const name = (it.product_name || "").toLowerCase();
        const sku = (it.sku || "").toLowerCase();
        // Optional: Add category search
        const cat = (it.category || "").toLowerCase();
        return name.includes(q) || sku.includes(q) || cat.includes(q);
      });
      setFiltered(out);
      setSearching(false);
    }, 250);
    return () => clearTimeout(id);
  }, [query, historyItems]);

  // ================== Date Helpers ==================
  const formatDate = (dateStr: string): string => {
    if (!dateStr) return "";
    const date = new Date(dateStr);
    const today = new Date();

    if (
      date.getFullYear() === today.getFullYear() &&
      date.getMonth() === today.getMonth() &&
      date.getDate() === today.getDate()
    ) {
      return (
        "Today " +
        date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
      );
    }

    return date.toLocaleString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const getWeekday = (dateStr: string): string => {
    const date = new Date(dateStr);
    return date.toLocaleDateString("en-US", { weekday: "short" });
  };

  // ================== Chart Computation ==================
  const stockData: StockData[] = useMemo(() => {
    if (!historyItems.length) return [];

    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const grouped: Record<string, { sales: number; adjustments: number }> = {};

    weekdays.forEach((day) => {
      grouped[day] = { sales: 0, adjustments: 0 };
    });

    historyItems.forEach((item) => {
      const day = getWeekday(item.date);
      if (!grouped[day]) grouped[day] = { sales: 0, adjustments: 0 };
      // Currently only sales (out); add logic for >0 if stock-in events added
      grouped[day].sales += Math.abs(item.change); // Units sold
      // grouped[day].adjustments += item.change > 0 ? item.change : 0; // Future in
    });

    return weekdays.map((day) => ({
      day,
      sales: grouped[day]?.sales ?? 0,
      adjustments: grouped[day]?.adjustments ?? 0,
    }));
  }, [historyItems]);

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

  // ================== Loading/Error States ==================
  if (loading) {
    return (
      <div className="h-screen flex items-center justify-center bg-white">
        <LoadingSpinner />
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

  // ================== Derived Values ==================
  const totalSalesFromHistory = historyItems.reduce((acc, i) => acc + i.units_sold, 0);

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
                if (!historyItems.length) return "N/A";
                const latestDateStr = historyItems.reduce(
                  (latest, item) =>
                    new Date(item.date) > new Date(latest) ? item.date : latest,
                  historyItems[0]?.date ?? ""
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
                  return `Today ${latestDate.toLocaleTimeString([], {
                    hour: "2-digit",
                    minute: "2-digit",
                    hour12: true,
                  })}`;
                } else if (isYesterday) {
                  return `Yesterday ${latestDate.toLocaleTimeString([], {
                    hour: "2-digit",
                    minute: "2-digit",
                    hour12: true,
                  })}`;
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
                <p className="text-lg font-bold">{totalStock}</p>
                <p className="text-[11px] opacity-70">Total</p>
              </div>

              {/* Divider */}
              <div className="w-px bg-white mx-1 h-8 opacity-50"></div>

              {/* Stock In */}
              <div className="flex-1 text-center">
                <p className="text-lg font-bold text-green-200">{totalIn}</p>
                <p className="text-[11px] opacity-70">Stock In</p>
              </div>

              {/* Divider */}
              <div className="w-px bg-white mx-1 h-8 opacity-50"></div>

              {/* Stock Out */}
              <div className="flex-1 text-center">
                <p className="text-lg font-bold text-red-200">{totalOut}</p>
                <p className="text-[11px] opacity-70">Stock Out</p>
              </div>
            </div>
          </div>

          {/* Stock Status Cards - Row Layout */}
          <div className="flex flex-row gap-2 ">
            {/* Overstock */}
            <div
              className="relative bg-[#242424] rounded-[20px] border-[5px] border-[#D4D4D4] 
                  w-[250px] h-[110px] shadow-md flex-shrink-0"
            >
              <p className="absolute left-[15px] top-[25px] text-[16px] leading-[18px] font-normal text-white/80">
                Overstock
              </p>
              <p className="absolute left-[15px] top-[63px] text-[28px] leading-[20px] font-normal text-white">
                {products.filter((p) => p.inventory.total_stock > 200).length}
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
            <div
              className="relative bg-red-600 rounded-[20px] border-[5px] border-red-300 
                  w-[250px] h-[110px] shadow-md flex-shrink-0 flex flex-col items-center justify-center"
            >
              <div className="absolute top-[12px] right-[12px] w-[35px] h-[35px] rounded-full bg-white flex items-center justify-center">
                <img
                  src={iconOutOfStock}
                  alt="Out of Stock Icon"
                  className="w-[16px] h-[16px] object-contain"
                />
              </div>
              <p className="absolute left-[15px] top-[25px] text-[16px] leading-[18px] font-normal text-white/80">
                Out of Stock
              </p>
              <p className="absolute left-[15px] top-[63px] text-[28px] leading-[20px] font-normal text-white">
                {products.filter((p) => p.inventory.total_stock === 0).length}
              </p>
            </div>

            {/* Low Stock */}
            <div
              className="relative bg-yellow-400 rounded-[20px] border-[5px] border-yellow-200 
                  w-[250px] h-[110px] shadow-md flex-shrink-0 flex flex-col items-center justify-center"
            >
              <div className="absolute top-[12px] right-[12px] w-[35px] h-[35px] rounded-full bg-white flex items-center justify-center">
                <img
                  src={iconLowStock}
                  alt="Low Stock Icon"
                  className="w-[16px] h-[16px] object-contain"
                />
              </div>
              <p className="absolute left-[15px] top-[25px] text-[16px] leading-[18px] font-normal text-white/80">
                Low Stock
              </p>
              <p className="absolute left-[15px] top-[63px] text-[28px] leading-[20px] font-normal text-white">
                {
                  products.filter(
                    (p) =>
                      p.inventory.total_stock > 0 &&
                      p.inventory.total_stock <= 10
                  ).length
                }
              </p>
            </div>
          </div>
        </div>

        {/* Chart + History */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 bg-white p-6 rounded-xl shadow-sm">
            <h2 className="text-lg font-semibold text-black mb-4">
              Stock Movement (Sales by Day)
            </h2>
            <div className="h-[260px] sm:h-[300px] lg:h-[360px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={stockData} barCategoryGap="30%">
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis dataKey="day" stroke="#9ca3af" />
                  <YAxis stroke="#9ca3af" />
                  <Tooltip contentStyle={{ borderRadius: "8px" }} />
                  <defs>
                    <linearGradient id="salesGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#ef4444" stopOpacity={0.8} />
                      <stop
                        offset="100%"
                        stopColor="#ef4444"
                        stopOpacity={0.2}
                      />
                    </linearGradient>
                  </defs>
                  <Bar
                    dataKey="sales"
                    radius={[6, 6, 0, 0]}
                    fill="url(#salesGrad)"
                  />
                  {/* Hide adjustments bar if always 0; show if you add stock-in */}
                  {/* <Bar dataKey="adjustments" ... /> */}
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-sm max-h-[400px] overflow-y-auto">
            <h2 className="text-lg font-semibold text-gray-800 mb-4">
              Recent Sales History
            </h2>
            <ul className="space-y-4">
              {filtered.map((item) => (
                <li
                  key={`${item.id}-${item.date}`}
                  className="flex justify-between items-center text-sm"
                >
                  <div className="flex items-center gap-3">
                    {item.image && (
                      <img
                        src={item.image}
                        alt={item.product_name}
                        className="w-10 h-10 object-cover rounded"
                      />
                    )}
                    <div>
                      <span className="text-gray-700 font-medium block">
                        {item.product_name}
                      </span>
                      {/* Optional: Show category */}
                      {item.category && (
                        <span className="text-gray-500 text-xs">
                          {item.category}
                        </span>
                      )}
                      <span className="text-gray-500 text-xs block">
                        {formatDate(item.date)}
                      </span>
                    </div>
                  </div>
                  <span className="font-bold text-red-500">
                    -{item.units_sold}
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
            <span>
              {(() => {
                const now = new Date();
                return Number.isFinite(now.getTime())
                  ? now.toLocaleDateString("en-US", {
                      month: "short",
                      day: "numeric",
                      year: "numeric",
                    })
                  : "—";
              })()}
            </span>
            <span className="font-semibold">Today</span>
          </div>

          <div className="grid grid-cols-3 text-center divide-x divide-gray-300">
            <div>
              <p className="text-2xl font-bold">{totalStock}</p>
              <p className="text-xs opacity-80">Total</p>
            </div>
            <div>
              <p className="text-2xl font-bold text-green-200">{totalIn}</p>
              <p className="text-xs opacity-80">Stock In</p>
            </div>
            <div>
              <p className="text-2xl font-bold text-red-200">{totalOut}</p>
              <p className="text-xs opacity-80">Stock Out</p>
            </div>
          </div>
        </div>

        {/* Stock Summary Cards */}
        <div className="grid grid-cols-3 gap-3 mb-6">
          {/* Overstock */}
          <div className="bg-black text-white p-4 rounded-xl shadow-lg relative flex flex-col items-center justify-center h-[120px]">
            <div className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white flex items-center justify-center">
              <img
                src={iconOverstock}
                alt="Overstock Icon"
                className="w-4 h-4 object-contain"
              />
            </div>
            <p className="text-xs mb-1 opacity-80">Overstock</p>
            <p className="text-xl font-bold">
              {products.filter((p) => p.inventory.total_stock > 200).length}
            </p>
          </div>

          {/* Out of Stock */}
          <div className="bg-red-600 text-white p-4 rounded-xl shadow-lg relative flex flex-col items-center justify-center h-[120px]">
            <div className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white flex items-center justify-center">
              <img
                src={iconOutOfStock}
                alt="Out of Stock Icon"
                className="w-4 h-4 object-contain"
              />
            </div>
            <p className="text-xs mb-1 opacity-80">Out of Stock</p>
            <p className="text-xl font-bold">
              {products.filter((p) => p.inventory.total_stock === 0).length}
            </p>
          </div>

          {/* Low Stock */}
          <div className="bg-yellow-400 text-white p-4 rounded-xl shadow-lg relative flex flex-col items-center justify-center h-[120px]">
            <div className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white flex items-center justify-center">
              <img
                src={iconLowStock}
                alt="Low Stock Icon"
                className="w-4 h-4 object-contain"
              />
            </div>
            <p className="text-xs mb-1 opacity-80">Low Stock</p>
            <p className="text-xl font-bold">
              {
                products.filter(
                  (p) =>
                    p.inventory.total_stock > 0 && p.inventory.total_stock <= 10
                ).length
              }
            </p>
          </div>
        </div>

        {/* Stock Movement Chart */}
        <div className="bg-white rounded-xl p-5 shadow-lg mb-6">
          <h2 className="text-md font-semibold text-gray-800 mb-4">
            Stock Movement
          </h2>
          <div className="h-[220px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={stockData} barCategoryGap="30%">
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis dataKey="day" stroke="#9ca3af" />
                <YAxis stroke="#9ca3af" />
                <Tooltip contentStyle={{ borderRadius: "8px" }} />
                <defs>
                  <linearGradient
                    id="salesMobile"
                    x1="0"
                    y1="0"
                    x2="0"
                    y2="1"
                  >
                    <stop offset="0%" stopColor="#ef4444" stopOpacity={0.8} />
                    <stop offset="100%" stopColor="#ef4444" stopOpacity={0.2} />
                  </linearGradient>
                </defs>
                <Bar
                  dataKey="sales"
                  radius={[6, 6, 0, 0]}
                  fill="url(#salesMobile)"
                />
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
              onClick={() => setShowAll((prev) => !prev)}
            >
              {showAll ? "See less" : "See all"}
            </button>
          </div>

          <ul className="space-y-4">
            {(showAll ? filtered : filtered.slice(0, 3)).map((item) => (
              <li
                key={`${item.id}-${item.date}`}
                className="flex justify-between items-center text-sm border-b border-gray-100 pb-2 last:border-none"
              >
                <div className="flex items-center gap-3">
                  {item.image && (
                    <img
                      src={item.image}
                      alt={item.product_name}
                      className="w-10 h-10 object-cover rounded-md"
                    />
                  )}
                  <div>
                    <p className="font-medium text-gray-700">
                      {item.product_name}
                    </p>
                    {/* Optional: Show category */}
                    {item.category && (
                      <p className="text-gray-500 text-xs">{item.category}</p>
                    )}
                  </div>
                </div>
                <span className="font-semibold text-red-500">
                  -{item.units_sold}
                </span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}