import api from "./api";

interface LoginResponse {
  access: string;
  refresh: string;
}

export async function login(email: string, password: string): Promise<void> {
  const res = await api.post<LoginResponse>("token/", { email, password });
  localStorage.setItem("access", res.data.access);
  localStorage.setItem("refresh", res.data.refresh);
}

export async function register(data: {
  email: string;
  password: string;
  username?: string;
}): Promise<void> {
  await api.post("register/", data);
}

export async function getUser(): Promise<any> {
  const res = await api.get("user/");
  return res.data;
}

export function logout(): void {
  localStorage.removeItem("access");
  localStorage.removeItem("refresh");
}