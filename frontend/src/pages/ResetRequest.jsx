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
  <div className="h-screen w-screen bg-white flex flex-col overflow-hidden">
      {/* Top logo */}
      <div className="pt-4 px-4 sm:px-6 lg:px-10">
        <img
          src="/src/assets/toplogo.png"
          alt="Top Logo"
          className="h-8 sm:h-10 md:h-12 lg:h-14 object-contain"
        />
      </div>

      {/* Center content */}
      <div className="flex flex-1 items-center justify-center px-4 sm:px-6">
        <div className="w-full max-w-md text-center -translate-y-6 sm:-translate-y-10">
          {/* Illustration */}
          <img
            src="/src/assets/resetlogo.png"
            alt="Reset Illustration"
  className="mx-auto mb-4 h-24 sm:h-28 object-contain -mt-4 sm:-mt-16"
          />

          {/* Heading */}
          <h1 className="text-2xl sm:text-3xl font-bold text-[#242424] mb-2">
            Forget your Password?
          </h1>
          <p className="text-gray-500 mb-6 text-sm sm:text-base">
            Provide your account’s email for which you want to reset password!
          </p>

          {/* Error message */}
          {error && (
            <div className="bg-red-100 text-red-600 p-3 mb-4 rounded text-sm text-left">
              {error}
            </div>
          )}

          {/* Success message */}
          {message && (
            <div className="bg-green-100 text-green-600 p-3 mb-4 rounded text-sm text-left">
              {message}
            </div>
          )}

          {/* Reset Form */}
          <form onSubmit={handleReset} className="text-left">
            <div className="mb-10">
  <label className="block text-sm font-medium text-[#242424] mb-1">
                Email
              </label>
              <input
                type="email"
                placeholder="johndoe@gmail.com"
    className="w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>

            {/* Send button */}
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-500 text-white py-2 sm:py-3 text-sm sm:text-base rounded-full hover:bg-blue-600 transition"
            >
              {loading ? "Sending..." : "Send"}
            </button>
          </form>

          {/* Register + Back to Login */}
          <p className="text-center text-xs sm:text-sm text-gray-600 mt-10">
            Don’t have an account?{" "}
            <Link to="/signup" className="text-blue-500 hover:underline">
              Register
            </Link>
          </p>
          <div className="mt-4">
            <Link
              to="/login"
              className="text-xs sm:text-sm text-gray-600 hover:underline flex items-center justify-center gap-1"
            >
{/* Back to Login (arrow clickable only, text is static) */}
<div className="mt-6 flex items-center justify-center space-x-2">
  {/* Clickable arrow */}
  <Link to="/login">
    <img
      src="/src/assets/arrow.png"   // your arrow icon
      alt="Back"
      className="h-5 w-5 cursor-pointer hover:opacity-80"
    />
  </Link>

  {/* Static text */}
  <span className="text-sm text-gray-600">Back to Login</span>
</div>



            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}