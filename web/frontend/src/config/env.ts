const DEV_API_FALLBACK = "http://127.0.0.1:8000/api/";

function normalizeApiBaseUrl(value: string): string {
  const trimmed = value.trim();
  return trimmed.endsWith("/") ? trimmed : `${trimmed}/`;
}

function resolveApiBaseUrl(): string {
  const configured = import.meta.env.VITE_API_BASE_URL?.trim();
  if (configured) {
    return normalizeApiBaseUrl(configured);
  }
  return DEV_API_FALLBACK;
}

/** Django API base, e.g. https://your-backend.com/api/ */
export const API_BASE_URL = resolveApiBaseUrl();

/** Backend origin without /api, used for media URLs */
export const BACKEND_ORIGIN = API_BASE_URL.replace(/\/api\/?$/, "").replace(/\/$/, "");

/** Build a full media URL from a relative or absolute path */
export function resolveMediaUrl(path: string | null | undefined): string | null {
  if (!path?.trim()) return null;

  const value = path.trim();
  if (/^https?:\/\//i.test(value)) return value;

  if (value.startsWith("/")) {
    return `${BACKEND_ORIGIN}${value}`;
  }

  return `${BACKEND_ORIGIN}/media/${value}`;
}

if (import.meta.env.PROD) {
  const usesLocalhost =
    API_BASE_URL.includes("127.0.0.1") || API_BASE_URL.includes("localhost");

  if (usesLocalhost) {
    console.error(
      "[StockWise] VITE_API_BASE_URL points to localhost in production. " +
        "Login will only work on the machine running the backend. " +
        "Set VITE_API_BASE_URL in Vercel to your public HTTPS backend URL and redeploy."
    );
  }
}
