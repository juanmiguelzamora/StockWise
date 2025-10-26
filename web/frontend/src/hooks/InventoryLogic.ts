import { useState, useEffect, ChangeEvent } from "react";
import api from "../services/api";
import { useInventory } from "../contexts/InventoryContext";

export interface InventoryItem {
  inventory_id: number;
  product_id: number;
  product_name: string;
  sku?: string | null;
  category?: string | null;
  quantity: number;
  image?: string | null;
  stock_status?: string;
}

export interface HistoryItem {
  product_id: number;
  product_name: string;
  image?: string | null;
  change: number;
  quantity: number;
  date: string;
}

export interface UseInventoryLogic {
  searchTerm: string;
  setSearchTerm: (value: string) => void;
  items: InventoryItem[];
  loading: boolean;
  inputQuantities: Record<number, number | "">;
  handleIncrease: (product_id: number) => void;
  handleDecrease: (product_id: number) => void;
  handleInputChange: (product_id: number, value: string) => void;
  handleSave: (product_id: number) => void;
  filteredItems: InventoryItem[];
}

function getStockStatus(quantity: number): string {
  if (quantity === 0) return "out_of_stock";
  if (quantity > 0 && quantity <= 5) return "low_stock";
  return "in_stock";
}

export function useInventoryLogic(onStockChange?: (item: HistoryItem) => void): UseInventoryLogic {
  const [searchTerm, setSearchTerm] = useState<string>("");
  const [items, setItems] = useState<InventoryItem[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [inputQuantities, setInputQuantities] = useState<Record<number, number | "">>({});
  const { addHistory } = useInventory();

  // ✅ Fetch items
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

  // ✅ Update single item
  const updateItem = (product_id: number, newQuantity: number, clickChange = 0) => {
    setItems((prev) => {
      const target = prev.find((i) => i.product_id === product_id);
      if (!target) return prev;

      const updated = prev.map((i) =>
        i.product_id === product_id
          ? { ...i, quantity: newQuantity, stock_status: getStockStatus(newQuantity) }
          : i
      );

      const sorted = [...updated].sort((a, b) => b.quantity - a.quantity);

      const record: HistoryItem = {
        product_id: target.product_id,
        product_name: target.product_name,
        image: target.image ?? null,
        change: clickChange,
        quantity: newQuantity,
        date: new Date().toISOString(),
      };

      addHistory(record);
      onStockChange?.(record);
      return sorted;
    });
  };

  // ✅ Save quantity
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

  // ✅ Increase / Decrease
  const handleIncrease = async (product_id: number) => {
    const item = items.find((i) => i.product_id === product_id);
    if (!item || !item.sku) return;
    const newQuantity = item.quantity + 1;
    try {
      await api.patch(`/products/${item.sku}/`, { quantity: newQuantity });
      updateItem(product_id, newQuantity, +1);
      setInputQuantities((prev) => ({ ...prev, [product_id]: newQuantity }));
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
      await api.patch(`/products/${item.sku}/`, { quantity: newQuantity });
      updateItem(product_id, newQuantity, -1);
      setInputQuantities((prev) => ({ ...prev, [product_id]: newQuantity }));
      localStorage.setItem("refreshHistory", Date.now().toString());
    } catch (err) {
      console.error("❌ Failed to decrease stock:", err);
    }
  };

  // ✅ Input change
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
    .filter((i) => i.product_name.toLowerCase().includes(searchTerm.toLowerCase()))
    .sort((a, b) => a.product_name.localeCompare(b.product_name));

  return {
    searchTerm,
    setSearchTerm,
    items,
    loading,
    inputQuantities,
    handleIncrease,
    handleDecrease,
    handleInputChange,
    handleSave,
    filteredItems,
  };
}
