// src/pages/ResetPassword.tsx
import { useSearchParams, Link, useNavigate } from "react-router-dom";
import { useState } from "react";
import api from "../services/api";

export default function ResetPassword() {
  const [searchParams] = useSearchParams();
  const uid: string | null = searchParams.get("uid");
  const token: string | null = searchParams.get("token");

  const [password, setPassword] = useState<string>("");
  const [confirmPassword, setConfirmPassword] = useState<string>("");
  const [error, setError] = useState<string>("");
  const [success, setSuccess] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(false);

  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    // ✅ Client-side validation
    if (!password || !confirmPassword) {
      return setError("⚠️ Please fill in all fields.");
    }
    if (password !== confirmPassword) {
      return setError("⚠️ Passwords do not match!");
    }

    setLoading(true);
    setError("");
    setSuccess("");

    try {
      await api.post("users/password-reset-confirm/", {
        uid,
        token,
        new_password: password,
        confirm_password: confirmPassword,
      });

      setSuccess("✅ Password reset successfully! Redirecting to login...");
      setTimeout(() => navigate("/login", { replace: true }), 2000);
    } catch (err: any) {
      if (err.response?.data) {
        const data = err.response.data as {
          errors?: Record<string, string[]>;
          message?: string;
        };
        if (data.errors) {
          const allErrors = Object.values(data.errors).flat().join(" ");
          setError(allErrors || "Something went wrong.");
        } else if (data.message) {
          setError(data.message);
        } else {
          setError("⚠️ Failed to reset password.");
        }
      } else {
        setError("Server error, please try again later.");
      }
    } finally {
      setLoading(false);
    }
  };

  if (!uid || !token) {
    return (
      <p className="text-center text-red-600 font-semibold mt-10">
        ⚠️ Invalid or expired reset link.
      </p>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
      <div className="bg-white p-6 rounded-2xl shadow-md w-full max-w-md">
        <h2 className="text-2xl font-bold mb-4 text-center">Reset Password</h2>

        {error && (
          <div className="bg-red-100 text-red-600 p-3 mb-4 rounded">{error}</div>
        )}
        {success && (
          <div className="bg-green-100 text-green-600 p-3 mb-4 rounded">
            {success}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <input
              type="password"
              placeholder="New Password"
              className="w-full border rounded-lg px-3 py-2 mt-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          <div>
            <input
              type="password"
              placeholder="Confirm Password"
              className="w-full border rounded-lg px-3 py-2 mt-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-blue-500 text-white py-2 rounded-full hover:bg-blue-700 transition"
          >
            {loading ? "Resetting..." : "Reset Password"}
          </button>
        </form>

        <p className="text-center text-sm text-gray-600 mt-6">
          <Link to="/login" className="text-blue-500 hover:underline">
            Back to Login
          </Link>
        </p>
      </div>
    </div>
  );
}
