import axios from "axios";

const api = axios.create({
  baseURL: "http://127.0.0.1:8000", // Django backend
  withCredentials: true, // send cookies
});

// Get CSRF token
export async function getCSRFToken() {
  const res = await api.get("/auth/csrf/");
  return res.data.csrfToken;
}

fetch('http://127.0.0.1:8000/auth/csrf/', { credentials: 'include' })
  .then(res => { console.log('status', res.status); return res.json().catch(()=>null); })
  .then(body => console.log('body', body))
  .catch(err => console.error('fetch error', err));

export default api;
