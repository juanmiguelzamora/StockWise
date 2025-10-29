import StatusCard from "./StatusCard";

type ProductLike = {
  inventory?: {
    total_stock?: number;
  };
};

type Props = {
  products: ProductLike[];
  iconOverstock: string;
  iconOutOfStock: string;
  iconLowStock: string;
};

export default function StatusCardsRow({ products, iconOverstock, iconOutOfStock, iconLowStock }: Props) {
  const overCount = products.filter((p) => (p.inventory?.total_stock ?? 0) > 200).length;
  const outCount = products.filter((p) => (p.inventory?.total_stock ?? 0) === 0).length;
  const lowCount = products.filter((p) => {
    const stock = p.inventory?.total_stock ?? 0;
    return stock > 0 && stock <= 10;
  }).length;

  return (
    <div className="flex flex-row gap-2 ">
      <StatusCard
        title="Overstock"
        count={overCount}
        iconSrc={iconOverstock}
        containerClassName="relative bg-[#242424] rounded-[20px] border-[5px] border-[#D4D4D4] w-[250px] h-[110px] shadow-md flex-shrink-0"
      />
      <StatusCard
        title="Out of Stock"
        count={outCount}
        iconSrc={iconOutOfStock}
        containerClassName="relative bg-red-600 rounded-[20px] border-[5px] border-red-300 w-[250px] h-[110px] shadow-md flex-shrink-0"
      />
      <StatusCard
        title="Low Stock"
        count={lowCount}
        iconSrc={iconLowStock}
        containerClassName="relative bg-yellow-400 rounded-[20px] border-[5px] border-yellow-200 w-[250px] h-[110px] shadow-md flex-shrink-0"
      />
    </div>
  );
}
