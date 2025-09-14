import { useEffect, useState } from "react";
import api from "../api"; // axios instance with JWT

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [editingUser, setEditingUser] = useState(null);
  const [editRole, setEditRole] = useState("");
  const [currentUser, setCurrentUser] = useState(null);

  useEffect(() => {
    fetchUsers();
    fetchCurrentUser();
  }, []);

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

  // Delete user
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

    if (!window.confirm("Are you sure you want to delete this user?")) return;

    try {
      await api.delete(`users/user-management/${id}/`);
      fetchUsers();
    } catch (err) {
      console.error("Delete user error:", err.response?.data || err.message);
      alert(err.response?.data?.detail || "Failed to delete user");
    }
  };

  // Edit user role
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
  else setEditRole("user");
};
  const saveEdit = () => {
  if (!editingUser) return;
  if (editingUser.id === currentUser.id) {
    alert("⚠️ You cannot edit your own account.");
    setEditingUser(null);
    return;
  }

  let updatedUser = {};
  if (editRole === "admin") updatedUser = { is_superuser: true, is_staff: true };
  else if (editRole === "staff") updatedUser = { is_superuser: false, is_staff: true };
  else updatedUser = { is_superuser: false, is_staff: false };

  editUser(editingUser.id, updatedUser);
};

  if (loading) return <p className="p-6">Loading users...</p>;
  if (error) return <p className="p-6 text-red-500">{error}</p>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Users</h1>
      <table className="w-full border text-left">
        <thead className="bg-gray-200">
          <tr>
            <th className="p-2">Email</th>
            <th className="p-2">Role</th>
            <th className="p-2">Action</th>
          </tr>
        </thead>
        <tbody>
          {users.map((u) => (
            <tr key={u.id} className="border-b">
              <td className="p-2">{u.email}</td>
              <td className="p-2">
                {editingUser?.id === u.id ? (
                  <select
                    value={editRole}
                    onChange={(e) => setEditRole(e.target.value)}
                    className="border p-1"
                  >
                    <option value="admin">Admin</option>
                    <option value="staff">Staff</option>
                  </select>
                ) : u.is_superuser ? (
                  <span className="text-red-600 font-semibold">Admin</span>
                ) : u.is_staff ? (
                  <span className="text-blue-600">Staff</span>
                ) : (
                  <span className="text-gray-600">User</span>
                )}
              </td>
              <td className="p-2 flex gap-2">
                {editingUser?.id === u.id ? (
                  <>
                    <button
                      onClick={saveEdit}
                      className="bg-green-500 text-white px-3 py-1 rounded"
                    >
                      Save
                    </button>
                    <button
                      onClick={() => setEditingUser(null)}
                      className="bg-gray-500 text-white px-3 py-1 rounded"
                    >
                      Cancel
                    </button>
                  </>
                ) : (
                  <>
                    <button
                      onClick={() => startEdit(u)}
                      disabled={!currentUser?.is_superuser}
                      className={`px-3 py-1 rounded ${
                        !currentUser?.is_superuser
                          ? "bg-gray-400 cursor-not-allowed"
                          : "bg-blue-500 text-white"
                      }`}
                    >
                      Edit Role
                    </button>
                    <button
                      onClick={() => deleteUser(u.id)}
                      disabled={!currentUser?.is_superuser}
                      className={`px-3 py-1 rounded ${
                        !currentUser?.is_superuser
                          ? "bg-gray-400 cursor-not-allowed"
                          : "bg-red-500 text-white"
                      }`}
                    >
                      Delete
                    </button>
                  </>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
