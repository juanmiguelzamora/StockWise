import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import api from "../services/api"; // ✅ axios instance

// Define backend response type for login
interface LoginResponse {
  access?: string;
  refresh?: string;
  access_token?: string;
  refresh_token?: string;
}

const Login: React.FC = () => {
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(false);
  const [errors, setErrors] = useState<string[]>([]);
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent<HTMLFormElement>) => {
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

      const res = await api.post<LoginResponse>("users/login/", {
        email,
        password,
      });

      const data = res.data;

      // ✅ Save JWT tokens (backend may return access/refresh OR access_token/refresh_token)
      if ((data.access || data.access_token) && (data.refresh || data.refresh_token)) {
        const access = data.access || data.access_token || "";
        const refresh = data.refresh || data.refresh_token || "";

        sessionStorage.setItem("accessToken", access);
        sessionStorage.setItem("refreshToken", refresh);

        navigate("/dashboard");
      } else {
        setErrors(["⚠️ No tokens returned. Please check backend response."]);
      }
    } catch (err: any) {
      const errorList: string[] = [];

      if (!err.response) {
        // 🔹 Case 1: Backend/server unreachable
        errorList.push(
          "❌ Unable to reach the server. Please check your internet connection or backend."
        );
      } else {
        // 🔹 Case 2: Backend returned validation/auth errors
        const extractErrors = (obj: any): void => {
          if (!obj) return;
          if (Array.isArray(obj)) obj.forEach(extractErrors);
          else if (typeof obj === "object") Object.values(obj).forEach(extractErrors);
          else errorList.push(String(obj));
        };
        extractErrors(err.response.data);
      }

      if (errorList.length === 0) {
        errorList.push("⚠️ Invalid email or password.");
      }

      setErrors(errorList);
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
          className="h-8 sm:h-10 md:h-12 lg:h-14 xl:h-16 object-contain"
        />
      </div>

      {/* Center content */}
      <div className="flex flex-1 items-center justify-center px-4 sm:px-6">
        <div className="w-full max-w-md text-center -translate-y-6 sm:-translate-y-10">
          {/* Illustration */}
          <img
            src="/src/assets/loginlogo.png"
            alt="Login Illustration"
            className="mx-auto mb-4 h-20 sm:h-24 md:h-28 lg:h-32 object-contain"
          />

          {/* Heading */}
          <h1 className="text-2xl sm:text-3xl font-bold text-[#242424] mb-1">
            Welcome back
          </h1>
          <p className="text-gray-500 mb-6 text-sm sm:text-base">
            Please enter your details to login.
          </p>

          {/* Error messages */}
          {errors.length > 0 && (
            <div className="bg-red-100 text-red-600 p-3 mb-6 rounded text-left text-sm">
              <ul className="list-disc list-inside space-y-1">
                {errors.map((err, idx) => (
                  <li key={idx}>{err}</li>
                ))}
              </ul>
            </div>
          )}

          {/* Login Form */}
          <form onSubmit={handleLogin} className="text-left">
            {/* Email */}
            <div className="mb-5">
              <label className="block text-sm font-medium text-[#242424] mb-1">
                Email
              </label>
              <input
                type="email"
                className="w-full border rounded-md px-3 py-2 text-sm sm:text-base focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>

            {/* Password */}
            <div className="mb-5">
              <div className="flex justify-between items-center mb-1">
                <label className="block text-sm font-medium text-[#242424]">
                  Password
                </label>
                <a
                  href="/reset"
                  className="text-xs sm:text-sm text-blue-500 hover:underline"
                >
                  Forgot Password?
                </a>
              </div>
              <input
                type="password"
                className="w-full border rounded-md px-3 py-2 text-sm sm:text-base focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>

            {/* Remember me */}
            <div className="flex items-center mb-6">
              <input type="checkbox" id="remember" className="mr-2" />
              <label
                htmlFor="remember"
                className="text-xs sm:text-sm text-gray-600"
              >
                Remember me
              </label>
            </div>

            {/* Login button */}
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-500 text-white py-2 sm:py-3 text-sm sm:text-base rounded-full hover:bg-blue-600 transition"
            >
              {loading ? "Signing in..." : "Login"}
            </button>
          </form>

          {/* Register link */}
          <p className="text-center text-xs sm:text-sm text-gray-600 mt-6">
            Don’t have an account?{" "}
            <Link to="/signup" className="text-blue-500 hover:underline">
              Register
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
