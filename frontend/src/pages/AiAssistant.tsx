// src/pages/AIAssistant.tsx
import React from "react";
import Navbar from "../layout/navbar";

const AIAssistant: React.FC = () => {
  return (
    <section style={{ marginTop: "8rem", textAlign: "left" }}>
      <h2>AI Assistant Page</h2>
      <Navbar />
      <div style={{ padding: "1rem" }}>
        <p>This is the AI Assistant page content.</p>
      </div>
    </section>
  );
};

export default AIAssistant;
