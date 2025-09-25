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
        sessionStorage.setItem("accessToken", data.access);
        sessionStorage.setItem("refreshToken", data.refresh);
        sessionStorage.setItem("authChanged", Date.now());
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
  <div className="h-screen w-screen bg-white flex flex-col overflow-hidden">
    {/* Top bar with logo */}
    <div className="pt-4 px-4 sm:px-6 lg:px-10">
      <img
        src="/src/assets/toplogo.png"
        alt="Logo"
        className="h-8 sm:h-10 md:h-12 lg:h-14 xl:h-16 object-contain"
      />
    </div>

    {/* Center content */}
    <div className="flex flex-1 items-center justify-center px-4 sm:px-6">
      <div className="w-full max-w-md text-center -translate-y-6 sm:-translate-y-10">
        {/* Illustration */}
        <img
          src="/src/assets/signuplogo.png"
          alt="Signup Illustration"
          className="mx-auto mb-3 h-16 sm:h-20 md:h-24"
        />

        {/* Heading */}
        <h1 className="text-3xl sm:text-4xl font-bold text-[#242424] mb-1">
          Welcome!
        </h1>
        <p className="text-gray-500 mb-2">Create a new account.</p>

        {/* Errors */}
        {errors.non_field_errors && (
          <div className="bg-red-100 text-red-600 p-3 mb-4 rounded">
            {errors.non_field_errors.map((err, idx) => (
              <p key={idx}>{err}</p>
            ))}
          </div>
        )}

        {/* Signup Form */}
        <form onSubmit={handleSignup} className="text-left">
          {/* Email */}
          <div className="mb-5">
            <label
              htmlFor="email"
              className="block text-sm font-medium text-[#242424] ml-2 mb-1"
            >
              Email
            </label>
            <input
              type="email"
              id="email"
              className="w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            {errors.email && (
              <p className="text-red-500 text-sm">{errors.email[0]}</p>
            )}
          </div>

          {/* Password */}
          <div className="mb-5">
            <label
              htmlFor="password"
              className="block text-sm font-medium text-[#242424] ml-2 mb-1"
            >
              Password
            </label>
            <input
              type="password"
              id="password"
              className="w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            {errors.password && (
              <p className="text-red-500 text-sm">{errors.password[0]}</p>
            )}
          </div>

          {/* Confirm Password */}
          <div className="mb-8">
            <label
              htmlFor="confirmPassword"
              className="block text-sm font-medium text-[#242424] ml-2 mb-1"
            >
              Confirm Password
            </label>
            <input
              type="password"
              id="confirmPassword"
              className="w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
            />
            {errors.re_password && (
              <p className="text-red-500 text-sm">{errors.re_password[0]}</p>
            )}
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading}
            className="w-full bg-blue-500 text-white py-2 rounded-full hover:bg-blue-700 transition"
          >
            {loading ? "Creating account..." : "Sign up"}
          </button>
        </form>

        {/* Login link */}
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
