import React, { useState, useEffect, useRef } from "react";

// Small helper to hide potentially malformed raw responses and let user reveal if needed
const RawResponseToggle: React.FC<{ raw: string }> = ({ raw }) => {
  const [visible, setVisible] = useState(false);
  return (
    <div className="mt-2">
      <div className="rounded-md bg-yellow-50 border border-yellow-200 p-3">
        <div className="text-sm text-yellow-800">⚠️ The AI produced malformed or partial JSON — raw output hidden to avoid confusing the UI.</div>
        <div className="mt-2 flex gap-2">
          <button
            className="px-3 py-1 bg-yellow-100 text-yellow-900 rounded text-sm"
            onClick={() => setVisible((v) => !v)}
          >
            {visible ? "Hide raw" : "Show raw"}
          </button>
          <a
            className="px-3 py-1 text-sm border rounded hover:bg-gray-50"
            href="/support"
          >
            Report issue
          </a>
        </div>
      </div>
      {visible && (
        <pre className="mt-3 bg-gray-100 p-3 rounded-md text-sm overflow-auto">{raw}</pre>
      )}
    </div>
  );
};
import Navbar from "../layout/navbar";
import { Send } from "lucide-react";
import api from "../services/api";

interface Message {
  role: "user" | "ai";
  // allow strings or React nodes so we can render structured UI for AI responses
  content: React.ReactNode;
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

  // auto-scroll only when messages update (prevents scrollbar flicker)
  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // Quick Actions
  const quickActions = [
    
    { title: "Check Stock", query: "What is the total stock?" },
    { title: "Seasonal Trends", query: "predict christmas trends for clothing" },
  ];

