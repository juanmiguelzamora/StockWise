import { useState, useEffect, ChangeEvent } from "react";
import Navbar from "../layout/navbar";
import { PlusCircle, MinusCircle } from "lucide-react";
import SearchBar from "../components/ui/searchbar";
import api from "../services/api";


// Inventory item type
interface InventoryItem {
  product_id: number;
  product_name: string;
  sku?: string | null;
  category?: string | null;
  quantity: number;
  image?: string | null;
}


// History item type
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

export default function Inventory({ onStockChange }: InventoryProps) {
  const [searchTerm, setSearchTerm] = useState<string>("");
  const [items, setItems] = useState<InventoryItem[]>([]);
  const [history, setHistory] = useState<HistoryItem[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [inputQuantities, setInputQuantities] = useState<Record<number, number | "">>({});

   
  

  // Fetch inventory
  useEffect(() => {
    const fetchItems = async () => {
      setLoading(true);
      try {
        const res = await api.get("inventory/");
        const rawItems: any[] = Array.isArray(res.data) ? res.data : res.data.results || [];

        const mapped: InventoryItem[] = rawItems.map((item) => ({
          product_id: item.product_id,
          product_name: item.product_name,
          sku: item.sku ?? null,
          category: item.category ?? null,
          quantity: item.quantity ?? 0,
          image: item.image ?? null,
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

  // Update item quantity & history
  const updateItem = (product_id: number, newQuantity: number) => {
  setItems((prevItems) => {
    const changedItem = prevItems.find((i) => i.product_id === product_id);
    if (!changedItem) return prevItems;

    const actualChange = newQuantity - changedItem.quantity;

    // Update the item
    const updated = prevItems.map((i) =>
      i.product_id === product_id ? { ...i, quantity: newQuantity } : i
    );

    // Sort by quantity descending so highest quantity comes first
    const sorted = [...updated].sort((a, b) => b.quantity - a.quantity);

    // Add to history
    const historyRecord: HistoryItem = {
      product_id: changedItem.product_id,
      product_name: changedItem.product_name,
      image: changedItem.image ?? null,
      change: actualChange,
      quantity: newQuantity,
      date: new Date().toISOString(),
    };

    setHistory((prev) => [...prev, historyRecord]);
    onStockChange?.(historyRecord);

    return sorted;
  });
};


const handleIncrease = async (product_id: number) => {
  const item = items.find((i) => i.product_id === product_id);
  if (!item) return;

  const newQuantity = item.quantity + 1;
  const change = 1;

  try {
    await api.post(`/inventory/${product_id}/adjust_stock/`, { change });
    updateItem(product_id, newQuantity);
    setInputQuantities((prev) => ({ ...prev, [product_id]: newQuantity }));
    
  } catch (err) {
    console.error("Failed to update stock:", err);
    alert("❌ Failed to update stock");
  }
};

const handleDecrease = async (product_id: number) => {
  const item = items.find((i) => i.product_id === product_id);
  if (!item) return;

  const newQuantity = Math.max(item.quantity - 1, 0);
  const change = -1;

  try {
    await api.post(`/inventory/${product_id}/adjust_stock/`, { change });
    updateItem(product_id, newQuantity);
    setInputQuantities((prev) => ({ ...prev, [product_id]: newQuantity }));
    
  } catch (err) {
    console.error("Failed to update stock:", err);
    alert("❌ Failed to update stock");
  }
};



 const handleInputChange = (product_id: number, value: string) => {
  if (value === "") {
    // Allow empty input
    setInputQuantities((prev) => ({ ...prev, [product_id]: "" as any }));
    return;
  }

  const num = parseInt(value, 10);
  if (!isNaN(num) && num >= 0) {
    setInputQuantities((prev) => ({ ...prev, [product_id]: num }));
  }
};
const handleSave = async (product_id: number) => {
  const value = inputQuantities[product_id];
  const newQuantity = value === "" || value === undefined ? 0 : Number(value);

  const item = items.find((i) => i.product_id === product_id);
  if (!item) return;

  try {
    const change = newQuantity - item.quantity;
    await api.post(`/inventory/${product_id}/adjust_stock/`, { change });
    updateItem(product_id, newQuantity);
    alert(`✅ Quantity for ${item.product_name} updated successfully!`);
  } catch (err) {
    console.error("Failed to update stock:", err);
    alert("❌ Failed to update stock");
  }
};


const filteredItems = items
  .filter((item) =>
    item.product_name.toLowerCase().includes(searchTerm.toLowerCase())
  )
  .sort((a, b) => a.product_name.localeCompare(b.product_name));
return (
  <section className="bg-[#F2F7FA] min-h-screen p-8 pt-24">
    <Navbar />

  <div className="max-w-6xl mx-auto">
  {/* Parent flex changes direction on mobile */}
  <div className="flex flex-col sm:flex-row sm:items-center mb-6 sm:space-x-6">
    {/* Search Bar */}
    <div className="flex-1 mb-3 sm:mb-0 sm:mr-6">
      <SearchBar
        value={searchTerm}
        onChange={(e: ChangeEvent<HTMLInputElement>) => setSearchTerm(e.target.value)}
        placeholder="Search Here..."
      />
    </div>

    {/* Filter buttons */}
    <div className="flex justify-center sm:justify-start space-x-6">
      <button className="flex items-center gap-1 text-gray-600 hover:text-gray-900">
        Categories
      </button>
      <button className="flex items-center gap-1 text-gray-600 hover:text-gray-900">
        Status
      </button>
        </div>
        
      </div>

     <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
  {filteredItems.map((item) => (
    
    <div
      key={item.product_id}
      className="bg-white shadow-md rounded-xl p-4 sm:p-6 flex flex-col sm:flex-col relative"
    >
{/* ✅ Mobile/List Layout */}
<div className="flex sm:hidden items-center relative bg-white rounded-lg shadow-sm p-2">
  {/* Status Badge */}
  {item.quantity === 0 ? (
    <span className="absolute top-1 right-2 bg-red-100 text-red-600 text-[10px] font-medium px-2 py-[2px] rounded-full">
      Out of Stock
    </span>
  ) : item.quantity < 10 ? (
    <span className="absolute top-1 right-2 bg-yellow-100 text-yellow-700 text-[10px] font-medium px-2 py-[2px] rounded-full">
      Low Stock
    </span>
  ) : (
    <span className="absolute top-1 right-2 bg-green-100 text-green-700 text-[10px] font-medium px-2 py-[2px] rounded-full">
      In Stock
    </span>
  )}

  {/* Product Image */}
  <img
    src={item.image ?? "/placeholder.png"}
    alt={item.product_name}
    className="w-16 h-16 object-contain mr-3"
  />


        {/* Info + Buttons */}
        <div className="flex-1">
          <h3 className="font-semibold text-gray-900">{item.product_name}</h3>
          <p className="text-sm text-gray-500">SKU: {item.sku ?? "N/A"}</p>
          <p className="text-sm text-gray-500">Category: {item.category ?? "—"}</p>
          <p className="text-sm text-gray-700">Qty: {item.quantity}</p>
        </div>

        {/* Action Buttons */}
       <div className="flex items-center gap-2 ml-0 sm:ml-4">
        

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
      ? "" // Show empty while editing
      : inputQuantities[item.product_id] ?? item.quantity
  }
  onChange={(e) => handleInputChange(item.product_id, e.target.value)}
  onBlur={() => {
    if (inputQuantities[item.product_id] === "") {
      setInputQuantities((prev) => ({
        ...prev,
        [item.product_id]: 0,
      }));
    }
  }}
  onKeyDown={(e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      handleSave(item.product_id);
    }
  }}
   className="w-14 min-w-[56px] flex-shrink-0 text-center border border-gray-300 rounded-md px-2 py-1 text-sm"
/>


  <button
    onClick={() => handleIncrease(item.product_id)}
    className="flex items-center justify-center w-8 h-8 rounded-full bg-green-100"
  >
    <img src="/icon_plusbtn.png" alt="Increase" className="w-4 h-4" />
  </button>
</div>
      </div>

      {/* Desktop/Grid Layout */}
      <div className="hidden sm:flex flex-col">
        {/* Status Badge */}
        {item.quantity === 0 ? (
          <span className="absolute top-2 right-3 bg-red-100 text-red-600 text-xs font-medium px-3 py-1 rounded-full">
            Out of Stock
          </span>
        ) : item.quantity < 10 ? (
          <span className="absolute top-2 right-3 bg-yellow-100 text-yellow-700 text-xs font-medium px-3 py-1 rounded-full">
            Low Stock
          </span>
        ) : (
          <span className="absolute top-2 right-3 bg-green-100 text-green-700 text-xs font-medium px-3 py-1 rounded-full">
            In Stock
          </span>
        )}

        {/* Product Image */}
        <div className="flex justify-center mb-4">
          <img
            src={item.image ?? "/placeholder.png"}
            alt={item.product_name}
            className="w-28 h-28 object-contain"
          />
        </div>

        {/* Product Info */}
        <h3 className="m-6 font-semibold text-center">{item.product_name}</h3>
        <div className="mt-2 space-y-1 text-left">
          <p className="text-sm text-gray-500">SKU: {item.sku ?? "N/A"}</p>
         <p className="text-sm text-gray-500"> Category: {item.category ?? "—"}</p>
          <p className="text-sm text-gray-700">Qty: {item.quantity}</p>
        </div>

        {/* Action Buttons */}
       <div className="flex justify-end items-center gap-2 mt-4">
  <button
    onClick={() => handleDecrease(item.product_id)}
    className="flex items-center justify-center w-8 h-8 rounded-full"
  >
    <img src="/icon_minusbtn.png" alt="Decrease" className="w-4 h-4" />
  </button>

<input
  type="number"
  min={0}
  value={
    inputQuantities[item.product_id] === ""
      ? "" // Show empty while editing
      : inputQuantities[item.product_id] ?? item.quantity
  }
  onChange={(e) => handleInputChange(item.product_id, e.target.value)}
  onBlur={() => {
    if (inputQuantities[item.product_id] === "") {
      setInputQuantities((prev) => ({
        ...prev,
        [item.product_id]: 0,
      }));
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
    className="flex items-center justify-center w-8 h-8 rounded-full"
  >
    <img src="/icon_plusbtn.png" alt="Increase" className="w-4 h-4" />
  </button>
</div>
</div>

{/* ✅ Hide Chrome/Edge scrollbar */}
<style>{`
  /* For Chrome, Safari and Edge */
  ::-webkit-scrollbar {
    display: none;
  }

  /* For Firefox */
  html {
    scrollbar-width: none;
  }
`}</style>
          </div>
        ))}
      </div>
    </div>
  </section>
);

}
