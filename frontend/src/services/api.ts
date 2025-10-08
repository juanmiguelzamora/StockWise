import axios, { AxiosError, AxiosRequestConfig, AxiosResponse } from "axios";

const api = axios.create({
  baseURL:  "http://127.0.0.1:8000/api/v1/", //"http://192.168.0.102:8000/api/v1/", 
});

// Attach JWT token from sessionStorage
api.interceptors.request.use((config) => {
  const token = sessionStorage.getItem("accessToken");
  if (token) {
    if (!config.headers) {
      config.headers = new axios.AxiosHeaders();
    }
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor to handle token refresh
api.interceptors.response.use(
  (res) => res,
  async (err) => {
    const originalRequest = err.config;

    if (err.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      const refreshToken = sessionStorage.getItem("refreshToken");

      if (refreshToken) {
        try {
          const res = await axios.post(
            "http://192.168.0.100:8000/api/v1/token/refresh/",
            { refresh: refreshToken }
          );

          const newAccess = res.data.access;
          sessionStorage.setItem("accessToken", newAccess);

          originalRequest.headers.Authorization = `Bearer ${newAccess}`;
          return api(originalRequest);
        } catch (refreshErr) {
          console.error("Refresh token failed", refreshErr);
          sessionStorage.clear();
          window.location.href = "/login";
        }
      }
    }

    return Promise.reject(err);
  }
);

// Utility: CSRF token fetcher
export async function getCSRFToken() {
  const res = await api.get<{ csrfToken: string }>("auth/csrf/");
  return res.data.csrfToken;
}

export default api;
