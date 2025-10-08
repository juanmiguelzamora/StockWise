import { useState, useCallback } from "react";
import type { ChangeEventHandler, HTMLAttributes } from "react";

interface SearchBarProps extends HTMLAttributes<HTMLDivElement> {
  value: string;
  onChange: ChangeEventHandler<HTMLInputElement>;
  placeholder?: string;
  className?: string; // optional extra classes
}

export default function SearchBar({
  value,
  onChange,
  placeholder = "Search Here...",
  className = "",
  ...divProps
}: SearchBarProps) {
  const [isFocused, setIsFocused] = useState(false);

  // useCallback prevents unnecessary re-renders
  const handleFocus = useCallback(() => setIsFocused(true), []);
  const handleBlur = useCallback(() => setIsFocused(false), []);

  return (
    <div
      className={`relative w-full max-w-[1268px] h-[50px] rounded-full flex items-center px-5 transition-all
        ${isFocused ? "border-2 border-blue-500 bg-white shadow-md" : "border border-gray-200 bg-white"} 
        ${className}`}
      {...divProps}
    >
      {/* Search Icon */}
      <div className="flex items-center justify-center mr-3">
        <img
          src="/iconsearch.png"
          alt="Search icon"
          className="w-4 h-4 opacity-50 pointer-events-none"
          draggable={false}
        />
      </div>

      {/* Input */}
    {/* Input Field */}
      <input
        type="text"
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        aria-label={placeholder}
        className="flex-1 bg-transparent text-sm placeholder-gray-400 text-gray-700 outline-none min-w-0 sm:text-base"
        onFocus={handleFocus}
        onBlur={handleBlur}
      />
    </div>
  );
}
