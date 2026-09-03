import type { HistoryItem } from "../../types/history";
import HistoryItemRow from "./HistoryItemRow";

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
          list.map((item) => (
            <HistoryItemRow key={`${item.id}-${item.date}`} item={item} mobile />
          ))
        ) : (
          <li className="text-center text-gray-500 py-8">No history items available.</li>
        )}
      </ul>
    </div>
  );
}
