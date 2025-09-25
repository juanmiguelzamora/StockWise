// src/authService.js
import api from "./api";

// --- Django JWT login ---
export async function loginDjango(email, password) {
  try {
    const res = await api.post("users/login/", { email, password });

    // Save tokens & auth type for multi-tab sync
    sessionStorage.setItem("authType", "jwt");
    sessionStorage.setItem("accessToken", res.data.access);
    sessionStorage.setItem("refreshToken", res.data.refresh);
    sessionStorage.setItem("authChanged", Date.now()); // trigger storage event in other tabs

    return { type: "jwt", token: res.data.access };
  } catch (err) {
    // Return readable error for frontend
    const errorMessage =
      err.response?.data?.detail ||
      err.response?.data?.non_field_errors?.[0] ||
      "Login failed. Please check your credentials.";
    throw new Error(errorMessage);
  }
}

// --- Logout ---
export function logout() {
  sessionStorage.removeItem("authType");
  sessionStorage.removeItem("accessToken");
  sessionStorage.removeItem("refreshToken");
  sessionStorage.setItem("authChanged", Date.now()); // trigger storage event in other tabs

  // Optional: redirect to login page
  window.location.href = "/login";
}
