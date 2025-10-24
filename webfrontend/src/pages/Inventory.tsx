import { useState, useEffect, ChangeEvent } from "react";
import Navbar from "../layout/navbar";
import SearchBar from "../components/ui/searchbar";
import api from "../services/api";
import { useInventory } from "../contexts/InventoryContext"; // ✅ added

interface InventoryItem {
  inventory_id: number;
  product_id: number;
  product_name: string;
  sku?: string | null;
  category?: string | null;
  quantity: number;
  image?: string | null;
  stock_status?: string;
}

interface HistoryItem {
  product_id: number;
  product_name: string;
  image?: string | null;
  change: number;
  quantity: number;
  date: string;
}

interface InventoryProps {
  onStockChange?: (historyItem: HistoryItem) => void;
}

// Helper function to determine stock status
function getStockStatus(quantity: number): string {
  if (quantity === 0) return "out_of_stock";
  if (quantity > 0 && quantity <= 5) return "low_stock";
  return "in_stock";
}

export default function Inventory({ onStockChange }: InventoryProps) {
  const [searchTerm, setSearchTerm] = useState<string>("");
  const [items, setItems] = useState<InventoryItem[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [inputQuantities, setInputQuantities] = useState<Record<number, number | "">>({});

  const { addHistory } = useInventory(); // ✅ access shared history context

  // ✅ Fetch inventory items from backend
  useEffect(() => {
    const fetchItems = async () => {
      setLoading(true);
      try {
        const res = await api.get("inventory/");
        const rawItems: any[] = Array.isArray(res.data) ? res.data : res.data.results || [];

        const mapped: InventoryItem[] = rawItems.map((item) => ({
          inventory_id: item.id,
          product_id: item.product.id,
          product_name: item.product.name,
          sku: item.product.sku ?? null,
          category: item.product.category ?? null,
          quantity: item.product.inventory?.total_stock ?? item.total_stock ?? 0,
        image: item.product.image_url
  ? `${import.meta.env.VITE_API_BASE_URL || "http://localhost:8000"}/media/${item.product.image_url}`
  : null,

          stock_status: item.product.inventory?.stock_status ?? "unknown",
        }));

        setItems(mapped);
      } catch (err) {
        console.error("❌ Failed to fetch inventory:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchItems();
  }, []);
  

//history
  const updateItem = (product_id: number, newQuantity: number, clickChange = 0) => {
  setItems((prev) => {
    const target = prev.find((i) => i.product_id === product_id);
    if (!target) return prev;

    const updated = prev.map((i) =>
      i.product_id === product_id
        ? {
            ...i,
            quantity: newQuantity,
            stock_status: getStockStatus(newQuantity),
          }
        : i
    );

    const sorted = [...updated].sort((a, b) => b.quantity - a.quantity);

    const record: HistoryItem = {
      product_id: target.product_id,
      product_name: target.product_name,
      image: target.image ?? null,
      change: clickChange, // ✅ Only record the number of clicks (+1 or -1)
      quantity: newQuantity,
      date: new Date().toISOString(),
    };

    addHistory(record); // ✅ push to shared context
    onStockChange?.(record);
    return sorted;
  });
};

  // ✅ Save quantity change via PATCH to backend
  const handleSave = async (product_id: number) => {
    const value = inputQuantities[product_id];
    const newQuantity = value === "" || value === undefined ? 0 : Number(value);

    const item = items.find((i) => i.product_id === product_id);
    if (!item || !item.sku) return;

    try {
      await api.patch(`/products/${item.sku}/`, { quantity: newQuantity });
      updateItem(product_id, newQuantity);
      alert(`✅ Quantity for ${item.product_name} updated successfully!`);
    } catch (err) {
      console.error("❌ Failed to update stock:", err);
      alert("❌ Failed to update stock");
    }
  };

const handleIncrease = async (product_id: number) => {
  const item = items.find((i) => i.product_id === product_id);
  if (!item || !item.sku) return;

  const newQuantity = item.quantity + 1;

  try {
    // ✅ 1. Update product stock
    await api.patch(`/products/${item.sku}/`, { quantity: newQuantity });

    // ✅ 2. Update local state
    updateItem(product_id, newQuantity, +1);
    setInputQuantities((prev) => ({ ...prev, [product_id]: newQuantity }));

    // ✅ 3. Notify dashboard to refresh its history (instead of posting)
    localStorage.setItem("refreshHistory", Date.now().toString());
  } catch (err) {
    console.error("❌ Failed to increase stock:", err);
  }
};

const handleDecrease = async (product_id: number) => {
  const item = items.find((i) => i.product_id === product_id);
  if (!item || !item.sku) return;

  const newQuantity = Math.max(item.quantity - 1, 0);

  try {
    // ✅ 1. Update product stock
    await api.patch(`/products/${item.sku}/`, { quantity: newQuantity });

    // ✅ 2. Update local state
    updateItem(product_id, newQuantity, -1);
    setInputQuantities((prev) => ({ ...prev, [product_id]: newQuantity }));

    // ✅ 3. Notify dashboard to refresh its history
    localStorage.setItem("refreshHistory", Date.now().toString());
  } catch (err) {
    console.error("❌ Failed to decrease stock:", err);
  }
};

  // ✅ Handle quantity input changes
  const handleInputChange = (product_id: number, value: string) => {
    if (value === "") {
      setInputQuantities((prev) => ({ ...prev, [product_id]: "" as any }));
      return;
    }

    const num = parseInt(value, 10);
    if (!isNaN(num) && num >= 0) {
      setInputQuantities((prev) => ({ ...prev, [product_id]: num }));
    }
  };

const filteredItems = items
  .filter((i) =>
    i.product_name.toLowerCase().includes(searchTerm.toLowerCase())
  )
  .sort((a, b) => a.product_name.localeCompare(b.product_name));


  return (
    <section className="bg-[#F2F7FA] min-h-screen p-8 pt-24">
      <Navbar />
      <div className="max-w-6xl mx-auto">
        {/* 🔍 Search + Filter */}
        <div className="flex flex-col sm:flex-row sm:items-center mb-6 sm:space-x-6">
          <div className="flex-1 mb-3 sm:mb-0 sm:mr-6">
            <SearchBar
              value={searchTerm}
              onChange={(e: ChangeEvent<HTMLInputElement>) => setSearchTerm(e.target.value)}
              placeholder="Search Here..."
            />
          </div>
          
        </div>

        {/* 📦 Inventory Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {filteredItems.map((item) => (
            <div key={item.inventory_id} className="bg-white shadow-md rounded-xl p-4 sm:p-6 relative">
              {/* Badge */}
              <span
                className={`absolute top-2 right-3 text-xs font-medium px-3 py-1 rounded-full ${
                  item.stock_status === "out_of_stock"
                    ? "bg-red-100 text-red-600"
                    : item.stock_status === "low_stock"
                    ? "bg-yellow-100 text-yellow-700"
                    : "bg-green-100 text-green-700"
                }`}
              >
                {item.stock_status === "out_of_stock"
                  ? "Out of Stock"
                  : item.stock_status === "low_stock"
                  ? "Low Stock"
                  : "In Stock"}
              </span>

              {/* Image */}
              <div className="flex justify-center mb-4">
                <img
                  src={item.image ?? "/placeholder.png"}
                  alt={item.product_name}
                  className="w-28 h-28 object-contain"
                />
              </div>

              {/* Info */}
              <h3 className="font-semibold text-center">{item.product_name}</h3>
              <div className="mt-2 space-y-1 text-center">
                <p className="text-sm text-gray-500">SKU: {item.sku ?? "N/A"}</p>
                <p className="text-sm text-gray-500">Category: {item.category ?? "—"}</p>
                <p className="text-sm text-gray-700">Qty: {item.quantity}</p>
              </div>

              {/* Actions */}
              <div className="flex justify-center items-center gap-2 mt-4">
                <button
                  onClick={() => handleDecrease(item.product_id)}
                  className="flex items-center justify-center w-8 h-8 rounded-full bg-red-100"
                >
                  <img src="/icon_minusbtn.png" alt="Decrease" className="w-4 h-4" />
                </button>

                <input
                  type="number"
                  min={0}
                  value={
                    inputQuantities[item.product_id] === ""
                      ? ""
                      : inputQuantities[item.product_id] ?? item.quantity
                  }
                  onChange={(e) => handleInputChange(item.product_id, e.target.value)}
                  onBlur={() => {
                    if (inputQuantities[item.product_id] === "") {
                      setInputQuantities((prev) => ({ ...prev, [item.product_id]: 0 }));
                    }
                  }}
                  onKeyDown={(e) => {
                    if (e.key === "Enter") {
                      e.preventDefault();
                      handleSave(item.product_id);
                    }
                  }}
                  className="w-14 text-center border border-gray-300 rounded-md px-2 py-1 text-sm"
                />

                <button
                  onClick={() => handleIncrease(item.product_id)}
                  className="flex items-center justify-center w-8 h-8 rounded-full bg-green-100"
                >
                  <img src="/icon_plusbtn.png" alt="Increase" className="w-4 h-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
