import React, { useId } from "react";
import {
    Bar,
    BarChart,
    CartesianGrid,
    ResponsiveContainer,
    Tooltip,
    XAxis,
    YAxis,
} from "recharts";

export default function Dashboard() {
    const gradientIdIn = useId();
    const gradientIdOut = useId();

    const stockData = [
        { day: "Mon", in: 200, out: 300, full: 400 },
        { day: "Tue", in: 100, out: 80, full: 400 },
        { day: "Wed", in: 300, out: 250, full: 400 },
        { day: "Thu", in: 400, out: 300, full: 400 },
        { day: "Fri", in: 350, out: 250, full: 400 },
        { day: "Sat", in: 300, out: 200, full: 400 },
        { day: "Sun", in: 200, out: 120, full: 400 },
    ];

    const history = [
        { item: "Wireless Headphones", stock: 324, change: -100 },
        { item: "Wireless Headphones", stock: 454, change: +100 },
    ];

    // Styles
    const container: React.CSSProperties = {
        maxWidth: 1200,
        margin: "40px auto",
        fontFamily: `"Inter", "Helvetica Neue", Arial, sans-serif`,
        padding: "12px 20px",
    };

    const topRow: React.CSSProperties = {
        display: "flex",
        gap: 18,
        alignItems: "flex-start",
        marginTop: 10,
    };

    const todayCard: React.CSSProperties = {
        background: "linear-gradient(90deg,#8fb7ff,#3b82f6)",
        marginTop: 15,
        color: "#fff",
        borderRadius: 14,
        flexDirection: "column",
        padding: 20,
        height: 75,
        width: 560,
        boxShadow: "0 6px 22px rgba(19,50,96,0.08)",
    };

    const cardsRightGroup: React.CSSProperties = {
        display: "flex",
        gap: 18,
        marginLeft: "auto",
    };

    const smallCardBase: React.CSSProperties = {
        marginTop: 15,
        borderRadius: 16,
        padding: 20,
        width: 200,
        boxSizing: "border-box",
        color: "#fff",
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
        position: "relative",
        fontFamily: `"Inter", "Helvetica Neue", Arial, sans-serif`,
    };

    const overstockCard: React.CSSProperties = {
        ...smallCardBase,
        backgroundColor: "#1f1f1f",
        border: "4px solid #c4c4c4",
    };

    const outOfStockRedCard: React.CSSProperties = {
        ...smallCardBase,
        backgroundColor: "#ff3b3b",
        border: "4px solid #ff8b8b",
    };

    const outOfStockYellowCard: React.CSSProperties = {
        ...smallCardBase,
        backgroundColor: "#ffc952",
        border: "4px solid #ffdf95",
        color: "#fff",
    };

    const textLabelStyle: React.CSSProperties = {
        fontSize: 16,
        opacity: 0.85,
    };

    const numberStyle: React.CSSProperties = {
        fontSize: 40,
        fontWeight: "700",
        marginTop: 6,
        lineHeight: 1,
    };

    const iconStyle: React.CSSProperties = {
        position: "absolute",
        top: 20,
        right: 20,
        width: 24,
        height: 24,
        opacity: 0.85,
    };

    const mainRow: React.CSSProperties = {
        display: "flex",
        gap: 24,
        marginTop: 26,
        alignItems: "flex-start",
    };

    const chartCard: React.CSSProperties = {
        background: "#fff",
        borderRadius: 14,
        padding: 22,
        width: 820,
        boxShadow: "0 6px 22px rgba(19,50,96,0.06)",
    };

    const historyCard: React.CSSProperties = {
        background: "#fff",
        borderRadius: 14,
        padding: 22,
        height: 369,
        width: 520,
        boxShadow: "0 6px 22px rgba(19,50,96,0.06)",
    };
    

    const smallText: React.CSSProperties = { fontSize: 12, opacity: 0.85 };

    return (
        <div style={container}>
            {/* Top row */}
            <div style={topRow}>
                {/* Today card */}
                <div style={todayCard}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                        <div style={smallText}>Today</div>
                        <div style={{ fontSize: 11, opacity: 0.85 }}>Jul 29, 2025</div>
                    </div>

                    <div
                        style={{
                            display: "flex",
                            justifyContent: "space-between",
                            alignItems: "center",
                            marginTop: 18,
                            textAlign: "center",
                        }}
                    >
                        {/* Total */}
                        <div style={{ flex: 1 }}>
                            <div style={{ fontSize: 32, fontWeight: 700 }}>392</div>
                            <div style={{ fontSize: 12, opacity: 0.9 }}>Total</div>
                        </div>

                        {/* Divider */}
                        <div
                            style={{
                                width: 1,
                                height: 48,
                                backgroundColor: "rgba(255, 255, 255, 0.4)",
                                margin: "0 20px",
                            }}
                        ></div>

                        {/* Stock In */}
                        <div style={{ flex: 1 }}>
                            <div style={{ fontSize: 22, fontWeight: 700 }}>123</div>
                            <div style={{ fontSize: 12, opacity: 0.9 }}>Stock In</div>
                        </div>

                        {/* Divider */}
                        <div
                            style={{
                                width: 1,
                                height: 48,
                                backgroundColor: "rgba(255, 255, 255, 0.4)",
                                margin: "0 20px",
                            }}
                        ></div>

                        {/* Stock Out */}
                        <div style={{ flex: 1 }}>
                            <div style={{ fontSize: 22, fontWeight: 700 }}>242</div>
                            <div style={{ fontSize: 12, opacity: 0.9 }}>Stock Out</div>
                        </div>
                    </div>
                </div>

                {/* Small cards with icons */}
                <div style={cardsRightGroup}>
                    {/* Overstock Card */}
                    <div style={overstockCard}>
                        <div style={textLabelStyle}>Overstock</div>
                        <div style={numberStyle}>10</div>
                        {/* Stopwatch icon */}
                        <svg
                            style={iconStyle}
                            fill="none"
                            stroke="#fff"
                            strokeWidth="2"
                            viewBox="0 0 24 24"
                        >
                            <circle cx="12" cy="13" r="7" stroke="#fff" strokeWidth="2" fill="none" />
                            <path d="M12 10v4l3 2" stroke="#fff" strokeWidth="2" strokeLinecap="round" />
                            <path d="M9 4h6" stroke="#fff" strokeWidth="2" strokeLinecap="round" />
                        </svg>
                    </div>

                    {/* Out of Stock Red Card */}
                    <div style={outOfStockRedCard}>
                        <div style={textLabelStyle}>Out of Stock</div>
                        <div style={numberStyle}>99</div>
                        {/* Timer cancel icon */}
                        <svg
                            style={iconStyle}
                            fill="none"
                            stroke="#fff"
                            strokeWidth="2"
                            viewBox="0 0 24 24"
                        >
                            <circle cx="12" cy="12" r="10" stroke="#fff" strokeWidth="2" />
                            <line x1="9" y1="9" x2="15" y2="15" stroke="#fff" strokeWidth="2" />
                            <line x1="15" y1="9" x2="9" y2="15" stroke="#fff" strokeWidth="2" />
                            <path d="M12 7v5" stroke="#fff" strokeWidth="2" strokeLinecap="round" />
                        </svg>
                    </div>

                    {/* Out of Stock Yellow Card */}
                    <div style={outOfStockYellowCard}>
                        <div style={textLabelStyle}>Out of Stock</div>
                        <div style={numberStyle}>32</div>
                        {/* Warning / low stock icon */}
                        <svg
                            style={iconStyle}
                            fill="none"
                            stroke="#fff"
                            strokeWidth="2"
                            viewBox="0 0 24 24"
                        >
                            <path d="M12 8v4" stroke="#fff" strokeWidth="2" strokeLinecap="round" />
                            <path d="M12 16h.01" stroke="#fff" strokeWidth="2" strokeLinecap="round" />
                            <circle cx="12" cy="12" r="10" stroke="#fff" strokeWidth="2" />
                        </svg>
                    </div>
                </div>
            </div>

            {/* Main row: chart and history */}
            <div style={mainRow}>
                <div style={chartCard}>
                    <div style={{ fontSize: 16, marginBottom: 10, fontWeight: 600 }}>Stock Movement</div>
                    <div style={{ width: "100%", height: 340 }}>
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart
                                data={stockData}
                                margin={{ top: 8, right: 16, left: 8, bottom: 18 }}
                                barCategoryGap="28%"
                            >
                                <defs>
                                    <linearGradient id={gradientIdIn} x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="0%" stopColor="#16a34a" stopOpacity={0.95} />
                                        <stop offset="70%" stopColor="#16a34a" stopOpacity={0.25} />
                                        <stop offset="100%" stopColor="#16a34a" stopOpacity={0.05} />
                                    </linearGradient>
                                    <linearGradient id={gradientIdOut} x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="0%" stopColor="#ef4444" stopOpacity={0.95} />
                                        <stop offset="70%" stopColor="#ef4444" stopOpacity={0.25} />
                                        <stop offset="100%" stopColor="#ef4444" stopOpacity={0.05} />
                                    </linearGradient>
                                </defs>
                                <CartesianGrid stroke="#e9eef1" strokeDasharray="4 8" vertical={false} />
                                <YAxis
                                    domain={[0, 420]}
                                    ticks={[0, 50, 100, 150, 200, 250, 300, 350, 400]}
                                    tick={{ fill: "#9aa5ad", fontSize: 11 }}
                                    axisLine={false}
                                />
                                <XAxis
                                    dataKey="day"
                                    axisLine={false}
                                    tickLine={false}
                                    tick={{ fontSize: 12, fill: "#8a98a0" }}
                                />
                                <Tooltip cursor={{ fill: "rgba(0,0,0,0.04)" }} />
                                <Bar dataKey="full" fill="#f2fbf3" barSize={44} radius={[10, 10, 0, 0]} />
                                <Bar dataKey="in" fill={`url(#${gradientIdIn})`} barSize={28} radius={[8, 8, 0, 0]} />
                                <Bar dataKey="out" fill={`url(#${gradientIdOut})`} barSize={28} radius={[8, 8, 0, 0]} />
                            </BarChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                <div style={historyCard}>
                    <div style={{ fontSize: 16, marginBottom: 10, fontWeight: 600 }}>History</div>
                    <div style={{ display: "flex", flexDirection: "column", gap: 18 }}>
                        {history.map((h) => (
                            <div
                                key={h.item + "-" + h.stock}
                                style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}
                            >
                                <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
                                    <div
                                        style={{
                                            width: 36,
                                            height: 36,
                                            borderRadius: 18,
                                            overflow: "hidden",
                                            flexShrink: 0,
                                        }}
                                    >
                                        <img
                                            src="/src/assets/Headphone.png"
                                            alt="headphone"
                                            style={{ width: "100%", height: "100%", objectFit: "cover" }}
                                        />
                                    </div>
                                    <div>
                                        <div style={{ fontSize: 13, fontWeight: 600 }}>{h.item}</div>
                                        <div style={{ fontSize: 12, color: "#8b98a0" }}>Stock: {h.stock}</div>
                                    </div>
                                </div>
                                <div
                                    style={{
                                        fontWeight: 700,
                                        color: h.change > 0 ? "#16a34a" : "#ef4444",
                                    }}
                                >
                                    {h.change > 0 ? "+" : ""}
                                    {h.change}
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
}
