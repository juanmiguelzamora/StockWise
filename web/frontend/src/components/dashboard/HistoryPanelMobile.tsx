import type { HistoryItem } from "./HistoryPanelDesktop";

type Props = {
  items: HistoryItem[];
  showAll: boolean;
  onToggleShowAll: () => void;
};

export default function HistoryPanelMobile({ items, showAll, onToggleShowAll }: Props) {
  const list = showAll ? items : items.slice(0, 3);
  return (
    <div className="bg-white rounded-xl p-5 shadow-lg">
      <div className="flex justify-between items-center mb-3">
        <h2 className="text-md font-semibold text-gray-800">History</h2>
        <button className="text-blue-500 text-sm hover:underline sm:hidden" onClick={onToggleShowAll}>
          {showAll ? "See less" : "See all"}
        </button>
      </div>
      <ul className="space-y-4">
        {list.length > 0 ? (
          list.map((item) => {
            const changeValue = item.change ?? item.units_sold ?? 0;
            const isNegative = changeValue < 0;
            return (
              <li key={`${item.id}-${item.date}`} className="flex justify-between items-center text-sm border-b border-gray-100 pb-2 last:border-none">
                <div className="flex items-center gap-3">
                  {item.image && (
                    <img
                      src={item.image}
                      alt={item.product_name}
                      className="w-10 h-10 object-cover rounded-md"
                      onError={(e) => {
                        (e.currentTarget as HTMLImageElement).style.display = "none";
                      }}
                    />
                  )}
                  <div>
                    <p className="font-medium text-gray-700">{item.product_name}</p>
                  </div>
                </div>
                <span className={`font-semibold ${isNegative ? "text-red-500" : "text-green-500"}`}>
                  {isNegative ? `-${Math.abs(changeValue)}` : `+${Math.abs(changeValue)}`}
                </span>
              </li>
            );
          })
        ) : (
          <li className="text-center text-gray-500 py-8">No history items available.</li>
        )}
      </ul>
    </div>
  );
}
