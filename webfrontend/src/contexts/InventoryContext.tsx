import { createContext, useContext, useState, ReactNode } from "react";

interface Product {
  id: number;
  name: string;
  stock: number;
  change?: number;
  description?: string;
  date?: string;
}

interface InventoryContextType {
  items: Product[];
  setItems: React.Dispatch<React.SetStateAction<Product[]>>;
  handleStockChange: (item: Product) => void;
}

const InventoryContext = createContext<InventoryContextType | undefined>(undefined);

export const InventoryProvider = ({ children }: { children: ReactNode }) => {
  const [items, setItems] = useState<Product[]>([]);

  const handleStockChange = (item: Product) => {
    setItems(prev => [item, ...prev]);
  };

  return (
    <InventoryContext.Provider value={{ items, setItems, handleStockChange }}>
      {children}
    </InventoryContext.Provider>
  );
};

export const useInventory = () => {
  const ctx = useContext(InventoryContext);
  if (!ctx) throw new Error("useInventory must be used inside <InventoryProvider>");
  return ctx;
};
