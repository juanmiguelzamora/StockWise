export type HistoryItem = {
  id: number;
  product_name: string;
  sku: string;
  image: string;
  category?: string;
  units_sold: number;
  date: string;
  change: number;
};
