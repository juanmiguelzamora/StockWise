import { useState, useEffect } from "react";


export default function ResetConfirm() {
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");
  const [oobCode, setOobCode] = useState("");

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    setOobCode(params.get("oobCode"));
  }, []);

  const handleConfirm = async () => {
    try {
      await confirmPasswordReset(auth, oobCode, password);
      setMessage("Password has been reset! You can now log in.");
    } catch (error) {
      setMessage(error.message);
    }
  };

  return (
    <div>
      <h2>Enter New Password</h2>
      <input
        type="password"
        placeholder="New password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <button onClick={handleConfirm}>Reset Password</button>
      <p>{message}</p>
    </div>
  );
}