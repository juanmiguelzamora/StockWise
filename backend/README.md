# StockWise Backend - Django REST API

A comprehensive Django REST Framework backend for inventory management, trend analysis, and AI-powered assistance.

## 📁 Project Structure

```
backend/
├── auth_app/              # User authentication & authorization
├── product_app/           # Product & inventory management
├── trend_app/             # Market trends & predictions
├── ai_assistant/          # AI-powered chat assistant
├── backend/               # Django project settings
├── script/                # Utility scripts
├── templates/             # Email templates
├── utils/                 # Shared utilities
├── media/                 # User-uploaded files
├── documentation/         # API documentation
├── manage.py              # Django management script
├── requirements.txt       # Python dependencies
└── .env                   # Environment variables
```

---

## 📦 App Modules

### 🔐 **`auth_app/`** - Authentication & User Management
**Purpose:** Handles user registration, login, JWT tokens, and password reset

**Key Files:**
- **`models.py`** - Custom User model with email as username
- **`serializers.py`** - User registration & serialization
- **`views.py`** - Registration, login, user detail endpoints
- **`signals.py`** - Post-registration signals
- **`admin.py`** - Django admin configuration

**Endpoints:**
- `POST /api/register/` - User registration
- `POST /api/token/` - JWT token obtain
- `POST /api/token/refresh/` - Refresh JWT token
- `GET /api/user/` - Get current user details
- `GET /api/users/` - List all users (admin)
- `POST /api/password_reset/` - Request password reset

**Features:**
- Custom User model with email authentication
- JWT token-based authentication
- Password reset via email
- User profile management

---

### 📦 **`product_app/`** - Product & Inventory Management
**Purpose:** Manages products, inventory tracking, stock history, and web scraping

**Key Files:**
- **`models.py`** - Product, Category, StockHistory, ScraperConfig models
- **`serializers.py`** - Product & inventory serialization
- **`views.py`** - CRUD operations for products
- **`scraper_sites.py`** - Web scraping logic for product data
- **`tasks.py`** - Background tasks (Celery)
- **`signals.py`** - Auto-create stock history on product changes
- **`utils.py`** - Helper functions

**Endpoints:**
- `GET /api/products/` - List all products
- `POST /api/products/` - Create new product
- `GET /api/products/{id}/` - Get product details
- `PUT /api/products/{id}/` - Update product
- `DELETE /api/products/{id}/` - Delete product
- `GET /api/stock/history/` - Get stock history

**Features:**
- Product CRUD operations
- Category management
- Stock level tracking
- Automatic stock history logging
- Web scraping for product data
- Image upload support

---

### 📈 **`trend_app/`** - Market Trends & Predictions
**Purpose:** Analyzes market trends and provides demand predictions using ML

**Key Files:**
- **`models.py`** - Trend, Prediction models
- **`serializers.py`** - Trend data serialization
- **`views.py`** - Trend analysis endpoints
- **`urls.py`** - Trend-related routes

**Endpoints:**
- `GET /api/trends/` - Get market trends
- `GET /api/predictions/` - Get demand predictions
- `POST /api/scraper/run/` - Trigger web scraper

**Features:**
- Market trend analysis
- Demand forecasting
- Historical trend data
- Integration with web scraping

---

### 🤖 **`ai_assistant/`** - AI Chat Assistant
**Purpose:** Provides AI-powered conversational assistance for inventory queries

**Key Files:**
- **`models.py`** - Conversation, Message models
- **`views.py`** - Chat endpoints
- **`urls.py`** - AI assistant routes

**Endpoints:**
- `POST /api/ai/chat/` - Send message to AI assistant
- `GET /api/ai/conversations/` - Get conversation history

**Features:**
- Conversational AI interface
- Context-aware responses
- Conversation history tracking
- Integration with inventory data

---

### ⚙️ **`backend/`** - Django Project Configuration
**Purpose:** Core Django settings and configuration

**Key Files:**
- **`settings.py`** - Django settings (database, middleware, apps)
- **`urls.py`** - Root URL configuration
- **`wsgi.py`** - WSGI application entry point
- **`asgi.py`** - ASGI application entry point

**Configuration:**
- Database: PostgreSQL/SQLite
- Authentication: JWT (SimpleJWT)
- CORS enabled for frontend
- Media file handling
- REST Framework settings

