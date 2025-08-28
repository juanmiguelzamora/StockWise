import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyCiSjQXG6eMOWzKpT6zqCSNWlMWz9hFvfM",
  authDomain: "stockwise-a19d2.firebaseapp.com",
  projectId: "stockwise-a19d2",
  storageBucket: "stockwise-a19d2.firebasestorage.app",
  messagingSenderId: "647273326250",
  appId: "1:647273326250:web:ad7fc94e7ca8bd5b5d52d3"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);


