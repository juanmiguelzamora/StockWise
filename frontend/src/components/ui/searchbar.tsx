import { useState } from "react";
import type { ChangeEventHandler } from "react";

interface SearchBarProps {
  value: string;
  onChange: ChangeEventHandler<HTMLInputElement>;
  placeholder?: string;
}

export default function SearchBar({
  value,
  onChange,
  placeholder,
}: SearchBarProps) {
  const [isFocused, setIsFocused] = useState(false);

  return (
    <div
      className={`relative w-full max-w-[1268px] h-[50px] rounded-full flex items-center px-5 transition-all ${
        isFocused
          ? "border-2 border-blue-500 bg-white shadow-md"
          : "border border-gray-200 bg-white"
      }`}
    >
      {/* Search Icon */}
      <div className="flex items-center justify-center mr-3">
        <img
          src="/src/assets/iconsearch.png"
          alt="Search icon"
          className="w-4 h-4 opacity-50 pointer-events-none"
          draggable={false}
        />
      </div>

      {/* Input */}
      <input
        type="text"
        value={value}
        onChange={onChange}
        placeholder={placeholder || "Search Here..."}
        className="flex-1 bg-transparent text-sm placeholder-gray-400 text-gray-700 outline-none"
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
      />
    </div>
  );
}
