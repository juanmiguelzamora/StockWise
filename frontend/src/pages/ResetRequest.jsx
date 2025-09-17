import { useState } from "react";
import { Link } from "react-router-dom";
import api from "../services/api";

export default function ResetRequest() {
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleReset = async (e) => {
    e.preventDefault();
    if (!email) return setError("Please enter your email");

    setLoading(true);
    setError("");
    setMessage("");

    try {
      const res = await api.post("users/password-reset/", { email });

      setMessage("✅ Check your email for a reset link.");
    } catch (err) {
      if (err.response) {
        // Server responded but with an error
        setError(err.response.data.detail || "No user found with this email.");
      } else {
        // Network or other issue
        setError("⚠️ Server error. Please try again later.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleReset}>
      <h2>Request Password Reset</h2>
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        required
      />
      <button disabled={loading}>
        {loading ? "Sending..." : "Send reset email"}
      </button>
      {error && <p style={{ color: "red" }}>{error}</p>}
      {message && <p style={{ color: "green" }}>{message}</p>}
      <Link to="/login">Back to login</Link>
    </form>
  );
}
