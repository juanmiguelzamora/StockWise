import { useSearchParams, Link } from "react-router-dom";
import { useState } from "react";

export default function ResetPassword() {
  const [searchParams] = useSearchParams();
  const uid = searchParams.get("uid");
  const token = searchParams.get("token");

  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (password !== confirmPassword) {
      setError("Passwords do not match!");
      return;
    }

    setLoading(true);
    setError("");
    setMessage("");

    try {
  const res = await fetch(
  "http://192.168.0.100:8000/api/v1/auth/password-reset-confirm/",
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            uid,
            token,
            password, // ✅ correct key for your backend
          }),
        }
      );

      const data = await res.json();

      if (res.ok && data.success) {
        setMessage("Password reset successful! You can now log in.");
      } else {
        setError(data.message || "Something went wrong.");
      }
    } catch (e) {
      setError("Server error, please try again later.");
    } finally {
      setLoading(false);
    }
  };

  if (!uid || !token) {
    return <p>Invalid or expired reset link.</p>;
  }

  return (
    <div style={{ maxWidth: "400px", margin: "50px auto" }}>
      <h2>Reset Password</h2>
      <form onSubmit={handleSubmit}>
        <input
          type="password"
          placeholder="New Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
        <br />
        <input
          type="password"
          placeholder="Confirm Password"
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
          required
        />
        <br />
        <button type="submit" disabled={loading}>
          {loading ? "Resetting..." : "Reset Password"}
        </button>
      </form>
      {error && <p style={{ color: "red" }}>{error}</p>}
      {message && (
        <p style={{ color: "green" }}>
          {message} <Link to="/login">Login</Link>
        </p>
      )}
    </div>
  );
}
