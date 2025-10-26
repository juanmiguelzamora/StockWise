import { createContext, useContext, useState, ReactNode } from "react";

interface HistoryItem {
  product_id: number;
  product_name: string;
  image?: string | null;
  change: number;
  quantity: number;
  date: string;
}

interface InventoryContextType {
  history: HistoryItem[];
  addHistory: (item: HistoryItem) => void;
}

const InventoryContext = createContext<InventoryContextType | undefined>(undefined);

export function InventoryProvider({ children }: { children: ReactNode }) {
  const [history, setHistory] = useState<HistoryItem[]>([]);

  const addHistory = (item: HistoryItem) => {
    setHistory((prev) => [item, ...prev]); // add to top
  };

  return (
    <InventoryContext.Provider value={{ history, addHistory }}>
      {children}
    </InventoryContext.Provider>
  );
}

export function useInventory() {
  const ctx = useContext(InventoryContext);
  if (!ctx) throw new Error("useInventory must be used within InventoryProvider");
  return ctx;
}
