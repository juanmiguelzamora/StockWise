import { useEffect, useState } from "react";
import api from "../services/api"; // axios instance with JWT
import Navbar from "../layout/navbar";
import RolePopup from "../components/ui/rolepopup";
import DeleteUserPopup from "../components/ui/deletepopup";
import SearchBar from "../components/ui/searchbar";

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [filteredUsers, setFilteredUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [editingUser, setEditingUser] = useState(null);
  const [editRole, setEditRole] = useState("");
  const [currentUser, setCurrentUser] = useState(null);
  const [userToDelete, setUserToDelete] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");

  const [open, setOpen] = useState(false);
  const [selected, setSelected] = useState("All User");

  useEffect(() => {
    fetchUsers();
    fetchCurrentUser();
  }, []);

  // ✅ Multi-tab auth sync
useEffect(() => {
  const handleAuthChange = (event) => {
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

    // Search filter
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      data = data.filter((user) => user.email.toLowerCase().includes(term));
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
      const res = await api.get("users/user-management/");
      setUsers(res.data.results || res.data);
    } catch (err) {
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
      const res = await api.get("users/me/");
      setCurrentUser(res.data);
    } catch (err) {
      console.error("Fetch current user error:", err);
    }
  };

  const deleteUser = async (id) => {
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
      await api.delete(`users/user-management/${id}/`);
      fetchUsers();
    } catch (err) {
      console.error("Delete user error:", err.response?.data || err.message);
      alert(err.response?.data?.detail || "Failed to delete user");
    }
  };

  const requestDeleteUser = (user) => {
    setUserToDelete(user);
  };

  const confirmDeleteUser = async () => {
    if (!userToDelete) return;
    await deleteUser(userToDelete.id);
    setUserToDelete(null);
  };

  const editUser = async (id, updatedUser) => {
    try {
      await api.patch(`users/user-management/${id}/`, updatedUser);
      fetchUsers();
      setEditingUser(null);
    } catch (err) {
      console.error("Edit user error:", err.response?.data || err.message);
      alert(err.response?.data?.detail || "Failed to edit user");
    }
  };

  const startEdit = (user) => {
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

    let updatedUser = {};
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
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search Here..."
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
                <div className="absolute right-0 mt-2 bg-white border rounded-md shadow-md w-32 z-50">
                  <div
                    onClick={() => {
                      setSelected("All User");
                      setOpen(false);
                    }}
                    className="px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 cursor-pointer"
                  >
                    All User
                  </div>
                  <div
                    onClick={() => {
                      setSelected("All Admin");
                      setOpen(false);
                    }}
                    className="px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 cursor-pointer"
                  >
                    All Admin
                  </div>
                  <div
                    onClick={() => {
                      setSelected("All Staff");
                      setOpen(false);
                    }}
                    className="px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 cursor-pointer"
                  >
                    All Staff
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Table */}
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
                {filteredUsers.map((u, idx) => (
                  <tr
                    key={u.id}
                    className={`${
                      idx % 2 === 0 ? "bg-white" : "bg-[#F9FBFF]"
                    } hover:bg-gray-100 transition`}
                  >
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
                          !currentUser?.is_superuser
                            ? "opacity-30 cursor-not-allowed"
                            : "hover:opacity-80"
                        }`}
                        title="Edit Role"
                      >
                        <img
                          src="/src/assets/iconedit.png"
                          alt="Edit"
                          className="w-full h-full object-contain"
                          draggable={false}
                        />
                      </button>
                      <button
                        onClick={() => requestDeleteUser(u)}
                        disabled={!currentUser?.is_superuser}
                        className={`w-5 h-5 ${
                          !currentUser?.is_superuser
                            ? "opacity-30 cursor-not-allowed"
                            : "hover:opacity-80"
                        }`}
                        title="Delete User"
                      >
                        <img
                          src="/src/assets/icondelete.png"
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
        <RolePopup
          role={editRole}
          setRole={setEditRole}
          onSave={saveEdit}
          onCancel={() => setEditingUser(null)}
        />
      )}

      {/* Popup for deleting */}
      {userToDelete && (
        <DeleteUserPopup
          onConfirm={confirmDeleteUser}
          onCancel={() => setUserToDelete(null)}
        />
      )}
    </div>
  );
}
