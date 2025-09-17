import axios from "axios";

const api = axios.create({
  baseURL: "http://127.0.0.1:8000/api/v1/", // ✅ include /api/v1/
});

// Attach JWT token from localStorage
// Attach JWT token from sessionStorage
api.interceptors.request.use((config) => {
  const token = sessionStorage.getItem("access");  // 👈 use sessionStorage
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
// (Optional) Get CSRF token if you ever need it for non-JWT endpoints
export async function getCSRFToken() {
  const res = await api.get("auth/csrf/");
  return res.data.csrfToken;
}

export default api;
