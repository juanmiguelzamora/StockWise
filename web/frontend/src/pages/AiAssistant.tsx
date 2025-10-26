// src/pages/AIAssistant.tsx
import React from "react";
import Navbar from "../layout/navbar";
import { Send } from "lucide-react";

const AIAssistant: React.FC = () => {
  return (
    <section className="pt-28 px-6 min-h-screen bg-gray-50">
      {/* Navbar */}
      <Navbar />

      {/* Page Title with Icon */}
      <div className="flex items-center gap-3 mb-6">
        <img
          src="/icon_ai.png" // ✅ served from /public
          alt="AI Assistant Icon"
          className="w-8 h-8 object-contain"
        />
        <h2 className="text-2xl font-semibold text-gray-800">AI Assistant</h2>
      </div>

      <p className="text-gray-500 mb-6">
        Advanced AI insights for intelligent inventory management
      </p>

     {/* Conversation Section */}
      <div className="max-w-6xl mx-auto relative">
        {/* Clear button styled like Figma */}
        <button
          className="absolute -top-10 right-5 w-[50px] h-[30px] border border-[#242424]/50 rounded-[5px] text-[15px] text-[#242424]/80 hover:bg-gray-100 transition"
        >
          Clear
        </button>


        {/* Conversation Box */}
        <div className="bg-white rounded-[30px] shadow-md p-6">
          {/* Title */}
          <h3 className="text-xl font-medium text-[#242424] mb-6">
            Conversation
          </h3>

          {/* Message Row */}
          <div className="flex items-start gap-4 mb-6">
            {/* Circle Icon */}
            <div className="w-10 h-10 rounded-full bg-[#5283FF] flex items-center justify-center">
              <span className="text-white font-semibold">AI</span>
            </div>

            {/* Message Bubble */}
            <div className="flex-1 bg-[#F2F2F2] rounded-lg p-4 text-black text-base leading-relaxed">
              Hello! I’m your Stockwise AI Assistant powered by advanced language
              models. I can provide deep insights into your inventory, analyze
              trends, make predictions, and help optimize your stock management.
              What would you like to explore?
            </div>
          </div>

          {/* Quick Action Buttons */}
          <div className="flex gap-4 mb-6">
            <button className="px-4 py-2 border border-gray-400/50 rounded-md text-sm text-[#242424] hover:bg-gray-100 transition">
              Stock Analysis
            </button>
            <button className="px-4 py-2 border border-gray-400/50 rounded-md text-sm text-[#242424] hover:bg-gray-100 transition">
              Category Insights
            </button>
          </div>

          {/* Input Section */}
          <div className="flex items-center">
            <input
              type="text"
              placeholder="Ask me everything about your inventory"
              className="flex-1 px-4 py-3 bg-[#F2F2F2] rounded-lg text-base placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#5283FF] transition"
            />
            <button className="ml-3 w-14 h-14 bg-[#5283FF] rounded-lg flex items-center justify-center hover:bg-blue-600 transition">
              <Send size={22} className="text-white" />
            </button>
          </div>
        </div>
      </div>
    </section>
  );
};

export default AIAssistant;
