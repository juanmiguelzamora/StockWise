import { useState } from "react";
import { useNavigate } from "react-router-dom";
import iconOverstock from "../assets/icon1.png";
import iconOutOfStock from "../assets/icon2.png";
import iconLowStock from "../assets/icon3.png";

import LoadingSpinner from "../components/ui/loadingspinner";
import Navbar from "../layout/navbar";
import SummaryStats from "../components/dashboard/SummaryStats";
import StatusCardsRow from "../components/dashboard/StatusCardsRow";
import StockMovementChart from "../components/dashboard/StockMovementChart";
import HistoryPanelDesktop from "../components/dashboard/HistoryPanelDesktop";
import HistoryPanelMobile from "../components/dashboard/HistoryPanelMobile";
import { useDashboardLogic } from "../hooks/DashboardLogic";

// ================== COMPONENT ==================
export default function ProtectedDashboard() {
  const [showAll, setShowAll] = useState(false);
  const navigate = useNavigate();

  const {
    products,
    filtered,
    loading,
    error,
    totalStock,
    totalIn,
    totalOut,
    stockData,
  } = useDashboardLogic();

  // ================== Logout ==================
  const handleLogout = async () => {
    try {
      localStorage.removeItem("access");
      localStorage.removeItem("refresh");
      navigate("/login");
    } catch (err) {
      console.error("Logout error:", err);
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

  // ================== UI ==================
  return (
    <div className="h-screen bg-gray-100 flex flex-col">
      <Navbar onLogout={handleLogout} className="bg-transparent" />

      {/* Desktop View */}
      <div className="hidden lg:block flex-1 overflow-y-auto lg:overflow-hidden px-6 py-6 max-w-7xl mx-auto w-full pt-20">
        {/* Top Summary Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-1 mb-6">
          {/* Total + Stock In + Stock Out */}
          <SummaryStats
            totalStock={totalStock}
            totalIn={totalIn}
            totalOut={totalOut}
            latestChangeLabel={(() => {
              // Prefer what the UI shows (filtered). Fallback to products' updated_at.
              let latestDate: Date | null = null;
              if (filtered && filtered.length) {
                const latestFromFiltered = filtered.reduce<string>((latest, item) => {
                  const cur = item.date ?? "";
                  return new Date(cur) > new Date(latest) ? cur : latest;
                }, filtered[0]?.date ?? "");
                if (latestFromFiltered) {
                  const d = new Date(latestFromFiltered);
                  if (!isNaN(d.getTime())) latestDate = d;
                }
              }
              if (!latestDate && products?.length) {
                const latestUpdatedAt = products.reduce<string | null>((acc, p) => {
                  if (!p.updated_at) return acc;
                  if (!acc) return p.updated_at;
                  return new Date(p.updated_at) > new Date(acc) ? p.updated_at : acc;
                }, null);
                if (latestUpdatedAt) {
                  const d = new Date(latestUpdatedAt);
                  if (!isNaN(d.getTime())) latestDate = d;
                }
              }
              if (!latestDate) return "N/A";
              const today = new Date();
              const yesterday = new Date();
              yesterday.setDate(today.getDate() - 1);

              const isToday = latestDate.toDateString() === today.toDateString();

              const isYesterday = latestDate.toDateString() === yesterday.toDateString();

              if (isToday) {
                return `Today ${latestDate.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: true })}`;
              } else if (isYesterday) {
                return `Yesterday ${latestDate.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: true })}`;
              }
              return latestDate.toLocaleString("en-US", {
                month: "short",
                day: "numeric",
                hour: "2-digit",
                minute: "2-digit",
                hour12: true,
              });
            })()}
          />

          {/* Stock Status Cards - Row Layout */}
          <StatusCardsRow
            products={products}
            iconOverstock={iconOverstock}
            iconOutOfStock={iconOutOfStock}
            iconLowStock={iconLowStock}
          />
        </div>

        {/* Chart + History */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 bg-white p-6 rounded-xl shadow-sm">
            <h2 className="text-lg font-semibold text-black mb-4">
              Stock Movement
            </h2>
            {/* ✅ Display last updated time using first element (latest) */}
            {products?.length > 0 && (() => {
              const latest = products.reduce<string | null>((acc, p) => {
                if (!p.updated_at) return acc;
                if (!acc) return p.updated_at;
                return new Date(p.updated_at) > new Date(acc) ? p.updated_at : acc;
              }, null);
              return latest ? (
                <p className="text-sm text-gray-500 mb-4">
                  Last updated:{" "}
                  {new Date(latest).toLocaleString("en-US", {
                    year: "numeric",
                    month: "short",
                    day: "numeric",
                    hour: "2-digit",
                    minute: "2-digit",
                  })}
                </p>
              ) : null;
            })()}

            <StockMovementChart data={stockData} />
          </div>

          <HistoryPanelDesktop items={filtered} />
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

        <div className="bg-white rounded-xl p-5 shadow-lg mb-6">
          <h2 className="text-md font-semibold text-gray-800 mb-4">
            Stock Movement
          </h2>
          <div className="h-[220px]">
            <StockMovementChart data={stockData} />
          </div>
        </div>

        {/* History Section */}
        <HistoryPanelMobile
          items={filtered}
          showAll={showAll}
          onToggleShowAll={() => setShowAll((prev) => !prev)}
        />
      </div>
    </div>
  );
}