import { useEffect, useState, useMemo } from "react";
import api from "../services/api";

export interface BackendProduct {
  id: number;
  sku: string;
  name: string;
  description?: string;
  category: string;
  image_url?: string;
  updated_at?: string;
  inventory: {
    stock_in: number;
    stock_out: number;
    total_stock: number;
    average_daily_sales?: number;
    stock_status: "out_of_stock" | "low_stock" | "in_stock";
  };
}

export interface HistoryItem {
  id: number;
  product_name: string;
  sku: string;
  image: string;
  category?: string;
  units_sold: number;
  date: string;
  change: number;
}

export interface StockData {
  day: string;
  stockIn: number;
  stockOut: number;
}

// ================== HOOK ==================
export function useDashboardLogic() {
  const [products, setProducts] = useState<BackendProduct[]>([]);
  const [historyItems, setHistoryItems] = useState<HistoryItem[]>([]);
  const [filtered, setFiltered] = useState<HistoryItem[]>([]);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [searching, setSearching] = useState(false);
  const [error, setError] = useState("");

  const fallbackHistory = useMemo<HistoryItem[]>(() => {
    if (!products || products.length === 0) return [];
    const base = (import.meta.env.VITE_API_BASE_URL || "http://localhost:8000").replace(/\/$/, "");
    const list = products.map((p) => {
      const d = p.updated_at || new Date().toISOString();
      let image = "/placeholder.png";
      const raw = p.image_url;
      if (typeof raw === "string" && raw.trim()) {
        const val = raw.trim();
        if (/^https?:\/\//i.test(val)) image = val;
        else if (val.startsWith("/")) image = `${base}${val}`;
        else image = `${base}/media/${val}`;
      }
      const stockIn = p.inventory?.stock_in || 0;
      const stockOut = p.inventory?.stock_out || 0;
      return {
        id: p.id,
        product_name: p.name || "",
        sku: p.sku || "",
        image,
        category: p.category || "",
        units_sold: stockOut,
        date: new Date(d).toISOString(),
        change: stockIn - stockOut,
      } as HistoryItem;
    });
    return list
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
      .slice(0, 10);
  }, [products]);

  
  useEffect(() => {
    const fetchProducts = async () => {
      setLoading(true);
      try {
        const { data } = await api.get<BackendProduct[]>("/products/?ordering=-updated_at");
        setProducts(data || []);
      } catch (err) {
        console.error(err);
        setError("Failed to load products");
      } finally {
        setLoading(false);
      }
    };
    fetchProducts();
  }, []);

  // ================== Fetch History ==================
  useEffect(() => {
    const fetchHistory = async () => {
      setLoading(true);
      try {
        const res = await api.get("/stock/history/");
        const rawHistory: any[] = Array.isArray(res.data)
          ? res.data
          : res.data.results || [];

        const mappedHistory: HistoryItem[] = rawHistory.map((item) => {
          const timestamp = item.timestamp || item.updated_at || item.date || new Date().toISOString();

          const base = (import.meta.env.VITE_API_BASE_URL || "http://localhost:8000").replace(/\/$/, "");
          const rawImg: string | undefined = item.image || item.image_url;
          let image = "/placeholder.png";
          if (typeof rawImg === "string" && rawImg.trim()) {
            const val = rawImg.trim();
            if (/^https?:\/\//i.test(val)) {
              image = val; // already absolute URL
            } else if (val.startsWith("/")) {
              image = `${base}${val}`; // already a path like /media/...
            } else {
              image = `${base}/media/${val}`; // filename relative to /media
            }
          }

          // derive change value from multiple possible fields
          const rawChange =
            item.change ??
            item.quantity ??
            item.qty ??
            item.delta ??
            item.stock_change ??
            item.units_sold ??
            0;
          const numChange = typeof rawChange === "string" ? Number(rawChange) : Number(rawChange);

          return {
            id: item.id,
            product_name: item.product_name || "",
            sku: item.sku || "",
            image,
            category: item.category || "",
            units_sold: (item.units_sold ?? Math.abs(Number.isFinite(numChange) ? numChange : 0)) || 0,
            date: new Date(timestamp).toISOString(),
            change: Number.isFinite(numChange) ? numChange : 0,
          };
        });

        mappedHistory.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
        setHistoryItems(mappedHistory);
        setFiltered(mappedHistory);
      } catch (err) {
        console.error(err);
        setError("Failed to load history");
      } finally {
        setLoading(false);
      }
    };
    fetchHistory();
  }, []);

  // ================== Computed Values ==================
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
  const totalSalesFromHistory = useMemo(() => historyItems.reduce((acc, i) => acc + (i.units_sold || 0), 0), [historyItems]);

  // ================== Search Filter ==================
  useEffect(() => {
    if (!query) {
      setFiltered(historyItems.length ? historyItems : fallbackHistory);
      return;
    }
    setSearching(true);
    const timeoutId = setTimeout(() => {
      const q = query.toLowerCase().trim();
      const source = historyItems.length ? historyItems : fallbackHistory;
      const out = source.filter(
        (it) =>
          it.product_name.toLowerCase().includes(q) ||
          it.sku.toLowerCase().includes(q) ||
          (it.category || "").toLowerCase().includes(q)
      );
      setFiltered(out);
      setSearching(false);
    }, 250);
    return () => clearTimeout(timeoutId);
  }, [query, historyItems, fallbackHistory]);

  useEffect(() => {
    if (historyItems.length === 0 && !query) {
      setFiltered(fallbackHistory);
    }
  }, [, fallbackHistory, query]);

  // ================== Chart Data ==================
  const stockData: StockData[] = useMemo(() => {
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const grouped: Record<string, { stockIn: number; stockOut: number }> = {};

    weekdays.forEach((day) => (grouped[day] = { stockIn: 0, stockOut: 0 }));

    products.forEach((product) => {
      const dateStr = product.updated_at || new Date().toISOString();
      const day = new Date(dateStr).toLocaleDateString("en-US", { weekday: "short" });
      if (!grouped[day]) grouped[day] = { stockIn: 0, stockOut: 0 };
      grouped[day].stockIn += product.inventory?.stock_in ?? 0;
      grouped[day].stockOut += product.inventory?.stock_out ?? 0;
    });

    return weekdays.map((day) => ({ day, stockIn: grouped[day].stockIn, stockOut: grouped[day].stockOut }));
  }, [products]);

  return {
    products,
    historyItems,
    filtered,
    query,
    setQuery,
    loading,
    searching,
    error,
    totalStock,
    totalIn,
    totalOut,
    totalSalesFromHistory,
    stockData,
  };
} 
