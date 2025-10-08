import React from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "./App";
import "./index.css"; // make sure this line is present
import { InventoryProvider } from "./contexts/InventoryContext";


const container = document.getElementById("root");

if (!container) {
  throw new Error("Root container not found");
}

const root = createRoot(container);
root.render(
  <React.StrictMode>
     <InventoryProvider>
    <BrowserRouter>
      <App />
    </BrowserRouter>
    </InventoryProvider>
  </React.StrictMode>
);