  // Unified send function
  const sendQuery = async (query: string) => {
    if (!query.trim() || loading) return;
    const userMessage: Message = { role: "user", content: query };

    setMessages((prev) => [...prev, userMessage]);
    setInput("");
    setLoading(true);

    try {
      const res = await api.post("ai/ask/", { query });
      let aiResponse: React.ReactNode = <div>No response from AI.</div>;

      if (res.data) {
        const r = res.data.response || res.data;

        // General inventory (keep as rich text)
        if (r && r.query_type === "general_inventory") {
          aiResponse = (
            <div className="prose">
              <h4>📊 Overall Inventory Status</h4>
              <p>📦 <strong>Total Products:</strong> {r.total_products}</p>
              <p>📈 <strong>Total Stock:</strong> {Number(r.total_stock).toLocaleString()} units</p>
              <p>📉 <strong>Average Daily Sales:</strong> {Number(r.average_daily_sales).toFixed(2)} units/day</p>
              <p>⚠️ <strong>Low Stock Items:</strong> {r.low_stock_items}</p>
              <p>❌ <strong>Out of Stock Items:</strong> {r.out_of_stock_items}</p>
              {r.top_categories && r.top_categories.length > 0 && (
                <div>
                  <h5>🏆 Top Categories by Stock</h5>
                  <ul>
                    {r.top_categories.map((cat: any, i: number) => (
                      <li key={i}>{i + 1}. {cat.category}: {Number(cat.stock).toLocaleString()} units</li>
                    ))}
                  </ul>
                </div>
              )}
              <p className="mt-2">{r.restock_needed ? "⚠️" : "✅"} {r.summary}</p>
              <p>💡 {r.recommendation}</p>
            </div>
          );
        }

        // Item-specific
        else if (r && r.item) {
          const recText = String(r.recommendation || "");
          const notFound = /not found|not in inventory|verify the product name|no such item/i.test(recText);

          if (notFound) {
            aiResponse = (
              <div>
                <div className="flex items-center gap-3">
                  <h4 className="text-lg font-medium">🛒 {r.item}</h4>
                  <span className="ml-2 text-sm px-2 py-0.5 bg-red-100 text-red-700 rounded">Not found</span>
                </div>

                <p className="mt-2 text-sm text-gray-600">Item not found in inventory. Please verify the product name or browse existing products.</p>

                <div className="mt-3 flex gap-2">
                  <button
                    className="px-3 py-1 bg-blue-600 text-white rounded text-sm"
                    onClick={() => (window.location.href = "/inventory")}
                  >
                    View products
                  </button>
                  <button
                    className="px-3 py-1 border rounded text-sm"
                    onClick={() => navigator.clipboard?.writeText(String(r.item))}
                  >
                    Copy name
                  </button>
                </div>

                {recText && (
                  <p className="mt-3 text-gray-700 text-sm">💡 {recText}</p>
                )}
              </div>
            );
          } else {
            aiResponse = (
              <div>
                <h4>🛒 {r.item}</h4>
                <p><strong>Current stock:</strong> {r.current_stock}</p>
                <p><strong>Average daily sales:</strong> {r.average_daily_sales}</p>
                <p>{r.restock_needed ? "⚠️ Restock needed!" : "✅ Stock sufficient."}</p>
                <p>💡 {r.recommendation}</p>
              </div>
            );
          }
        }

        // Category
        else if (r && r.category) {
          aiResponse = (
            <div>
              <h4>📦 {r.category}</h4>
              <p><strong>Total stock:</strong> {r.total_stock}</p>
              <p><strong>Avg daily sales:</strong> {r.average_daily_sales}</p>
              <p>{r.restock_needed ? "⚠️ Restock needed!" : "✅ Stock healthy."}</p>
              <p>💡 {r.recommendation}</p>
            </div>
          );
        }

        // Trend predictions array
        else if (r && Array.isArray(r.predicted_trends)) {
          aiResponse = (
            <div>
              <h4>📊 Inventory Trend Forecast</h4>
              <div className="grid gap-3 mt-3">
                {r.predicted_trends.map((t: any, i: number) => (
                  <div key={i} className="p-3 rounded-lg border border-gray-200">
                    <div className="flex items-center justify-between">
                      <strong className="text-sm">{t.keyword}</strong>
                      <span className="text-xs text-gray-500">🔥 {t.hot_score}</span>
                    </div>
                    <p className="text-sm mt-2">💡 {t.suggestion}</p>
                  </div>
                ))}
              </div>
              {r.overall_prediction && <p className="mt-3">🔮 <em>{r.overall_prediction}</em></p>}
            </div>
          );
        }

        // Single trend object: { keyword, hot_score, suggestion }
        else if (r && (r.keyword || r.hot_score) && (r.suggestion || r.suggest)) {
          const keyword = r.keyword || r.title || "Trend";
          const hot = r.hot_score ?? r.hotScore ?? "N/A";
          const suggestion = r.suggestion || r.suggest || "";
          aiResponse = (
            <div className="p-3 rounded-lg border border-gray-200">
              <div className="flex items-center justify-between">
                <strong className="text-sm">{keyword}</strong>
                <span className="text-xs text-gray-500">🔥 {hot}</span>
              </div>
              <p className="text-sm mt-2">💡 {suggestion}</p>
            </div>
          );
        }

          // Fallback handling
          else {
            // If backend returned a plain string that mentions JSON parsing failures,
            // hide the raw data and show a friendly error with an optional reveal toggle.
            if (typeof r === "string") {
              const isParseError = /All JSON candidates failed|All JSON/i.test(r) || /raw:/i.test(r);
              if (isParseError) {
                aiResponse = <RawResponseToggle raw={r} />;
              } else {
                // plain string (not a parse failure) -> render as text
                aiResponse = <div className="whitespace-pre-wrap">{r}</div>;
              }
            } else {
              // unknown object -> pretty JSON
              aiResponse = (
                <pre className="bg-gray-100 p-3 rounded-md text-sm overflow-auto">{JSON.stringify(r, null, 2)}</pre>
              );
            }
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