// src/authService.js
import api from "./api";

// --- Firebase imports ---
import { auth } from "./firebase";
import { signInWithEmailAndPassword } from "firebase/auth";

// --- Firebase login ---
export async function loginFirebase(email, password) {
  const userCred = await signInWithEmailAndPassword(auth, email, password);
  const token = await userCred.user.getIdToken();
  localStorage.setItem("authType", "firebase");
  localStorage.setItem("accessToken", token);
  return { type: "firebase", token };
}

// --- Django JWT login ---
export async function loginDjango(email, password) {
  const res = await api.post("/api/v1/auth/jwt/login/", { email, password });
  localStorage.setItem("authType", "jwt");
  localStorage.setItem("accessToken", res.data.access);
  localStorage.setItem("refreshToken", res.data.refresh);
  return { type: "jwt", token: res.data.access };
}

// --- Logout ---
export function logout() {
  localStorage.removeItem("authType");
  localStorage.removeItem("accessToken");
  localStorage.removeItem("refreshToken");
}
