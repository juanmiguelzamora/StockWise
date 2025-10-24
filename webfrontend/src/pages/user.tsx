import React, { useEffect, useState } from "react";
import api from "../services/api"; // axios instance with JWT
import Navbar from "../layout/navbar";
import RolePopup from "../components/ui/rolepopup";
import DeleteUserPopup from "../components/ui/deletepopup";
import SearchBar from "../components/ui/searchbar";

// 🔹 Define User type (updated to match backend model: added first_name, last_name; assuming backend serializer includes is_superuser/is_staff for role checks)
interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  is_superuser: boolean;
  is_staff: boolean;
  is_active: boolean;
}

// 🔹 API response for paginated users
interface PaginatedResponse<T> {
  results?: T[];
  [key: string]: any; // allow extra fields
}

const UsersPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [filteredUsers, setFilteredUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string>("");
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [editRole, setEditRole] = useState<string>("");
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [userToDelete, setUserToDelete] = useState<User | null>(null);
  const [searchTerm, setSearchTerm] = useState<string>("");

  const [open, setOpen] = useState<boolean>(false);
  const [selected, setSelected] = useState<"All User" | "All Admin" | "All Staff">("All User");

  useEffect(() => {
    fetchUsers();
    fetchCurrentUser();
  }, []);

  // ✅ Multi-tab auth sync
  useEffect(() => {
    const handleAuthChange = (event: StorageEvent) => {
      if (event.key === "authChanged") {
        fetchCurrentUser(); // reload currentUser when login/logout in another tab
      }
    };

    window.addEventListener("storage", handleAuthChange);
    return () => window.removeEventListener("storage", handleAuthChange);
  }, []);

  // ✅ Filtering logic with both search + dropdown
  useEffect(() => {
    let data = users;

    // Search filter (now searches across name and email for better UX)
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      data = data.filter(
        (user) =>
          user.email.toLowerCase().includes(term) ||
          `${user.first_name} ${user.last_name}`.toLowerCase().includes(term)
      );
    }

    // Dropdown filter
    if (selected === "All Admin") {
      data = data.filter((user) => user.is_superuser);
    } else if (selected === "All Staff") {
      data = data.filter((user) => user.is_staff && !user.is_superuser);
    }

    setFilteredUsers(data);
  }, [searchTerm, users, selected]);

  const fetchUsers = async () => {
    setLoading(true);
    setError("");
    try {
      // Assuming backend has a list endpoint at "users/" (e.g., a ListAPIView); adjust if different
      const res = await api.get("users/");
      const payload: unknown = res.data;

      const isPaginated = (v: any): v is PaginatedResponse<User> =>
        v && typeof v === "object" && "results" in v;

      let data: User[] = [];

      if (Array.isArray(payload)) {
        data = payload as User[];
      } else if (isPaginated(payload)) {
        data = payload.results ?? [];
      } else {
        data = [payload as User];
      }

      setUsers(data);
    } catch (err: any) {
      console.error("Fetch error:", err.response?.status, err.response?.data);
      if (err.response?.status === 401) setError("Unauthorized: Please log in again.");
      else if (err.response?.status === 403) setError("Forbidden: Only admin can view users.");
      else setError("Failed to fetch users");
    } finally {
      setLoading(false);
    }
  };

  const fetchCurrentUser = async () => {
    try {
      const res = await api.get<User>("user/");
      setCurrentUser(res.data);
    } catch (err) {
      console.error("Fetch current user error:", err);
    }
  };

  const deleteUser = async (id: number) => {
    if (!currentUser) return;

    if (!currentUser.is_superuser) {
      alert("⚠️ Only admin can delete users");
      return;
    }

    if (id === currentUser.id) {
      alert("⚠️ You cannot delete your own account while logged in.");
      return;
    }

    try {
      await api.delete(`users/${id}/`);  // Consistent with detail endpoint
      fetchUsers();  // Refresh list
    } catch (err: any) {
      console.error("Delete user error:", err.response?.status, err.response?.data || err.message);
      if (err.response?.status === 403) {
        alert("Forbidden: Only admin can delete users.");
      } else if (err.response?.status === 404) {
        alert("User not found.");
      } else {
        alert(err.response?.data?.detail || "Failed to delete user");
      }
    }
  };

  const requestDeleteUser = (user: User) => {
    setUserToDelete(user);
  };

  const confirmDeleteUser = async () => {
    if (!userToDelete) return;
    await deleteUser(userToDelete.id);
    setUserToDelete(null);
  };

  const editUser = async (id: number, updatedUser: Partial<User>) => {
    if (!editingUser) return;

    try {
      await api.patch(`users/${editingUser.id}/`, updatedUser);  // Use editingUser.id for consistency; endpoint matches detail
      fetchUsers();  // Refresh list
      setEditingUser(null);
    } catch (err: any) {
      console.error("Edit user error:", err.response?.status, err.response?.data || err.message);
      if (err.response?.status === 403) {
        alert("Forbidden: Only admin can edit users.");
      } else if (err.response?.status === 404) {
        alert("User not found.");
      } else {
        alert(err.response?.data?.detail || "Failed to edit user");
      }
    }
  };

  const startEdit = (user: User) => {
    if (!currentUser?.is_superuser) {
      alert("⚠️ Only admin can edit roles");
      return;
    }
    if (user.id === currentUser.id) {
      alert("⚠️ You cannot edit your own account while logged in.");
      return;
    }
    setEditingUser(user);
    if (user.is_superuser) setEditRole("admin");
    else if (user.is_staff) setEditRole("staff");
    else setEditRole("");
  };

  const saveEdit = () => {
    if (!editingUser) return;

    let updatedUser: Partial<User> = {};
    if (editRole === "admin") updatedUser = { is_superuser: true, is_staff: true };
    else if (editRole === "staff") updatedUser = { is_superuser: false, is_staff: true };
    else updatedUser = { is_superuser: false, is_staff: false };

    editUser(editingUser.id, updatedUser);
  };

  if (loading) return <p className="p-6">Loading users...</p>;
  if (error) return <p className="p-6 text-red-500">{error}</p>;

  return (
    <div>
      <Navbar />
      <div className="bg-[#F2F7FA] min-h-screen p-8 pt-24">
        <div className="max-w-6xl mx-auto">
          {/* Top Bar with Search + Dropdown */}
          <div className="flex items-center mb-6">
            <div className="flex-1 mr-6">
              <SearchBar
                value={searchTerm}
                onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSearchTerm(e.target.value)}
                placeholder="Search by name or email..."
              />
            </div>
            <div className=" relative flex-shrink-0 min-w-[110px] text-right">
              {/* Button */}
              <button
                onClick={() => setOpen(!open)}
                className="flex items-center gap-1 text-gray-700 cursor-pointer whitespace-nowrap bg-transparent border-none outline-none"
              >
                <span className="text-sm">{selected}</span>
                <span className="text-xs">▼</span>
              </button>

              {/* Dropdown */}
              {open && (
                <div className="absolute right-6 mt-2 bg-white border rounded-md shadow-md w-32 z-50">
                  {["All User", "All Admin", "All Staff"].map((option) => (
                    <div
                      key={option}
                      onClick={() => {
                        setSelected(option as typeof selected);
                        setOpen(false);
                      }}
                      className="px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 cursor-pointer text-center"
                    >
                      {option}
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Table (updated: added Name column; adjusted widths for table-fixed) */}
          <div className="bg-white rounded-xl shadow-md overflow-hidden">
            <table className="w-full text-left table-fixed">
              <thead>
                <tr className="bg-[#5283FF] text-white">
                  <th className="w-1/3 px-6 py-3">Name</th>
                  <th className="w-1/3 px-6 py-3">Email</th>
                  <th className="w-1/6 px-6 py-3 text-center">User Role</th>
                  <th className="w-1/6 px-6 py-3 text-center">Action</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((u, idx) => (
                  <tr
                    key={u.id}
                    className={`${idx % 2 === 0 ? "bg-white" : "bg-[#F9FBFF]"} hover:bg-gray-100 transition`}
                  >
                    <td className="px-6 py-3 text-gray-800">
                      {u.first_name} {u.last_name}
                    </td>
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
                        onClick={() => startEdit(u)}
                        disabled={!currentUser?.is_superuser}
                        className={`w-5 h-5 ${
                          !currentUser?.is_superuser ? "opacity-30 cursor-not-allowed" : "hover:opacity-80"
                        }`}
                        title="Edit Role"
                      >
                        <img
                          src="/iconedit.png"
                          alt="Edit"
                          className="w-full h-full object-contain"
                          draggable={false}
                        />
                      </button>
                      <button
                        onClick={() => requestDeleteUser(u)}
                        disabled={!currentUser?.is_superuser}
                        className={`w-5 h-5 ${
                          !currentUser?.is_superuser ? "opacity-30 cursor-not-allowed" : "hover:opacity-80"
                        }`}
                        title="Delete User"
                      >
                        <img
                          src="/icondelete.png"
                          alt="Delete"
                          className="w-full h-full object-contain"
                          draggable={false}
                        />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Popup for editing */}
      {editingUser && (
        <RolePopup role={editRole} setRole={setEditRole} onSave={saveEdit} onCancel={() => setEditingUser(null)} />
      )}

      {/* Popup for deleting */}
      {userToDelete && (
        <DeleteUserPopup onConfirm={confirmDeleteUser} onCancel={() => setUserToDelete(null)} />
      )}
    </div>
  );
};

export default UsersPage;