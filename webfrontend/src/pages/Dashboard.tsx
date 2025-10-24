import { useEffect, useState, useMemo, useId } from "react";
import { useNavigate } from "react-router-dom";
import api from "../services/api";
import { Legend } from "recharts";
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
  id?: number;
  sku?: string;
  name?: string;
  description?: string;
  category?: string;
  image_url?: string;
  updated_at?: string; // ISO date string
  inventory?: {
    stock_in?: number;
    stock_out?: number;
    total_stock?: number;
    average_daily_sales?: number;
    stock_status?: "out_of_stock" | "low_stock" | "in_stock";
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
  stockIn: number;
  stockOut: number;
  updated_at?: string;
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
    const fetchProducts = async () => {
      setLoading(true);
      setError(""); // Reset error on retry
      try {
        const prodRes = await api.get("/products/?ordering=-updated_at");
        // Improved null handling: Ensure data is array, filter out invalid items
        const rawData = prodRes?.data || [];
        if (!Array.isArray(rawData)) {
          throw new Error("Invalid response format: expected array");
        }
        const productsData: BackendProduct[] = rawData
          .filter(
            (item): item is BackendProduct => !!item && typeof item === "object"
          )
          .map((item) => ({
            ...item,
            inventory: {
              ...(item.inventory || {}),
              stock_in: (item.inventory as any)?.stock_in || 0,
              stock_out: (item.inventory as any)?.stock_out || 0,
              total_stock: (item.inventory as any)?.total_stock || 0,
            },
          }));
        setProducts(productsData);
      } catch (err: any) {
        console.error("Error fetching products:", err.response?.data || err);
        setError("Failed to load products");
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  // ================== Fetch / Derive History ==================
  useEffect(() => {
    if (!products.length) return; // wait until products are loaded

    const deriveHistory = () => {
      const derivedHistory: HistoryItem[] = products
        .filter((p) => p.id && p.name && p.sku) // Filter invalid products
        .map((p) => ({
          id: p.id || 0,
          product_name: p.name || "Unknown Product",
          sku: p.sku || "N/A",
          image: p.image_url
            ? `${
                import.meta.env.VITE_API_BASE_URL || "http://localhost:8000"
              }/media/${p.image_url}`
            : "/placeholder.png",
          category: p.category || "Uncategorized",
          units_sold: p.inventory?.stock_out ?? 0,
          date: p.updated_at || new Date().toISOString(),
          change: p.inventory?.stock_out ?? 0,
        }));
      setHistoryItems(derivedHistory);
      setFiltered(derivedHistory);
    };

    deriveHistory();
  }, [products]); // depends on products

  // ================== Computed Totals ==================
  const totalStock = useMemo(
    () => products.reduce((acc, p) => acc + (p.inventory?.total_stock ?? 0), 0),
    [products]
  );

  const totalIn = useMemo(
    () => products.reduce((acc, p) => acc + (p.inventory?.stock_in ?? 0), 0),
    [products]
  );

  const totalOut = useMemo(
    () => products.reduce((acc, p) => acc + (p.inventory?.stock_out ?? 0), 0),
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
  const formatDate = (dateStr?: string): string => {
  if (!dateStr) return "";

  const date = new Date(dateStr);
  if (isNaN(date.getTime())) return ""; // Invalid date

  const today = new Date();

  // Compare dates in Manila timezone
  const dateManila = new Date(
    date.toLocaleString("en-US", { timeZone: "Asia/Manila" })
  );
  const todayManila = new Date(
    today.toLocaleString("en-US", { timeZone: "Asia/Manila" })
  );

  if (
    dateManila.getFullYear() === todayManila.getFullYear() &&
    dateManila.getMonth() === todayManila.getMonth() &&
    dateManila.getDate() === todayManila.getDate()
  ) {
    return (
      "Today " +
      date.toLocaleTimeString("en-US", {
        hour: "2-digit",
        minute: "2-digit",
        timeZone: "Asia/Manila",
      })
    );
  }

  return date.toLocaleString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    timeZone: "Asia/Manila",
  });
};


 const getWeekday = (dateStr?: string): string => {
  if (!dateStr) return "Sat"; // Default fallback
  const date = new Date(dateStr);
  if (isNaN(date.getTime())) return "Sat";
  return date.toLocaleDateString("en-US", { 
    weekday: "short", 
    timeZone: "Asia/Manila" 
  });
};
  // ================== Chart Computation ==================
  const stockData: StockData[] = useMemo(() => {
    if (!products.length) return [];

    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const grouped: Record<string, { stockIn: number; stockOut: number }> = {};

    weekdays.forEach((day) => {
      grouped[day] = { stockIn: 0, stockOut: 0 };
    });

    products.forEach((p) => {
      const day = getWeekday(p.updated_at);
      if (!grouped[day]) grouped[day] = { stockIn: 0, stockOut: 0 };

      grouped[day].stockIn += p.inventory?.stock_in ?? 0;
      grouped[day].stockOut += p.inventory?.stock_out ?? 0;
    });

    return weekdays.map((day) => ({
      day,
      stockIn: grouped[day]?.stockIn ?? 0,
      stockOut: grouped[day]?.stockOut ?? 0,
    }));
  }, [products]);
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

  // ================== Empty State ==================
  if (!products || products.length === 0) {
    return (
      <div className="h-screen flex items-center justify-center bg-gray-100">
        <div className="text-center p-8">
          <h2 className="text-2xl font-bold text-gray-800 mb-4">
            No Products Found
          </h2>
          <p className="text-gray-600 mb-6">
            Your inventory is empty. Add products to view the dashboard.
          </p>
          <button
            onClick={() => navigate("/products/new")} // Adjust route as needed
            className="bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-4 rounded-lg transition-colors"
          >
            Add First Product
          </button>
        </div>
      </div>
    );
  }

  // ================== Derived Values ==================
  const totalSalesFromHistory = historyItems.reduce(
    (acc, i) => acc + (i.units_sold ?? 0),
    0
  );

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
                    new Date(item.date ?? "") > new Date(latest)
                      ? item.date ?? ""
                      : latest,
                  historyItems[0]?.date ?? ""
                );
                if (!latestDateStr) return "N/A";
                const latestDate = new Date(latestDateStr);
                if (isNaN(latestDate.getTime())) return "N/A";
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
                {
                  products.filter((p) => (p.inventory?.total_stock ?? 0) > 200)
                    .length
                }
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
                {
                  products.filter((p) => (p.inventory?.total_stock ?? 0) === 0)
                    .length
                }
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
                  products.filter((p) => {
                    const stock = p.inventory?.total_stock ?? 0;
                    return stock > 0 && stock <= 10;
                  }).length
                }
              </p>
            </div>
          </div>
        </div>

        {/* Chart + History */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 bg-white p-6 rounded-xl shadow-sm">
            <h2 className="text-lg font-semibold text-black mb-4">
              Stock Movement
            </h2>
            {/* ✅ Display last updated time using first element (latest) */}
            {stockData?.length > 0 && stockData[0]?.updated_at && (
              <p className="text-sm text-gray-500 mb-4">
                Last updated:{" "}
                {new Date(stockData[0].updated_at).toLocaleString("en-US", {
                  year: "numeric",
                  month: "short",
                  day: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                })}
              </p>
            )}

            <div className="h-[260px] sm:h-[300px] lg:h-[360px]">
              {stockData.every((d) => d.stockIn === 0 && d.stockOut === 0) ? (
                <div className="flex items-center justify-center h-full text-gray-500">
                  No stock movement data available.
                </div>
              ) : (
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={stockData} barCategoryGap="35%">
                    <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                    <XAxis dataKey="day" stroke="#9ca3af" />
                    <YAxis stroke="#9ca3af" />
                    <Tooltip contentStyle={{ borderRadius: "8px" }} />

                    <defs>
                      {/* Green gradient for Stock In */}
                      <linearGradient
                        id="stockInGrad"
                        x1="0"
                        y1="0"
                        x2="0"
                        y2="1"
                      >
                        <stop
                          offset="0%"
                          stopColor="#22c55e"
                          stopOpacity={0.9}
                        />{" "}
                        {/* green-500 */}
                        <stop
                          offset="100%"
                          stopColor="#22c55e"
                          stopOpacity={0.3}
                        />
                      </linearGradient>

                      {/* Red gradient for Stock Out */}
                      <linearGradient
                        id="stockOutGrad"
                        x1="0"
                        y1="0"
                        x2="0"
                        y2="1"
                      >
                        <stop
                          offset="0%"
                          stopColor="#ef4444"
                          stopOpacity={0.9}
                        />{" "}
                        {/* red-500 */}
                        <stop
                          offset="100%"
                          stopColor="#ef4444"
                          stopOpacity={0.3}
                        />
                      </linearGradient>
                    </defs>

                    {/* Green for Stock In */}
                    <Bar
                      dataKey="stockIn"
                      name="Stock In"
                      radius={[6, 6, 0, 0]}
                      fill="url(#stockInGrad)"
                    />

                    {/* Red for Stock Out */}
                    <Bar
                      dataKey="stockOut"
                      name="Stock Out"
                      radius={[6, 6, 0, 0]}
                      fill="url(#stockOutGrad)"
                    />
                  </BarChart>
                </ResponsiveContainer>
              )}
            </div>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-sm max-h-[400px] overflow-y-auto">
            <h2 className="text-lg font-semibold text-gray-800 mb-4">
              History
            </h2>
            <ul className="space-y-4">
              {filtered.length > 0 ? (
                filtered.map((item) => (
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
                          onError={(e) => {
                            e.currentTarget.style.display = "none";
                          }} // Hide broken images
                        />
                      )}
                      <div>
                        <span className="text-gray-700 font-medium block">
                          {item.product_name}
                        </span>
                      </div>
                    </div>
                    <span
                      className={`font-semibold ${
                        item.change < 0 ? "text-red-500" : "text-green-500"
                      }`}
                    >
                      {item.change > 0 ? `+${item.change}` : item.change}
                    </span>
                  </li>
                ))
              ) : (
                <li className="text-center text-gray-500 py-8">
                  No history items available.
                </li>
              )}
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
              {
                products.filter((p) => (p.inventory?.total_stock ?? 0) > 200)
                  .length
              }
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
              {
                products.filter((p) => (p.inventory?.total_stock ?? 0) === 0)
                  .length
              }
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
                products.filter((p) => {
                  const stock = p.inventory?.total_stock ?? 0;
                  return stock > 0 && stock <= 10;
                }).length
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
            {stockData.every((d) => d.stockIn === 0 && d.stockOut === 0) ? (
              <div className="flex items-center justify-center h-full text-gray-500">
                No stock movement data available.
              </div>
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={stockData} barCategoryGap="35%">
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis dataKey="day" stroke="#9ca3af" />
                  <YAxis stroke="#9ca3af" />
                  <Tooltip contentStyle={{ borderRadius: "8px" }} />

                  <defs>
                    {/* Green gradient for Stock In */}
                    <linearGradient
                      id="stockInGrad"
                      x1="0"
                      y1="0"
                      x2="0"
                      y2="1"
                    >
                      <stop offset="0%" stopColor="#22c55e" stopOpacity={0.9} />{" "}
                      {/* green-500 */}
                      <stop
                        offset="100%"
                        stopColor="#22c55e"
                        stopOpacity={0.3}
                      />
                    </linearGradient>

                    {/* Red gradient for Stock Out */}
                    <linearGradient
                      id="stockOutGrad"
                      x1="0"
                      y1="0"
                      x2="0"
                      y2="1"
                    >
                      <stop offset="0%" stopColor="#ef4444" stopOpacity={0.9} />{" "}
                      {/* red-500 */}
                      <stop
                        offset="100%"
                        stopColor="#ef4444"
                        stopOpacity={0.3}
                      />
                    </linearGradient>
                  </defs>

                  {/* Green for Stock In */}
                  <Bar
                    dataKey="stockIn"
                    name="Stock In"
                    radius={[6, 6, 0, 0]}
                    fill="url(#stockInGrad)"
                  />

                  {/* Red for Stock Out */}
                  <Bar
                    dataKey="stockOut"
                    name="Stock Out"
                    radius={[6, 6, 0, 0]}
                    fill="url(#stockOutGrad)"
                  />
                </BarChart>
              </ResponsiveContainer>
            )}
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
            {(showAll ? filtered : filtered.slice(0, 3)).length > 0 ? (
              (showAll ? filtered : filtered.slice(0, 3)).map((item) => {
                // Determine the change value safely
                const changeValue = item.change ?? item.units_sold ?? 0;
                const isNegative = changeValue < 0;

                return (
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
                          onError={(e) => {
                            e.currentTarget.style.display = "none";
                          }} // Hide broken images
                        />
                      )}
                      <div>
                        <p className="font-medium text-gray-700">
                          {item.product_name}
                        </p>
                      </div>
                    </div>

                    {/* ✅ Color + Sign */}
                    <span
                      className={`font-semibold ${
                        isNegative ? "text-red-500" : "text-green-500"
                      }`}
                    >
                      {isNegative
                        ? `-${Math.abs(changeValue)}`
                        : `+${Math.abs(changeValue)}`}
                    </span>
                  </li>
                );
              })
            ) : (
              <li className="text-center text-gray-500 py-8">
                No history items available.
              </li>
            )}
          </ul>
        </div>
      </div>
    </div>
  );
}
