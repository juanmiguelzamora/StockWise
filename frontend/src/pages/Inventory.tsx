import { useState, useEffect, ChangeEvent } from "react";
import Navbar from "../layout/navbar";
import { ChevronDown, PlusCircle, MinusCircle } from "lucide-react";
import SearchBar from "../components/ui/searchbar";
import api from "../services/api";

// Inventory item type
interface InventoryItem {
  id: number;
  name: string;
  sku: string;
  category: string;
  qty: number;
  image: string;
  status: "In Stock" | "Low Stock" | "Out of Stock";
}

// History item type
interface HistoryItem {
  id: number;
  name: string;
  image: string;  
  change: number;
  stock: number;
  date: string;
}

// Status color mapping type
const statusColor: Record<InventoryItem["status"], string> = {
  "In Stock": "bg-green-100 text-green-600",
  "Low Stock": "bg-yellow-100 text-yellow-600",
  "Out of Stock": "bg-red-100 text-red-600",
};

export default function Inventory() {
  const [searchTerm, setSearchTerm] = useState<string>("");
  const [items, setItems] = useState<InventoryItem[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [history, setHistory] = useState<HistoryItem[]>([]);

  // Determine stock status
  const getStatus = (qty: number): InventoryItem["status"] => {
    if (qty === 0) return "Out of Stock";
    if (qty <= 10) return "Low Stock";
    return "In Stock";
  };

  useEffect(() => {
    const fetchItems = async () => {
      setLoading(true);
      try {
        const res = await api.get("inventory/");
        const rawItems: any[] = Array.isArray(res.data)
          ? res.data
          : res.data.results || [];

        const mapped: InventoryItem[] = rawItems.map((item) => ({
          id: item.product_id,
          name: item.product_name,
          sku: item.sku || "",
          category: item.category || "Uncategorized",
          qty: item.quantity,
          image: item.image || "/placeholder.png",
          status: getStatus(item.quantity),
        }));

        setItems(mapped);
      } catch (err) {
        console.error("Failed to fetch inventory:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchItems();
  }, []);

  // Update item quantity and history
  const updateItem = (id: number, newQty: number, change: number) => {
    setItems((prevItems) => {
      const updated = prevItems.map((item) =>
        item.id === id ? { ...item, qty: newQty, status: getStatus(newQty) } : item
      );

      const changedItem = prevItems.find((item) => item.id === id);
      if (changedItem) {
        addToHistory({
          id: changedItem.id,
          name: changedItem.name,
           image: changedItem.image,
          change,
          stock: newQty,
          date: new Date().toISOString(),
        });
      }

      return updated;
    });
  };

  // Increase quantity
const handleIncrease = async (id: number) => {
  try {
    const res = await api.post(`/inventory/${id}/adjust_stock/`, {
      change: 1,
      note: "Manual increase",
    });
    updateItem(id, res.data.new_quantity, +1);
  } catch (err: any) {
    console.error("Increase failed:", err);
  }
};

const handleDecrease = async (id: number) => {
  const item = items.find((i) => i.id === id);
  if (!item || item.qty === 0) return;

  try {
    const res = await api.post(`/inventory/${id}/adjust_stock/`, {
      change: -1,
      note: "Manual decrease",
    });
    updateItem(id, res.data.new_quantity, -1);
  } catch (err: any) {
    console.error("Decrease failed:", err);
  }
};


  // Add record to history
  const addToHistory = (item: HistoryItem) => {
    setHistory((prev) => [...prev, item]);
  };

  const filteredItems = items.filter((item) =>
    item.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <section className="bg-[#F2F7FA] min-h-screen p-8 pt-24">
      <Navbar />

      <div className="max-w-6xl mx-auto">
        <div className="flex items-center mb-6">
          <div className="flex-1 mr-6">
            <SearchBar
              value={searchTerm}
              onChange={(e: ChangeEvent<HTMLInputElement>) =>
                setSearchTerm(e.target.value)
              }
              placeholder="Search Here..."
            />
          </div>
          <div className="flex space-x-6">
            <button className="flex items-center gap-1 text-gray-600 hover:text-gray-900">
              Categories <ChevronDown className="w-4 h-4" />
            </button>
            <button className="flex items-center gap-1 text-gray-600 hover:text-gray-900">
              Status <ChevronDown className="w-4 h-4" />
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {filteredItems.map((item) => (
            <div
              key={item.id}
              className="bg-white shadow-md rounded-xl p-4 flex flex-col items-center"
            >
              <span
                className={`px-3 py-1 text-xs font-medium rounded-full mb-2 self-start ${statusColor[item.status]}`}
              >
                {item.status}
              </span>

              <img
                src={item.image}
                alt={item.name}
                className="w-24 h-24 object-contain mb-4"
              />

              <h3 className="font-semibold">{item.name}</h3>
              <p className="text-sm text-gray-500">SKU: {item.sku}</p>
              <p className="text-sm text-gray-500">Category: {item.category}</p>
              <p className="text-sm text-gray-700 mt-1">Qty: {item.qty}</p>

              <div className="flex gap-3 mt-3">
                <button
                  onClick={() => handleDecrease(item.id)}
                  className="text-red-500 hover:scale-110 transition"
                >
                  <MinusCircle className="w-6 h-6" />
                </button>
                <button
                  onClick={() => handleIncrease(item.id)}
                  className="text-green-500 hover:scale-110 transition"
                >
                  <PlusCircle className="w-6 h-6" />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
