import { useId } from "react";
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";

export type StockData = {
  day: string;
  stockIn: number;
  stockOut: number;
  updated_at?: string;
};

type Props = {
  data: StockData[];
};

export default function StockMovementChart({ data }: Props) {
  const stockInGradId = useId();
  const stockOutGradId = useId();
  return (
    <div className="h-[260px] sm:h-[300px] lg:h-[360px]">
      {data.every((d) => d.stockIn === 0 && d.stockOut === 0) ? (
        <div className="flex items-center justify-center h-full text-gray-500">No stock movement data available.</div>
      ) : (
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} barCategoryGap="35%">
            <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
            <XAxis dataKey="day" stroke="#9ca3af" />
            <YAxis stroke="#9ca3af" />
            <Tooltip contentStyle={{ borderRadius: "8px" }} />

            <defs>
              <linearGradient id={stockInGradId} x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#22c55e" stopOpacity={0.9} />
                <stop offset="100%" stopColor="#22c55e" stopOpacity={0.3} />
              </linearGradient>
              <linearGradient id={stockOutGradId} x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#ef4444" stopOpacity={0.9} />
                <stop offset="100%" stopColor="#ef4444" stopOpacity={0.3} />
              </linearGradient>
            </defs>

            <Bar dataKey="stockIn" name="Stock In" radius={[6, 6, 0, 0]} fill={`url(#${stockInGradId})`} />
            <Bar dataKey="stockOut" name="Stock Out" radius={[6, 6, 0, 0]} fill={`url(#${stockOutGradId})`} />
          </BarChart>
        </ResponsiveContainer>
      )}
    </div>
  );
}
