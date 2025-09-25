import { useState, useEffect } from "react";
import { useSearchParams, useNavigate } from "react-router-dom";
import api from "../services/api";

export default function ResetConfirm() {
  const [searchParams] = useSearchParams();
  const uid = searchParams.get("uid");
  const token = searchParams.get("token");

  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const navigate = useNavigate();

  const handleConfirm = async () => {
    if (!password || !confirmPassword) {
      setError("⚠️ Please fill in all fields.");
      return;
    }
    if (password !== confirmPassword) {
      setError("⚠️ Passwords do not match.");
      return;
    }

    setLoading(true);
    setError("");
    setMessage("");

    try {
      await api.post("users/password-reset-confirm/", {
        uid,
        token,
        new_password: password,
        confirm_password: confirmPassword,
      });
      setMessage("✅ Password has been reset! Redirecting to login...");
      setTimeout(() => navigate("/login", { replace: true }), 2000);
    } catch (err) {
      console.error(err);
      if (err.response?.data?.detail) setError(err.response.data.detail);
      else setError("⚠️ Failed to reset password.");
    } finally {
      setLoading(false);
    }
  };

  if (!uid || !token) {
    return <p className="text-red-600 text-center mt-10">⚠️ Invalid or expired reset link.</p>;
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
      <div className="bg-white p-6 rounded-2xl shadow-md w-full max-w-md">
        <h2 className="text-2xl font-bold mb-4 text-center">Reset Password</h2>

        {error && <div className="bg-red-100 text-red-600 p-3 mb-4 rounded">{error}</div>}
        {message && <div className="bg-green-100 text-green-600 p-3 mb-4 rounded">{message}</div>}

        <input
          type="password"
          placeholder="New Password"
          className="w-full border rounded-lg px-3 py-2 mb-4 focus:outline-none focus:ring-2 focus:ring-blue-500"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <input
          type="password"
          placeholder="Confirm Password"
          className="w-full border rounded-lg px-3 py-2 mb-4 focus:outline-none focus:ring-2 focus:ring-blue-500"
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
        />

        <button
          onClick={handleConfirm}
          disabled={loading}
          className="w-full bg-blue-500 text-white py-2 rounded-full hover:bg-blue-700 transition"
        >
          {loading ? "Resetting..." : "Reset Password"}
        </button>
      </div>
    </div>
  );
}
