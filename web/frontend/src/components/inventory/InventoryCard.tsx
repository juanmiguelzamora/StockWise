import type { InventoryItem } from "../../hooks/InventoryLogic";
import type { ChangeEvent } from "react";

function formatQuantity(num: number): string {
  if (num >= 1000000) return (Math.floor(num / 100000) / 10).toString().replace(/\.0$/, "") + "M";
  if (num >= 1000) return (Math.floor(num / 100) / 10).toString().replace(/\.0$/, "") + "k";
  return num.toString();
}

type Props = {
  item: InventoryItem;
  quantityValue: number | "";
  onDecrease: (product_id: number) => void;
  onIncrease: (product_id: number) => void;
  onChange: (product_id: number, value: string) => void;
  onSave: (product_id: number) => void;
};

export default function InventoryCard({
  item,
  quantityValue,
  onDecrease,
  onIncrease,
  onChange,
  onSave,
}: Props) {
  return (
    <div className="bg-white shadow-md rounded-xl p-4 sm:p-6 relative">
      <span
        className={`absolute top-2 right-3 text-xs font-medium px-3 py-1 rounded-full ${
          item.stock_status === "out_of_stock"
            ? "bg-red-100 text-red-600"
            : item.stock_status === "low_stock"
            ? "bg-yellow-100 text-yellow-700"
            : "bg-green-100 text-green-700"
        }`}
      >
        {item.stock_status === "out_of_stock" ? "Out of Stock" : item.stock_status === "low_stock" ? "Low Stock" : "In Stock"}
      </span>

      <div className="flex justify-center mb-4">
        <img src={item.image ?? "/placeholder.png"} alt={item.product_name} className="w-28 h-28 object-contain" />
      </div>

      <h3 className="font-semibold text-center">{item.product_name}</h3>
      <div className="mt-2 space-y-1 text-center">
        <p className="text-sm text-gray-500">SKU: {item.sku ?? "N/A"}</p>
        <p className="text-sm text-gray-500">Category: {item.category ?? "—"}</p>
        <p className="text-sm text-gray-700">Qty: {formatQuantity(item.quantity)}</p>
      </div>

      <div className="flex justify-center items-center gap-2 mt-4">
        <button onClick={() => onDecrease(item.product_id)} className="flex items-center justify-center w-8 h-8 rounded-full bg-red-100">
          <img src="/icon_minusbtn.png" alt="Decrease" className="w-4 h-4" />
        </button>

        <input
          type="number"
          min={0}
          value={quantityValue}
          onChange={(e: ChangeEvent<HTMLInputElement>) => onChange(item.product_id, e.target.value)}
          onBlur={() => {
            if (quantityValue === "") {
              onSave(item.product_id);
            }
          }}
          onKeyDown={(e) => {
            if (e.key === "Enter") {
              e.preventDefault();
              onSave(item.product_id);
            }
          }}
          className="w-14 text-center border border-gray-300 rounded-md px-2 py-1 text-sm"
        />

        <button onClick={() => onIncrease(item.product_id)} className="flex items-center justify-center w-8 h-8 rounded-full bg-green-100">
          <img src="/icon_plusbtn.png" alt="Increase" className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
}
