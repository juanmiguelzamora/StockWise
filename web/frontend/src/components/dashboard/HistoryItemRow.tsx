import type { HistoryItem } from "../../types/history";

type Props = {
  item: HistoryItem;
  mobile?: boolean;
};

export default function HistoryItemRow({ item, mobile = false }: Props) {
  const changeValue = item.change ?? item.units_sold ?? 0;
  const isNegative = changeValue < 0;

  return (
    <li
      className={`flex justify-between items-center text-sm${
        mobile ? " border-b border-gray-100 pb-2 last:border-none" : ""
      }`}
    >
      <div className="flex items-center gap-3">
        {item.image && (
          <img
            src={item.image}
            alt={item.product_name}
            className={mobile ? "w-10 h-10 object-cover rounded-md" : "w-10 h-10 object-cover rounded"}
            onError={(event) => {
              (event.currentTarget as HTMLImageElement).style.display = "none";
            }}
          />
        )}
        <div>
          {mobile ? (
            <p className="font-medium text-gray-700">{item.product_name}</p>
          ) : (
            <span className="text-gray-700 font-medium block">{item.product_name}</span>
          )}
        </div>
      </div>
      <span
        className={`font-semibold ${
          isNegative ? "text-red-500" : "text-green-500"
        }`}
      >
        {mobile
          ? isNegative
            ? `-${Math.abs(changeValue)}`
            : `+${Math.abs(changeValue)}`
          : item.change > 0
            ? `+${item.change}`
            : item.change}
      </span>
    </li>
  );
}
