# StockWise Web Frontend - React + TypeScript

A modern, responsive web application for inventory management built with React, TypeScript, and Vite.

## 🚀 Tech Stack

- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool & dev server
- **React Router** - Client-side routing
- **Axios** - HTTP client
- **TailwindCSS** - Utility-first CSS
- **Lucide React** - Icon library

---

## 📁 Project Structure

```
src/
├── components/          # Reusable UI components
├── pages/               # Page components (routes)
├── services/            # API services & utilities
├── contexts/            # React Context providers
├── hooks/               # Custom React hooks
├── layout/              # Layout components
├── assets/              # Static assets (images, fonts)
├── App.tsx              # Main app component
├── main.tsx             # App entry point
└── index.css            # Global styles
```

---

## 📦 Folder Breakdown

### 🧩 **`components/`** - Reusable Components
**Purpose:** Shared UI components used across multiple pages

**Structure:**
```
components/
├── Navbar.tsx           # Navigation bar
├── Sidebar.tsx          # Side navigation
├── ProductCard.tsx      # Product display card
├── StockChart.tsx       # Stock level charts
├── TrendGraph.tsx       # Trend visualization
├── LoadingSpinner.tsx   # Loading indicator
├── Modal.tsx            # Modal dialogs
├── Button.tsx           # Custom button
├── Input.tsx            # Form inputs
└── ...
```

**Best Practices:**
- ✅ Small, focused components
- ✅ TypeScript interfaces for props
- ✅ Reusable across pages
- ✅ Styled with TailwindCSS

**Example Component:**
```tsx
interface ProductCardProps {
  name: string;
  price: number;
  stock: number;
  image: string;
}

export const ProductCard: React.FC<ProductCardProps> = ({ 
  name, price, stock, image 
}) => {
  return (
    <div className="border rounded-lg p-4">
      <img src={image} alt={name} />
      <h3>{name}</h3>
      <p>${price}</p>
      <span>Stock: {stock}</span>
    </div>
  );
};
```

---

### 📄 **`pages/`** - Page Components
**Purpose:** Full page components mapped to routes

**Structure:**
```
pages/
├── Login.tsx            # Login page
├── Signup.tsx           # Registration page
├── Dashboard.tsx        # Main dashboard
├── Products.tsx         # Product list
├── ProductDetail.tsx    # Product details
├── Inventory.tsx        # Inventory management
├── Trends.tsx           # Market trends
├── AIAssistant.tsx      # AI chat interface
├── Profile.tsx          # User profile
├── Settings.tsx         # App settings
└── NotFound.tsx         # 404 page
```

**Routing:**
```tsx
// App.tsx
<Routes>
  <Route path="/login" element={<Login />} />
  <Route path="/signup" element={<Signup />} />
  <Route path="/dashboard" element={<Dashboard />} />
  <Route path="/products" element={<Products />} />
  <Route path="/products/:id" element={<ProductDetail />} />
  <Route path="/inventory" element={<Inventory />} />
  <Route path="/trends" element={<Trends />} />
  <Route path="/ai" element={<AIAssistant />} />
  <Route path="/profile" element={<Profile />} />
  <Route path="*" element={<NotFound />} />
</Routes>
```

---

### 🔌 **`services/`** - API Services
**Purpose:** API communication and business logic

**Structure:**
```
services/
├── api.ts               # Axios instance & interceptors
├── authService.ts       # Authentication API calls
├── productService.ts    # Product API calls
├── inventoryService.ts  # Inventory API calls
├── trendsService.ts     # Trends API calls
└── aiService.ts         # AI assistant API calls
```

**API Configuration:**
```tsx
// api.ts
import axios from "axios";

const api = axios.create({
  baseURL: "http://127.0.0.1:8000/api/",
  withCredentials: true,
});

// Request interceptor - attach JWT token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem("access");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor - handle token refresh
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      // Refresh token logic
    }
    return Promise.reject(error);
  }
);

export default api;
```

**Service Example:**
```tsx
// productService.ts
import api from "./api";

export const getProducts = async () => {
  const response = await api.get("/products/");
  return response.data;
};

export const getProductById = async (id: number) => {
  const response = await api.get(`/products/${id}/`);
  return response.data;
};

export const updateProduct = async (id: number, data: any) => {
  const response = await api.put(`/products/${id}/`, data);
  return response.data;
};
```

---

### 🎣 **`hooks/`** - Custom React Hooks
**Purpose:** Reusable stateful logic

**Structure:**
```
hooks/
├── useAuth.ts           # Authentication hook
├── useProducts.ts       # Product data hook
├── useInventory.ts      # Inventory data hook
└── useDebounce.ts       # Debounce utility hook
```

**Example Hook:**
```tsx
// useAuth.ts
export const useAuth = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const userData = await api.get("/user/");
        setUser(userData.data);
      } catch (error) {
        setUser(null);
      } finally {
        setLoading(false);
      }
    };
    fetchUser();
  }, []);

  return { user, loading };
};
```

---

### 🌐 **`contexts/`** - React Context
**Purpose:** Global state management

**Structure:**
```
contexts/
└── AuthContext.tsx      # Authentication context
```

