import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";

export default function Signup() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState([]); // now an array
  const navigate = useNavigate();

  const handleSignup = async (e) => {
    e.preventDefault();

    // frontend validation
    if (!email || !password || !confirmPassword) {
      setErrors(["⚠️ Please fill in all fields"]);
      return;
    }

    if (password !== confirmPassword) {
      setErrors(["⚠️ Passwords do not match"]);
      return;
    }

    setLoading(true);
    setErrors([]);

    try {
      const res = await fetch("http://localhost:8000/api/v1/users/signup/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });

      const data = await res.json();

      if (!res.ok) {
        // Extract all error messages
        let errorList = [];

        if (typeof data === "string") {
          errorList.push(data);
        } else if (data.detail) {
          errorList.push(data.detail);
        } else {
          for (const key in data) {
            if (Array.isArray(data[key])) {
              errorList = [...errorList, ...data[key]];
            } else if (typeof data[key] === "string") {
              errorList.push(data[key]);
            }
          }
        }

        setErrors(errorList.length > 0 ? errorList : ["Signup failed. Please try again."]);
        setLoading(false);
        return;
      }

      // success → save JWT
      if (data.token) {
        localStorage.setItem("token", data.token);
      }

      navigate("/dashboard");
    } catch (err) {
      setErrors(["Network error: " + err.message]);
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

          {/* Show all errors */}
          {errors.length > 0 && (
            <div className="bg-red-100 text-red-600 p-3 mb-4 rounded">
              <ul className="list-disc list-inside space-y-1">
                {errors.map((err, idx) => (
                  <li key={idx}>{err}</li>
                ))}
              </ul>
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
            </div>

            <div>
              <label className="block text-sm font-medium">Password</label>
              <input
                type="password"
                className="w-full border rounded-lg px-3 py-2 mt-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>

            <div>
              <label className="block text-sm font-medium">Confirm Password</label>
              <input
                type="password"
                className="w-full border rounded-lg px-3 py-2 mt-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
              />
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
