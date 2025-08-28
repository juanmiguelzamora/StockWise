import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: "0.0.0.0",   // allow access on your LAN (phone, other devices)
    port: 5173,
  },
  resolve: {
    alias: {
      "@": "/src",
    },
  },
  build: {
    outDir: "dist",
  },
  // 👇 This is the important part
  preview: {
    port: 5173,
    strictPort: true,
  },
});
