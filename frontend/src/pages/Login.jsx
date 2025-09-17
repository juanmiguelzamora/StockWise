import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import api from "../services/api"; // ✅ axios instance

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState([]);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();

    // 🔹 Frontend validation
    if (!email || !password) {
      setErrors(["⚠️ Please fill in all fields"]);
      return;
    }

    setLoading(true);
    setErrors([]);

    try {
      // Clear old tokens before new login
      sessionStorage.removeItem("access");
      sessionStorage.removeItem("refresh");

      const res = await api.post("users/login/", { email, password });
      const data = res.data;

      // ✅ Save JWT tokens (backend may return access/refresh OR access_token/refresh_token)
      if ((data.access || data.access_token) && (data.refresh || data.refresh_token)) {
        const access = data.access || data.access_token;
        const refresh = data.refresh || data.refresh_token;

        sessionStorage.setItem("access", access);
        sessionStorage.setItem("refresh", refresh);

        navigate("/dashboard");
      } else {
        setErrors(["⚠️ No tokens returned. Please check backend response."]);
      }
    } catch (err) {
      let errorList = [];

      // 🔹 Extract validation errors from backend
      if (err.response?.data) {
        const extractErrors = (obj) => {
          if (!obj) return;
          if (Array.isArray(obj)) obj.forEach(extractErrors);
          else if (typeof obj === "object") Object.values(obj).forEach(extractErrors);
          else errorList.push(obj);
        };
        extractErrors(err.response.data);
      }

      setErrors(errorList.length > 0 ? errorList : ["⚠️ Invalid email or password"]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex">
      {/* Left side illustration */}
      <div className="hidden md:flex w-1/2 bg-gradient-to-br from-white-500 to-white-600 flex-col items-center justify-center relative">
        <img src="/toplogo.png" alt="Top Logo" className="absolute top-10 left-10 h-14 w-auto" />
        <img src="/loginlogo.png" alt="Login Illustration" className="max-w-md" />
      </div>

      {/* Right side form */}
      <div className="flex w-full md:w-1/2 items-center justify-center p-8">
        <div className="max-w-md w-full">
          <h1 className="text-5xl font-bold mb-2">Welcome back</h1>
          <p className="text-gray-500 mb-6">Please enter your details to login</p>

          {/* 🔹 Error messages */}
          {errors.length > 0 && (
            <div className="bg-red-100 text-red-600 p-3 mb-4 rounded">
              <ul className="list-disc list-inside space-y-1">
                {errors.map((err, idx) => (
                  <li key={idx}>{err}</li>
                ))}
              </ul>
            </div>
          )}

          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-sm font-medium">Email</label>
              <input
                type="email"
                className="w-full border rounded-lg px-3 py-2 mt-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>

            <div>
              <div className="flex justify-between items-center">
                <label className="block text-sm font-medium">Password</label>
                <a href="/reset" className="text-sm text-blue-500 hover:underline">
                  Forgot Password?
                </a>
              </div>
              <input
                type="password"
                className="w-full border rounded-lg px-3 py-2 mt-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>

            <div className="flex items-center">
              <input type="checkbox" id="remember" className="mr-2" />
              <label htmlFor="remember" className="text-sm text-gray-600">
                Remember me
              </label>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-500 text-white py-2 rounded-full hover:bg-blue-700 transition"
            >
              {loading ? "Signing in..." : "Login"}
            </button>
          </form>

          <p className="text-center text-sm text-gray-600 mt-6">
            Don’t have an account?{" "}
            <Link to="/signup" className="text-blue-500 hover:underline">
              Register
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
