import type { ChangeEvent } from "react";
import Navbar from "../layout/navbar";
import SearchBar from "../components/ui/searchbar";
import { useInventoryLogic } from "../hooks/InventoryLogic";
import InventoryCard from "../components/inventory/InventoryCard";

export default function Inventory() {
  const {
    searchTerm,
    setSearchTerm,
    inputQuantities,
    filteredItems,
    handleDecrease,
    handleIncrease,
    handleInputChange,
    handleSave,
  } = useInventoryLogic();

  return (
    <section className="bg-[#F2F7FA] min-h-screen p-8 pt-24">
      <Navbar />
      <div className="max-w-6xl mx-auto">
        {/* 🔍 Search + Filter */}
        <div className="flex flex-col sm:flex-row sm:items-center mb-6 sm:space-x-6">
          <div className="flex-1 mb-3 sm:mb-0 sm:mr-6">
            <SearchBar
              value={searchTerm}
              onChange={(e: ChangeEvent<HTMLInputElement>) => setSearchTerm(e.target.value)}
              placeholder="Search Here..."
            />
          </div>
         
        </div>

        {/* 📦 Inventory Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {filteredItems.map((item) => (
            <InventoryCard
              key={item.inventory_id}
              item={item}
              quantityValue={
                inputQuantities[item.product_id] === ""
                  ? ""
                  : inputQuantities[item.product_id] ?? item.quantity
              }
              onDecrease={handleDecrease}
              onIncrease={handleIncrease}
              onChange={handleInputChange}
              onSave={handleSave}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
