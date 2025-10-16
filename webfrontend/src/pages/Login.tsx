import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import api from "../services/api"; // ✅ your axios instance

interface LoginResponse {
  access: string;
  refresh: string;
}

const Login: React.FC = () => {
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(false);
  const [errors, setErrors] = useState<string[]>([]);
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setErrors([]);

    if (!email || !password) {
      setErrors(["⚠️ Please fill in all fields"]);
      return;
    }

    setLoading(true);

    try {
      // ✅ Django JWT endpoint
      const res = await api.post<LoginResponse>("token/", { email, password });
      const { access, refresh } = res.data;

      if (access && refresh) {
        // Save tokens to localStorage (works with interceptors)
        localStorage.setItem("access", access);
        localStorage.setItem("refresh", refresh);

        navigate("/dashboard");
      } else {
        setErrors(["⚠️ Invalid response from server (missing tokens)."]);
      }
    } catch (err: any) {
      const errorList: string[] = [];

      if (!err.response) {
        errorList.push("❌ Unable to connect to backend. Please check your server.");
      } else if (err.response.status === 401) {
        errorList.push("⚠️ Invalid email or password.");
      } else {
        // Extract Django REST error messages
        const extractErrors = (obj: any): void => {
          if (!obj) return;
          if (Array.isArray(obj)) obj.forEach(extractErrors);
          else if (typeof obj === "object") Object.values(obj).forEach(extractErrors);
          else errorList.push(String(obj));
        };
        extractErrors(err.response.data);
      }

      setErrors(errorList.length ? errorList : ["⚠️ Login failed."]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="h-screen w-screen bg-white flex flex-col overflow-hidden">
      {/* Top logo */}
      <div className="pt-4 px-4 sm:px-6 lg:px-10">
        <img
          src="/toplogo.png"
          alt="Top Logo"
          className="h-8 sm:h-10 md:h-12 lg:h-14 xl:h-16 object-contain"
        />
      </div>

      {/* Center content */}
      <div className="flex flex-1 items-center justify-center px-4 sm:px-6">
        <div className="w-full max-w-md text-center -translate-y-6 sm:-translate-y-10">
          <img
            src="/loginlogo.png"
            alt="Login Illustration"
            className="mx-auto mb-4 h-20 sm:h-24 md:h-28 lg:h-32 object-contain"
          />
          <h1 className="text-2xl sm:text-3xl font-bold text-[#242424] mb-1">
            Welcome back
          </h1>
          <p className="text-gray-500 mb-6 text-sm sm:text-base">
            Please enter your details to login.
          </p>

          {/* Errors */}
          {errors.length > 0 && (
            <div className="bg-red-100 text-red-600 p-3 mb-6 rounded text-left text-sm">
              <ul className="list-disc list-inside space-y-1">
                {errors.map((err, idx) => (
                  <li key={idx}>{err}</li>
                ))}
              </ul>
            </div>
          )}

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

          {/* Register */}
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
