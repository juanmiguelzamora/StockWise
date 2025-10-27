import React, { useState, useEffect, useRef } from "react";
import Navbar from "../layout/navbar";
import { Send } from "lucide-react";
import api from "../services/api";

interface Message {
  role: "user" | "ai";
  content: string;
}

const AIAssistant: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([
    {
      role: "ai",
      content:
        "👋 Hello! I’m your Stockwise AI Assistant. I can provide insights into your inventory, analyze trends, make predictions, and help optimize your stock management. What would you like to explore?",
    },
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);

  const chatEndRef = useRef<HTMLDivElement | null>(null);

  // ✅ Auto-scroll only when messages update (prevents scrollbar flicker)
  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // ✅ Quick Actions
  const quickActions = [
    
    { title: "Check Stock", query: "What is the total stock?" },
    { title: "Seasonal Trends", query: "predict christmas trends for clothing" },
  ];

  // 🧩 Unified send function
  const sendQuery = async (query: string) => {
    if (!query.trim() || loading) return;
    const userMessage: Message = { role: "user", content: query };

    setMessages((prev) => [...prev, userMessage]);
    setInput("");
    setLoading(true);

    try {
      const res = await api.post("ai/ask/", { query });
      let aiResponse = "No response from AI.";

      if (res.data) {
        const r = res.data.response || res.data;

        // Handle general inventory response
        if (r.query_type === "general_inventory") {
          aiResponse = `📊 **Overall Inventory Status**\n\n`;
          aiResponse += `📦 Total Products: ${r.total_products}\n`;
          aiResponse += `📈 Total Stock: ${r.total_stock.toLocaleString()} units\n`;
          aiResponse += `📉 Average Daily Sales: ${r.average_daily_sales.toFixed(2)} units/day\n`;
          aiResponse += `⚠️ Low Stock Items: ${r.low_stock_items}\n`;
          aiResponse += `❌ Out of Stock Items: ${r.out_of_stock_items}\n\n`;
          
          if (r.top_categories && r.top_categories.length > 0) {
            aiResponse += `🏆 **Top Categories by Stock:**\n`;
            r.top_categories.forEach((cat: any, i: number) => {
              aiResponse += `${i + 1}. ${cat.category}: ${cat.stock.toLocaleString()} units\n`;
            });
            aiResponse += `\n`;
          }
          
          aiResponse += `${r.restock_needed ? "⚠️" : "✅"} ${r.summary}\n\n`;
          aiResponse += `💡 ${r.recommendation}`;
        }
        // Handle item-specific response
        else if (r.item) {
          aiResponse = `🛒 **${r.item}** — Current stock: ${r.current_stock}, Average daily sales: ${r.average_daily_sales}. ${
            r.restock_needed ? "⚠️ Restock needed!" : "✅ Stock sufficient."
          }\n\n💡 ${r.recommendation}`;
        }
        // Handle category response
        else if (r.category) {
          aiResponse = `📦 **${r.category}** — Total stock: ${r.total_stock}, Avg daily sales: ${r.average_daily_sales}. ${
            r.restock_needed ? "⚠️ Restock needed!" : "✅ Stock healthy."
          }\n\n💡 ${r.recommendation}`;
        }
        // Handle trend predictions
        else if (r.predicted_trends) {
          aiResponse = `📊 **Inventory Trend Forecast**\n\n${r.predicted_trends
            .map(
              (t: any, i: number) =>
                `${i + 1}. **${t.keyword}** — 🔥 Trend Score: ${t.hot_score}\n   💡 ${t.suggestion}`
            )
            .join("\n\n")}\n\n🔮 *Overall Insight:* ${r.overall_prediction}`;
        }
        // Fallback for unknown response types
        else {
          aiResponse = JSON.stringify(r, null, 2);
        }
      }

      setMessages((prev) => [...prev, { role: "ai", content: aiResponse }]);
    } catch (err) {
      console.error("AI request failed:", err);
      setMessages((prev) => [
        ...prev,
        { role: "ai", content: "⚠️ Failed to get response from AI server." },
      ]);
    } finally {
      setLoading(false);
    }
  };

  const handleSend = () => sendQuery(input);
  const handleKeyPress = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") handleSend();
  };

  const clearChat = () => {
    setMessages([
      {
        role: "ai",
        content:
          "👋 Hello! I’m your Stockwise AI Assistant. I can provide insights into your inventory, analyze trends, make predictions, and help optimize your stock management. What would you like to explore?",
      },
    ]);
  };

  return (
    <section className="pt-28 px-6 min-h-screen bg-gray-50">
      <Navbar />

      {/* Header */}
      <div className="flex items-center gap-3 mb-6">
        <img
          src="/icon_ai.png"
          alt="AI Assistant Icon"
          className="w-9 h-9 object-contain"
        />
        <h2 className="text-2xl font-semibold text-gray-800">
          AI Assistant
        </h2>
      </div>

      <p className="text-gray-500 mb-6">
        Advanced AI insights for intelligent inventory management
      </p>

      <div className="max-w-6xl mx-auto relative">
        {/* Clear Chat Button */}
        <button
          onClick={clearChat}
          className="absolute -top-10 right-5 w-[60px] h-[30px] border border-gray-400/50 rounded-md text-[14px] text-gray-600 hover:bg-gray-100 transition"
        >
          Clear
        </button>

        {/* Chat Box */}
        <div className="bg-white rounded-[30px] shadow-lg p-6">
          <h3 className="text-xl font-medium text-[#242424] mb-6">
            Conversation
          </h3>

          {/* Messages */}
          <div
            className="space-y-6 max-h-[60vh] overflow-y-auto pr-3 scrollbar-thin scrollbar-thumb-gray-300 scrollbar-track-transparent"
            style={{ scrollBehavior: "smooth" }}
          >
            {messages.map((msg, i) => (
              <div
                key={i}
                className={`flex items-start gap-4 ${
                  msg.role === "user" ? "flex-row-reverse text-right" : ""
                }`}
              >
                {msg.role === "ai" ? (
                  <img
                    src="/icon_ai.png"
                    alt="AI"
                    className="w-10 h-10 rounded-full bg-[#5283FF]/10 p-2"
                  />
                ) : (
                  <div className="w-10 h-10 rounded-full bg-gray-400 text-white flex items-center justify-center font-semibold">
                    U
                  </div>
                )}

                <div
                  className={`p-4 rounded-xl text-base leading-relaxed whitespace-pre-wrap ${
                    msg.role === "ai"
                      ? "bg-[#F2F2F2] text-black"
                      : "bg-[#5283FF] text-white"
                  }`}
                >
                  {msg.content}
                </div>
              </div>
            ))}

            {/* Smooth "Thinking" bubble */}
            {loading && (
              <div className="flex items-center gap-3 text-gray-500 mt-2">
                <img
                  src="/icon_ai.png"
                  alt="AI Thinking"
                  className="w-8 h-8 rounded-full bg-[#5283FF]/10 p-1.5"
                />
                <div className="bg-[#F2F2F2] rounded-lg px-3 py-2 text-sm text-gray-500">
                  <span className="animate-pulse">Thinking...</span>
                </div>
              </div>
            )}
            <div ref={chatEndRef} />
          </div>

          {/* Quick Actions */}
          <div className="flex flex-wrap gap-3 mt-6">
            {quickActions.map((action, i) => (
              <button
                key={i}
                onClick={() => sendQuery(action.query)}
                disabled={loading}
                className="px-4 py-2 border border-gray-400/50 rounded-md text-sm text-[#242424] hover:bg-gray-100 transition disabled:opacity-50"
              >
                {action.title}
              </button>
            ))}
          </div>

          {/* Input */}
          <div className="flex items-center mt-6">
            <input
              type="text"
              placeholder="Ask me anything about your inventory..."
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyPress}
              className="flex-1 px-4 py-3 bg-[#F2F2F2] rounded-lg text-base placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#5283FF] transition"
            />
            <button
              onClick={handleSend}
              disabled={loading}
              className="ml-3 w-14 h-14 bg-[#5283FF] rounded-lg flex items-center justify-center hover:bg-blue-600 transition disabled:opacity-50"
            >
              <Send size={22} className="text-white" />
            </button>
          </div>
        </div>
      </div>
    </section>
  );
};

export default AIAssistant;
