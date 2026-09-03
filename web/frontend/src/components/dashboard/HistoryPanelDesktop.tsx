import type { HistoryItem } from "../../types/history";
import HistoryItemRow from "./HistoryItemRow";

export type { HistoryItem } from "../../types/history";

export default function HistoryPanelDesktop({ items }: { items: HistoryItem[] }) {
  return (
    <div className="bg-white p-6 rounded-xl shadow-sm max-h-[400px] overflow-y-auto">
      <h2 className="text-lg font-semibold text-gray-800 mb-4">History</h2>
      <ul className="space-y-4">
        {items.length > 0 ? (
          items.map((item) => (
            <HistoryItemRow key={`${item.id}-${item.date}`} item={item} />
          ))
        ) : (
          <li className="text-center text-gray-500 py-8">No history items available.</li>
        )}
      </ul>
    </div>
  );
}
