// components/ui/RolePopup.tsx
import React from "react";

interface RolePopupProps {
  role: string;
  setRole: (role: string) => void;
  onSave: () => void;
  onCancel: () => void;
}

export default function RolePopup({
  role,
  setRole,
  onSave,
  onCancel,
}: RolePopupProps) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="relative w-[400px] h-[300px] bg-white rounded-[33px] p-6">
        {/* Title */}
        <h2 className="text-[20px] text-center font-semibold text-black mb-6">
          Select User Role
        </h2>

        {/* Role Buttons */}
        <div className="flex justify-center gap-6 mb-6">
          <button
            onClick={() => setRole("admin")}
            className={`w-[130px] h-[50px] border rounded-[10px] ${
              role === "admin" ? "bg-red-100 border-red-500" : "border-gray-400"
            }`}
          >
            Admin
          </button>
          <button
            onClick={() => setRole("staff")}
            className={`w-[130px] h-[50px] border rounded-[10px] ${
              role === "staff" ? "bg-blue-100 border-blue-500" : "border-gray-400"
            }`}
          >
            Staff
          </button>
        </div>

        {/* Save / Cancel */}
        <div className="flex justify-center gap-6">
          <button
            onClick={onCancel}
            className="w-[130px] h-[50px] bg-[#FFA8A7] rounded-full text-[#FF2F3E] font-semibold"
          >
            Cancel
          </button>
          <button
            onClick={onSave}
            className="w-[130px] h-[50px] bg-[#99FFA3] rounded-full text-[#1AAA23] font-semibold"
          >
            Save
          </button>
        </div>
      </div>
    </div>
  );
}
