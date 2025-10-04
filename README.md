# StockWises

**Generated on:** 10/3/2025

---

## Overview

StockWises is a full-stack inventory management system designed to help businesses efficiently track and manage their stock products and user accounts. The project combines a Django backend with a React frontend, providing a seamless and interactive user experience.

---

## Project Structure

StockWises/
├── apps/
│ ├── inventory/ # Inventory management app (models, views, serializers, migrations)
│ └── users/ # User authentication and profile management
├── core/ # Core Django project configuration and settings
├── frontend/ # React frontend application
├── media/ # Media files including product images and profile pictures
├── manage.py # Django project management script
├── requirements.txt # Python dependencies
├── db.sqlite3 # SQLite database file
├── .env # Environment variables (hidden)
├── README.md # This file

yaml
Copy code

---

## Backend (Django)

### Apps

- **Inventory**  
  Handles stock products, transactions, and related inventory logic.  
  - Models: Product, StockTransaction, InventoryProduct, etc.  
  - Migrations for schema changes  
  - API views and serializers for data exchange  
  - Tests for reliability

- **Users**  
  Manages user authentication, permissions, and profiles.  
  - Supports login, signup, password reset workflows  
  - Firebase integration for authentication  
  - Permissions and signals for user events  
  - HTML templates for login page

### Core

- Django project setup including settings, URL routing, and WSGI/ASGI configurations.

---

## Frontend (React + TypeScript)

- Located in `frontend/src/`
- Uses React with TypeScript and Tailwind CSS for styling
- Organized into:
  - **components**: Reusable UI elements (buttons, cards, modals, forms)
  - **pages**: Individual pages like Dashboard, Inventory, Login, Signup, Profile, AI Assistant, Password Reset flows
  - **contexts**: Theme context for light/dark mode support
  - **hooks**: Custom React hooks (e.g. `useScrollDirection`)
  - **services**: API and auth service utilities for interacting with the backend
- Assets and media files (logos, icons, images) stored under `assets` and `public/media`
- Built with Vite for fast development and bundling

---

## Media

- Product images and user profile pictures are stored under the `media/` directory and organized into subfolders.
- Supports uploading and displaying media files in the app.

---

## Installation

### Backend

1. Clone the repository  
   ```bash
   git clone <repo-url>
   cd StockWises
Create and activate a Python virtual environment

bash
Copy code
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
Install dependencies

bash
Copy code
pip install -r requirements.txt
Apply migrations

bash
Copy code
python manage.py migrate
Run the development server

bash
Copy code
python manage.py runserver
Frontend
Navigate to the frontend directory

bash
Copy code
cd frontend
Install npm dependencies

bash
Copy code
npm install
Start the frontend development server

bash
Copy code
npm run dev
Usage
Access the frontend via http://localhost:3000 (or the port provided by Vite)

The backend API runs on http://localhost:8000

Users can sign up, log in, and manage their profiles

Inventory can be managed with stock products, transactions, and viewing history

The AI Assistant page provides additional AI-driven support features

Testing
Backend tests are located in each app's tests.py or tests/ directories

Run backend tests using Django's test runner

bash
Copy code
python manage.py test
Additional Notes
Environment variables and sensitive keys should be configured in the .env file (not included in the repo)

Firebase is used for authentication in the users app

Tailwind CSS setup instructions can be found in frontend/TAILWIND_SETUP.md

Frontend uses TypeScript, ensure your editor supports it for the best development experience