**Example Context:**
```tsx
// AuthContext.tsx
interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);

  const login = async (email: string, password: string) => {
    const response = await api.post("/token/", { email, password });
    localStorage.setItem("access", response.data.access);
    localStorage.setItem("refresh", response.data.refresh);
    setUser(response.data.user);
  };

  const logout = () => {
    localStorage.removeItem("access");
    localStorage.removeItem("refresh");
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, isAuthenticated: !!user }}>
      {children}
    </AuthContext.Provider>
  );
};
```

---

### 🏗️ **`layout/`** - Layout Components
**Purpose:** Page layout wrappers

**Structure:**
```
layout/
└── MainLayout.tsx       # Main app layout with navbar/sidebar
```

**Example Layout:**
```tsx
// MainLayout.tsx
export const MainLayout: React.FC<{ children: ReactNode }> = ({ children }) => {
  return (
    <div className="flex h-screen">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Navbar />
        <main className="flex-1 overflow-auto p-6">
          {children}
        </main>
      </div>
    </div>
  );
};
```

---

### 🎨 **`assets/`** - Static Assets
**Purpose:** Images, fonts, and static files

**Structure:**
```
assets/
├── images/
│   ├── logo.png
│   ├── toplogo.png
│   └── signuplogo.png
├── fonts/
└── icons/
```

---

## 🚀 Getting Started

### Prerequisites
- Node.js 18+
- npm or yarn
- Backend API running

### Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure API URL:**
   Edit `src/services/api.ts`:
   ```typescript
   const api = axios.create({
     baseURL: "http://127.0.0.1:8000/api/",
   });
   ```

3. **Run development server:**
   ```bash
   npm run dev
   ```

4. **Open browser:**
   Navigate to `http://localhost:5174`

---

## 📜 Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run preview` | Preview production build |
| `npm run lint` | Run ESLint |

---

## 🔑 Key Features

- ✅ **JWT Authentication** - Secure token-based auth
- ✅ **Auto Token Refresh** - Seamless session management
- ✅ **Responsive Design** - Mobile-first approach
- ✅ **Type Safety** - Full TypeScript coverage
- ✅ **Modern UI** - TailwindCSS styling
- ✅ **Fast Development** - Vite HMR
- ✅ **Protected Routes** - Auth-based routing
- ✅ **Error Handling** - Graceful error management

---

## 🎨 Styling

### TailwindCSS
Utility-first CSS framework for rapid UI development.

**Configuration:**
```js
// tailwind.config.js
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: "#3B82F6",
        secondary: "#8B5CF6",
      },
    },
  },
  plugins: [],
};
```

**Usage:**
```tsx
<button className="bg-blue-500 text-white px-4 py-2 rounded-full hover:bg-blue-700">
  Click Me
</button>
```

---

## 🔐 Authentication Flow

1. **Login:**
   - User submits credentials
   - Backend returns JWT tokens
   - Tokens stored in `localStorage`
   - User redirected to dashboard

2. **Protected Routes:**
   - Check for valid token
   - Redirect to login if not authenticated

3. **Token Refresh:**
   - Intercept 401 responses
   - Automatically refresh access token
   - Retry failed request

4. **Logout:**
   - Clear tokens from storage
   - Redirect to login page

---

## 📡 API Integration

### Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/register/` | POST | User registration |
| `/token/` | POST | Login & get tokens |
| `/token/refresh/` | POST | Refresh access token |
| `/user/` | GET | Get current user |
| `/products/` | GET | List products |
| `/products/{id}/` | GET | Get product details |
| `/stock/history/` | GET | Get stock history |
| `/trends/` | GET | Get market trends |
| `/ai/chat/` | POST | Chat with AI |

---

## 🧪 Testing

### Run Tests
```bash
npm run test
```

### Test Structure
```
tests/
├── components/          # Component tests
├── pages/               # Page tests
└── services/            # Service tests
```

---

## 🏗️ Architecture Pattern

**Pattern:** Component-Based Architecture
- **Pages** - Route-level components
- **Components** - Reusable UI pieces
- **Services** - API communication
- **Hooks** - Reusable logic
- **Contexts** - Global state

**Data Flow:**
```
User Action → Component → Service → API → Backend
                ↓
            State Update
                ↓
            UI Re-render
```

---

## 📦 Dependencies

### Core
- `react` - UI library
- `react-dom` - React DOM renderer
- `react-router-dom` - Routing
- `typescript` - Type safety

### Utilities
- `axios` - HTTP client
- `lucide-react` - Icons
- `tailwindcss` - Styling

### Dev Dependencies
- `vite` - Build tool
- `eslint` - Linting
- `@types/*` - TypeScript definitions

---

## 🔧 Configuration Files

### `vite.config.js`
Vite configuration for build and dev server

### `tsconfig.json`
TypeScript compiler options

### `tailwind.config.js`
TailwindCSS customization

### `eslint.config.js`
ESLint rules and plugins

---

## 🐛 Common Issues

### 1. CORS Errors
**Solution:** Ensure backend has CORS enabled for frontend URL

### 2. Token Expiration
**Solution:** Implement token refresh in `api.ts` interceptor

### 3. Build Errors
**Solution:** Clear `node_modules` and reinstall
```bash
rm -rf node_modules package-lock.json
npm install
```

---

## 📈 Performance Optimization

- ✅ **Code Splitting** - React.lazy() for route-based splitting
- ✅ **Image Optimization** - Compressed images
- ✅ **Lazy Loading** - Load components on demand
- ✅ **Memoization** - useMemo, useCallback for expensive operations
- ✅ **Tree Shaking** - Vite removes unused code


StockWise Development Team
