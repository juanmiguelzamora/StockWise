import React, { useEffect, useState } from "react";
import api from "../services/api"; // axios instance with JWT
import Navbar from "../layout/navbar";
import RolePopup from "../components/ui/rolepopup";
import DeleteUserPopup from "../components/ui/deletepopup";
import SearchBar from "../components/ui/searchbar";
import UsersTable from "../components/users/UsersTable";
import RoleFilter from "../components/users/RoleFilter";

// 🔹 Define User type
interface User {
  id: number;
  email: string;
  is_superuser: boolean;
  is_staff: boolean;
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
      const res = await api.get("user/"); // keep generic off here to avoid union confusion
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
      await api.delete(`user/${id}/`);
      fetchUsers();
    } catch (err: any) {
      console.error("Delete user error:", err.response?.data || err.message);
      alert(err.response?.data?.detail || "Failed to delete user");
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
    try {
      await api.patch(`user/${id}/`, updatedUser);
      fetchUsers();
      setEditingUser(null);
    } catch (err: any) {
      console.error("Edit user error:", err.response?.data || err.message);
      alert(err.response?.data?.detail || "Failed to edit user");
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
                placeholder="Search Here..."
              />
            </div>
            <RoleFilter selected={selected} onChange={(val) => setSelected(val)} />
          </div>

          <UsersTable users={filteredUsers} currentUser={currentUser} onEdit={startEdit} onDelete={requestDeleteUser} />
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