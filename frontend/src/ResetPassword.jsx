import { useSearchParams, Link, useNavigate } from "react-router-dom";
import { useState } from "react";

export default function ResetPassword() {
  const [searchParams] = useSearchParams();
  const uid = searchParams.get("uid");
  const token = searchParams.get("token");

  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [loading, setLoading] = useState(false);

  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Client-side validation
    if (!password || !confirmPassword) {
      setError("Please fill in all fields.");
      return;
    }
    if (password !== confirmPassword) {
      setError("Passwords do not match!");
      return;
    }

    setLoading(true);
    setError("");
    setSuccess("");

    try {
      const res = await fetch(
        "http://192.168.0.102:8000/api/v1/users/password-reset-confirm/",
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
  uid,
  token,
  new_password: password,
  confirm_password: confirmPassword
})

        }
      );

      let data;
      try {
        data = await res.json();
      } catch {
        throw new Error("Invalid server response.");
      }

      if (res.ok) {
        setSuccess("Password reset successfully! Redirecting to login...");
        setTimeout(() => navigate("/login", { replace: true }), 2000);
      } else {
        if (data.errors) {
          // Combine all field errors into one string
          const allErrors = Object.values(data.errors)
            .flat()
            .join(" ");
          setError(allErrors || "Something went wrong.");
        } else if (data.message) {
          setError(data.message);
        } else {
          setError("Something went wrong.");
        }
      }
    } catch (e) {
      setError("Server error, please try again later.");
      console.error(e);
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
      {success && <p style={{ color: "green" }}>{success}</p>}
    </div>
  );
}