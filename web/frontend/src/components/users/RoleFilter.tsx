type Option = "All User" | "All Admin" | "All Staff";

type Props = {
  selected: Option;
  onChange: (value: Option) => void;
};

export default function RoleFilter({ selected, onChange }: Props) {
  const options: Option[] = ["All User", "All Admin", "All Staff"];
  return (
    <div className="relative flex-shrink-0 min-w-[110px] text-right">
      <details className="inline-block">
        <summary className="list-none flex items-center gap-1 text-gray-700 cursor-pointer whitespace-nowrap bg-transparent border-none outline-none">
          <span className="text-sm">{selected}</span>
          <span className="text-xs">▼</span>
        </summary>
        <div className="absolute right-6 mt-2 bg-white border rounded-md shadow-md w-32 z-50">
          {options.map((option) => (
            <div
              key={option}
              onClick={() => onChange(option)}
              className="px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 cursor-pointer text-center"
            >
              {option}
            </div>
          ))}
        </div>
      </details>
    </div>
  );
}
