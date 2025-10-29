export interface UserRowData {
  id: number;
  email: string;
  is_superuser: boolean;
  is_staff: boolean;
}

type Props = {
  users: UserRowData[];
  currentUser: UserRowData | null;
  onEdit: (user: UserRowData) => void;
  onDelete: (user: UserRowData) => void;
};

export default function UsersTable({ users, currentUser, onEdit, onDelete }: Props) {
  return (
    <div className="bg-white rounded-xl shadow-md overflow-hidden">
      <table className="w-full text-left table-fixed">
        <thead>
          <tr className="bg-[#5283FF] text-white">
            <th className="px-6 py-3 ">Email</th>
            <th className="px-6 py-3 text-center ">User Role</th>
            <th className="px-6 py-3 text-center">Action</th>
          </tr>
        </thead>
        <tbody>
          {users.map((u, idx) => (
            <tr key={u.id} className={`${idx % 2 === 0 ? "bg-white" : "bg-[#F9FBFF]"} hover:bg-gray-100 transition`}>
              <td className="px-6 py-3 text-gray-800 truncate">{u.email}</td>
              <td className="px-6 py-3 text-center">
                {u.is_superuser ? (
                  <span className="font-semibold text-gray-900">Admin</span>
                ) : u.is_staff ? (
                  <span className="text-gray-800">Staff</span>
                ) : (
                  <span className="text-gray-500">User</span>
                )}
              </td>
              <td className="px-6 py-3 flex gap-4 items-center justify-center">
                <button
                  onClick={() => onEdit(u)}
                  disabled={!currentUser?.is_superuser}
                  className={`w-5 h-5 ${!currentUser?.is_superuser ? "opacity-30 cursor-not-allowed" : "hover:opacity-80"}`}
                  title="Edit Role"
                >
                  <img src="/iconedit.png" alt="Edit" className="w-full h-full object-contain" draggable={false} />
                </button>
                <button
                  onClick={() => onDelete(u)}
                  disabled={!currentUser?.is_superuser}
                  className={`w-5 h-5 ${!currentUser?.is_superuser ? "opacity-30 cursor-not-allowed" : "hover:opacity-80"}`}
                  title="Delete User"
                >
                  <img src="/icondelete.png" alt="Delete" className="w-full h-full object-contain" draggable={false} />
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
