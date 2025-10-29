interface Props {
  totalStock: number;
  totalIn: number;
  totalOut: number;
  latestChangeLabel: string;
}

export default function SummaryStats({ totalStock, totalIn, totalOut, latestChangeLabel }: Props) {
  return (
    <div className="bg-gradient-to-r from-blue-500 to-blue-600 text-white p-3 rounded-2xl shadow-md border-[6px] border-blue-200">
      <div className="text-[10px] opacity-70 mb-2 text-left">Latest Change ({latestChangeLabel || "N/A"})</div>
      <div className="flex items-center justify-between">
        <div className="flex-1 text-center">
          <p className="text-lg font-bold">{totalStock}</p>
          <p className="text-[11px] opacity-70">Total</p>
        </div>
        <div className="w-px bg-white mx-1 h-8 opacity-50" />
        <div className="flex-1 text-center">
          <p className="text-lg font-bold text-green-200">{totalIn}</p>
          <p className="text-[11px] opacity-70">Stock In</p>
        </div>
        <div className="w-px bg-white mx-1 h-8 opacity-50" />
        <div className="flex-1 text-center">
          <p className="text-lg font-bold text-red-200">{totalOut}</p>
          <p className="text-[11px] opacity-70">Stock Out</p>
        </div>
      </div>
    </div>
  );
}
