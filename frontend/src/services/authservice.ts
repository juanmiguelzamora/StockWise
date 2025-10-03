import api from "./api";

// Define the expected shape of the login response from Django
interface LoginResponse {
  access: string;
  refresh: string;
  [key: string]: any; // allow extra fields if backend adds more
}

// --- Django JWT login ---
export async function loginDjango(
  email: string,
  password: string
): Promise<{ type: "jwt"; token: string }> {
  try {
    const res = await api.post<LoginResponse>("users/login/", { email, password });

    // Save tokens & auth type for multi-tab sync
    sessionStorage.setItem("authType", "jwt");
    sessionStorage.setItem("accessToken", res.data.access);
    sessionStorage.setItem("refreshToken", res.data.refresh);
    sessionStorage.setItem("authChanged", Date.now().toString()); // must be string for sessionStorage

    return { type: "jwt", token: res.data.access };
  } catch (err: any) {
    // Handle API error safely
    const errorMessage: string =
      err?.response?.data?.detail ||
      err?.response?.data?.non_field_errors?.[0] ||
      "Login failed. Please check your credentials.";

    throw new Error(errorMessage);
  }
}

// --- Logout ---
export function logout(): void {
  sessionStorage.removeItem("authType");
  sessionStorage.removeItem("accessToken");
  sessionStorage.removeItem("refreshToken");
  sessionStorage.setItem("authChanged", Date.now().toString()); // must be string

  // Optional: redirect to login page
  window.location.href = "/login";
}
