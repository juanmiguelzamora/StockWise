import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Link } from "react-router-dom";


export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();
const handleLogin = async (e) => {
  e.preventDefault();

  if (!email || !password) {
    setError("⚠️ Please fill in all fields");
    return;
  }

  setLoading(true);
  setError("");

  try {
    const res = await fetch("http://localhost:8000/api/v1/users/login/", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password }),
    });

    const data = await res.json();

    if (!res.ok) {
      let errorMessage = "Login failed. Please try again.";

      if (typeof data === "string") {
        errorMessage = data;
      } else if (data.detail) {
        errorMessage = data.detail; // DRF typical error
      } else {
        // Collect field-specific errors
        const errors = [];
        for (const key in data) {
          if (Array.isArray(data[key])) {
            errors.push(...data[key]);
          } else if (typeof data[key] === "string") {
            errors.push(data[key]);
          }
        }
        if (errors.length > 0) {
          errorMessage = errors.join(" ");
        }
      }

      setError(errorMessage);
      return;
    }

    // success → save JWT
    if (data.token) {
      localStorage.setItem("token", data.token);
    }

    navigate("/dashboard");
  } catch (err) {
    setError("Network error: " + err.message);
  } finally {
    setLoading(false);
  }
};



return (
  <div className="min-h-screen flex">
    {/* Left side illustration */}
    <div className="hidden md:flex w-1/2 bg-gradient-to-br from-white-500 to-white-600 flex-col items-center justify-center relative">
      
      {/* New logo at the top */}
      <img
      
        src="/toplogo.png"
        alt="Top Logo"
        className="absolute top-10  left-10 h-14 w-auto"
        
      />

      {/* Existing Illustration */}
      <img
        src="/loginlogo.png"
        alt="Login Illustration"
        className="max-w-md"
      />
    </div>



      {/* Right side form */}
      <div className="flex w-full md:w-1/2 items-center justify-center p-8">
        <div className="max-w-md w-full">
          {/* Removed Logo + App name */}

          {/* Heading */}
          <h1 className="text-5xl font-bold mb-2 ">Welcome back</h1>
          <p className="text-gray-500 mb-6">
            Please enter your details to login
          </p>

          {/* Error */}
          {error && (
            <div className="bg-red-100 text-red-600 p-2 mb-4 rounded">
              {error}
            </div>
          )}

          {/* Form */}
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

            {/* Remember me */}
            <div className="flex items-center">
              <input type="checkbox" id="remember" className="mr-2" />
              <label htmlFor="remember" className="text-sm text-gray-600">
                Remember me
              </label>
            </div>

            {/* Login button */}
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-500 text-white py-2 rounded-full hover:bg-blue-700 transition"
            >
              {loading ? "Signing in..." : "Login"}
            </button>
          </form>

          {/* Register link */}
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
