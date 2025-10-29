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

export default function HistoryPanelDesktop({ items }: { items: HistoryItem[] }) {
  return (
    <div className="bg-white p-6 rounded-xl shadow-sm max-h-[400px] overflow-y-auto">
      <h2 className="text-lg font-semibold text-gray-800 mb-4">History</h2>
      <ul className="space-y-4">
        {items.length > 0 ? (
          items.map((item) => (
            <li key={`${item.id}-${item.date}`} className="flex justify-between items-center text-sm">
              <div className="flex items-center gap-3">
                {item.image && (
                  <img
                    src={item.image}
                    alt={item.product_name}
                    className="w-10 h-10 object-cover rounded"
                    onError={(e) => {
                      (e.currentTarget as HTMLImageElement).style.display = "none";
                    }}
                  />
                )}
                <div>
                  <span className="text-gray-700 font-medium block">{item.product_name}</span>
                </div>
              </div>
              <span className={`font-semibold ${item.change < 0 ? "text-red-500" : "text-green-500"}`}>
                {item.change > 0 ? `+${item.change}` : item.change}
              </span>
            </li>
          ))
        ) : (
          <li className="text-center text-gray-500 py-8">No history items available.</li>
        )}
      </ul>
    </div>
  );
}
