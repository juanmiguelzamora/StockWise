export default function DeleteUserPopup({ onConfirm, onCancel }) {
  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black/50 z-50">
      <div className="relative w-[400px] h-[277px] bg-white rounded-[33px] shadow-lg">
        {/* Title */}
        <h2 className="absolute left-[124px] top-[73px] text-[20px] leading-[24px] font-semibold text-black">
          Delete this User
        </h2>

        {/* Delete Button */}
        <button
          onClick={onConfirm}
          className="absolute left-[211px] top-[154px] w-[130px] h-[50px] bg-[#FFA8A7] rounded-full flex items-center justify-center"
        >
          <span className="text-[15px] font-medium text-[#FF2F3E]">Delete</span>
        </button>

        {/* Cancel Button */}
        <button
          onClick={onCancel}
          className="absolute left-[59px] top-[154px] w-[130px] h-[50px] border border-[rgba(36,36,36,0.5)] rounded-full flex items-center justify-center"
        >
          <span className="text-[15px] font-medium text-[#242424]">Cancel</span>
        </button>
      </div>
    </div>
  );
}
