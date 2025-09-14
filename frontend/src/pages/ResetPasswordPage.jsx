import { useParams, Link, useNavigate } from "react-router-dom";
import { useState } from "react";

export default function ResetPasswordPage() {
  const { uid, token } = useParams(); // ✅ get from URL params
  const navigate = useNavigate();

  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();

    setError("");
    setMessage("");

    if (!password || !confirmPassword) {
      setError("Please fill in all fields.");
      return;
    }

    if (password !== confirmPassword) {
      setError("Passwords do not match!");
      return;
    }

    if (!uid || !token) {
      setError("Invalid or expired reset link.");
      return;
    }

    setLoading(true);

    try {
    const response = await fetch("http://192.168.0.101:8000/api/v1/users/password-reset-confirm/", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    uid,
    token,
    password,
  }),
});

      const data = await response.json();

      if (response.ok && data.success) {
        setMessage("Password reset successfully! Redirecting to login...");
        setTimeout(() => navigate("/login"), 2000);
      } else {
        setError(data.message || "Failed to reset password.");
      }
    } catch (err) {
      setError("Server error, please try again later.");
    } finally {
      setLoading(false);
    }
  };

  if (!uid || !token) {
    return (
      <div style={{ maxWidth: "400px", margin: "50px auto" }}>
        <p>Invalid or expired reset link.</p>
        <Link to="/reset-request">Request a new link</Link>
      </div>
    );
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
