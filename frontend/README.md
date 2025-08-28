# StockWises Frontend

A modern React-based frontend application for StockWises, featuring authentication, responsive design, and a clean user interface.

## Features

- 🔐 **Firebase Authentication**
  - User login and signup
  - Password reset functionality
  - Protected routes
  - Secure token management

- 🎨 **Modern UI/UX**
  - Responsive design with Tailwind CSS
  - Dark/light mode support
  - Clean and intuitive interface
  - Loading states and error handling

- 🚀 **React 19 + Vite**
  - Fast development and build times
  - Modern React features
  - Optimized production builds

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn

### Installation

1. Install dependencies:
```bash
npm install
```

2. Start development server:
```bash
npm run dev
```

3. Build for production:
```bash
npm run build
```

## Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── layout/         # Layout components
│   └── ui/            # Basic UI components
├── contexts/           # React contexts
├── firebase.js         # Firebase configuration
├── App.jsx            # Main application component
├── Login.jsx          # Login page
├── Signup.jsx         # Signup page
├── Protected.jsx      # Protected dashboard
├── ResetRequest.jsx   # Password reset request
└── ResetPassword.jsx  # Password reset confirmation
```

## Authentication Flow

1. **Login**: Users can sign in with email/password
2. **Signup**: New users can create accounts
3. **Password Reset**: Users can request password reset emails
4. **Protected Routes**: Authenticated users access protected content
5. **Token Management**: Automatic token refresh and API calls

## Styling

- **Tailwind CSS**: Utility-first CSS framework
- **Custom Components**: Reusable component classes
- **Responsive Design**: Mobile-first approach
- **Dark Mode**: Automatic theme switching

## API Integration

The frontend integrates with the Django backend API:
- Protected endpoint: `http://127.0.0.1:8000/protected/`
- Firebase ID tokens for authentication
- Error handling and loading states

## Development

### Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

### Code Style

- ESLint configuration for code quality
- Consistent component structure
- Proper error handling
- Loading states for better UX

## Deployment

The application builds to the `dist/` folder and can be deployed to any static hosting service:

- Vercel
- Netlify
- AWS S3
- GitHub Pages

## Troubleshooting

### Common Issues

1. **Tailwind classes not working**: Ensure PostCSS is configured correctly
2. **Firebase errors**: Check Firebase configuration in `firebase.js`
3. **Build failures**: Clear `node_modules` and reinstall dependencies

### Environment Variables

Create a `.env` file for environment-specific configuration:

```env
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_domain
VITE_FIREBASE_PROJECT_ID=your_project_id
```

## Contributing

1. Follow the existing code style
2. Add proper error handling
3. Include loading states
4. Test responsive design
5. Update documentation

## License

This project is part of the StockWises application suite.
