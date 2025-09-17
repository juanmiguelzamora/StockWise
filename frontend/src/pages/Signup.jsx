import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import api from "../services/api"; // ✅ reuse axios instance

export default function Signup() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const navigate = useNavigate();

  const handleSignup = async (e) => {
    e.preventDefault();

    // 🔹 Frontend validation
    if (!email || !password || !confirmPassword) {
      setErrors({ non_field_errors: ["⚠️ Please fill in all fields"] });
      return;
    }
    if (password !== confirmPassword) {
      setErrors({ password: ["⚠️ Passwords do not match"] });
      return;
    }

    setLoading(true);
    setErrors({});

    try {
      // ✅ use axios instance instead of fetch
      const res = await api.post("users/signup/", {
        email,
        password,
        re_password: confirmPassword,
      });

      const data = res.data;

      // ✅ Save JWT if returned
      if (data.access && data.refresh) {
        sessionStorage.setItem("access", data.access);
        sessionStorage.setItem("refresh", data.refresh);
      }

      // Redirect after successful signup
      navigate("/login");
    } catch (err) {
      if (err.response?.data) {
        setErrors(err.response.data);
      } else {
        setErrors({ non_field_errors: ["Network error: " + err.message] });
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex">
      {/* Left side illustration */}
      <div className="hidden md:flex w-1/2 bg-gradient-to-br from-white-500 to-white-600 flex-col items-center justify-center relative">
        <img src="/toplogo.png" alt="Top Logo" className="absolute top-10 left-10 h-14 w-auto" />
        <img src="/loginlogo.png" alt="Signup Illustration" className="max-w-md" />
      </div>

      {/* Signup form */}
      <div className="flex w-full md:w-1/2 items-center justify-center p-8">
        <div className="max-w-md w-full">
          <h1 className="text-5xl font-bold mb-2">Create an account</h1>
          <p className="text-gray-500 mb-6">Please enter your details to sign up</p>

          {errors.non_field_errors && (
            <div className="bg-red-100 text-red-600 p-3 mb-4 rounded">
              {errors.non_field_errors.map((err, idx) => (
                <p key={idx}>{err}</p>
              ))}
            </div>
          )}

          <form onSubmit={handleSignup} className="space-y-4">
            <div>
              <label className="block text-sm font-medium">Email</label>
              <input
                type="email"
                className="w-full border rounded-lg px-3 py-2 mt-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
              {errors.email && <p className="text-red-500 text-sm">{errors.email[0]}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium">Password</label>
              <input
                type="password"
                className="w-full border rounded-lg px-3 py-2 mt-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
              {errors.password && <p className="text-red-500 text-sm">{errors.password[0]}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium">Confirm Password</label>
              <input
                type="password"
                className="w-full border rounded-lg px-3 py-2 mt-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
              />
              {errors.re_password && <p className="text-red-500 text-sm">{errors.re_password[0]}</p>}
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-500 text-white py-2 rounded-full hover:bg-blue-700 transition"
            >
              {loading ? "Creating account..." : "Sign up"}
            </button>
          </form>

          <p className="text-center text-sm text-gray-600 mt-6">
            Already have an account?{" "}
            <Link to="/login" className="text-blue-500 hover:underline">
              Login
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
