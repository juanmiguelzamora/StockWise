// Login.tsx
import React from "react";
import { useNavigate } from "react-router-dom";

export default function Login() {
    const navigate = useNavigate();

    const handleLogin = (e: React.FormEvent) => {
        e.preventDefault();
        // You can add authentication logic here later
        navigate("/dashboard"); // Redirect to dashboard
    };

    return (
        <div style={styles.container}>
            <div style={styles.card}>
                {/* Logo */}
                <div style={styles.logo}>
                    <img
                        src="https://via.placeholder.com/150x40?text=STOCKWISE"
                        alt="Logo"
                        style={{ height: 40 }}
                    />
                </div>

                {/* Illustration */}
                <img
                    src="https://undraw.co/api/illustrations/54a77543-e5ae-42be-a38a-e839a65b1a62"
                    alt="Illustration"
                    style={{ height: 120, marginBottom: 16 }}
                />

                {/* Welcome text */}
                <h2 style={styles.heading}>Welcome back</h2>
                <p style={styles.subheading}>Please enter your details to login.</p>

                {/* Form */}
                <form style={styles.form} onSubmit={handleLogin}>
                    <div style={styles.inputGroup}>
                        <label htmlFor="email" style={styles.label}>Email</label>
                        <input
                            id="email"
                            type="email"
                            placeholder="johndoe@gmail.com"
                            style={styles.input}
                            required
                        />
                    </div>

                    <div style={styles.inputGroup}>
                        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                            <label htmlFor="password" style={styles.label}>Password</label>
                            <a href="/forgot-password" style={styles.forgotLink}>Forgot Password</a>
                        </div>
                        <input
                            id="password"
                            type="password"
                            placeholder="********"
                            style={styles.input}
                            required
                        />
                    </div>

                    <div style={styles.rememberMe}>
                        <input type="checkbox" id="remember" />
                        <label htmlFor="remember" style={{ fontSize: 13, marginLeft: 6, color: "#374151" }}>
                            Remember me
                        </label>
                    </div>

                    <button type="submit" style={styles.button}>
                        Login
                    </button>

                    <p style={styles.footerText}>
                        Don’t have an account?{" "}
                        <a href='.pages/signup' style={styles.registerLink}>Register</a>
                    </p>
                </form>
            </div>
        </div>
    );
}

// styles object (same as before)
const styles: { [key: string]: React.CSSProperties } = {
    container: {
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "#f9fafb",
    },
    card: {
        backgroundColor: "#fff",
        padding: "40px 32px",
        borderRadius: 8,
        boxShadow: "0 8px 24px rgba(0,0,0,0.06)",
        width: 400,
        maxWidth: "90%",
        textAlign: "center",
    },
    logo: {
        display: "flex",
        justifyContent: "center",
        marginBottom: 24,
    },
    heading: {
        fontSize: 28,
        fontWeight: 700,
        marginBottom: 4,
        color: "#111827",
    },
    subheading: {
        fontSize: 14,
        color: "#6b7280",
        marginBottom: 24,
    },
    form: {
        display: "flex",
        flexDirection: "column",
        gap: 16,
    },
    inputGroup: {
        textAlign: "left",
    },
    label: {
        fontSize: 14,
        marginBottom: 6,
        color: "#374151",
    },
    input: {
        width: "100%",
        padding: "10px 12px",
        border: "1px solid #d1d5db",
        borderRadius: 6,
        fontSize: 14,
        outline: "none",
    },
    forgotLink: {
        fontSize: 12,
        color: "#3b82f6",
        textDecoration: "none",
    },
    rememberMe: {
        display: "flex",
        alignItems: "center",
    },
    button: {
        marginTop: 8,
        padding: "10px 16px",
        backgroundColor: "#3b82f6",
        color: "#fff",
        border: "none",
        borderRadius: 999,
        fontWeight: 600,
        cursor: "pointer",
        fontSize: 15,
    },
    footerText: {
        fontSize: 13,
        marginTop: 20,
        color: "#6b7280",
    },
    registerLink: {
        color: "#3b82f6",
        textDecoration: "none",
        marginLeft: 4,
    },
};