---

### 📜 **`script/`** - Utility Scripts
**Purpose:** Helper scripts for data management and automation

**Contents:**
- Database seeding scripts
- Data migration utilities
- Automation scripts

---

### 📧 **`templates/`** - Email Templates
**Purpose:** HTML templates for email notifications

**Contents:**
- Password reset emails
- Welcome emails
- Notification templates

---

### 🛠️ **`utils/`** - Shared Utilities
**Purpose:** Reusable helper functions across apps

**Contents:**
- Common validators
- Helper functions
- Shared constants

---

### 📁 **`media/`** - User Uploads
**Purpose:** Stores user-uploaded files (product images, etc.)

**Structure:**
```
media/
└── products/          # Product images
```

---

### 📚 **`documentation/`** - API Documentation
**Purpose:** API documentation and guides

**Contents:**
- API endpoint documentation
- Setup guides
- Architecture diagrams

---

## 🚀 Getting Started

### Prerequisites
- Python 3.10+
- PostgreSQL (optional, SQLite for development)
- Virtual environment

### Installation

1. **Create virtual environment:**
   ```bash
   python -m venv venv
   ```

2. **Activate virtual environment:**
   ```bash
   # Windows
   .\venv\Scripts\activate
   
   # Linux/Mac
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment variables:**
   Create `.env` file with:
   ```env
   SECRET_KEY=your-secret-key
   DEBUG=True
   DATABASE_URL=your-database-url
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_HOST_USER=your-email
   EMAIL_HOST_PASSWORD=your-password
   ```

5. **Run migrations:**
   ```bash
   python manage.py migrate
   ```

6. **Create superuser:**
   ```bash
   python manage.py createsuperuser
   ```

7. **Run development server:**
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

---

## 🔑 Key Features

- ✅ **JWT Authentication** - Secure token-based auth
- ✅ **RESTful API** - Clean, consistent API design
- ✅ **Product Management** - Full CRUD operations
- ✅ **Inventory Tracking** - Real-time stock monitoring
- ✅ **Trend Analysis** - Market insights & predictions
- ✅ **AI Assistant** - Conversational inventory help
- ✅ **Web Scraping** - Automated product data collection
- ✅ **Password Reset** - Email-based password recovery
- ✅ **Admin Panel** - Django admin for management

---

## 📡 API Endpoints

### Authentication
- `POST /api/register/` - Register new user
- `POST /api/token/` - Login & get JWT tokens
- `POST /api/token/refresh/` - Refresh access token
- `GET /api/user/` - Get current user

### Products
- `GET /api/products/` - List products
- `POST /api/products/` - Create product
- `GET /api/products/{id}/` - Get product
- `PUT /api/products/{id}/` - Update product
- `DELETE /api/products/{id}/` - Delete product

### Inventory
- `GET /api/stock/history/` - Get stock history

### Trends
- `GET /api/trends/` - Get market trends
- `GET /api/predictions/` - Get predictions

### AI Assistant
- `POST /api/ai/chat/` - Chat with AI

---

## 🧪 Testing

Run tests:
```bash
python manage.py test
```

---

## 📝 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SECRET_KEY` | Django secret key | Yes |
| `DEBUG` | Debug mode | Yes |
| `DATABASE_URL` | Database connection | No |
| `EMAIL_HOST` | SMTP host | Yes |
| `EMAIL_PORT` | SMTP port | Yes |
| `EMAIL_HOST_USER` | Email username | Yes |
| `EMAIL_HOST_PASSWORD` | Email password | Yes |

---

## 🏗️ Architecture

**Pattern:** Layered Architecture
- **Models** - Data layer (ORM)
- **Serializers** - Data transformation
- **Views** - Business logic & API endpoints
- **URLs** - Route configuration

**Database:** PostgreSQL/SQLite
**API Framework:** Django REST Framework
**Authentication:** JWT (SimpleJWT)

---

## 📦 Dependencies

Key packages:
- `Django` - Web framework
- `djangorestframework` - REST API
- `djangorestframework-simplejwt` - JWT auth
- `django-cors-headers` - CORS support
- `Pillow` - Image processing
- `requests` - HTTP client
- `beautifulsoup4` - Web scraping


StockWise Development Team
