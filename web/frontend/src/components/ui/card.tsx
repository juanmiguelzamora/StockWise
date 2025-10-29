import React from "react";
import type { ReactNode, HTMLAttributes } from "react";

type CardVariant = "default" | "elevated" | "outlined" | "filled";

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  children: ReactNode;
  variant?: CardVariant;
  className?: string;
}

const Card: React.FC<CardProps> & {
  Header: React.FC<CardSectionProps>;
  Body: React.FC<CardSectionProps>;
  Footer: React.FC<CardSectionProps>;
} = ({ children, variant = "default", className = "", ...props }) => {
  const baseClasses = "rounded-xl shadow-sm transition-all duration-200";

  const variants: Record<CardVariant, string> = {
    default: "bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700",
    elevated: "bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl border border-gray-200 dark:border-gray-700",
    outlined: "bg-transparent border-2 border-gray-200 dark:border-gray-700",
    filled: "bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700",
  };

  const classes = `${baseClasses} ${variants[variant]} ${className}`;

  return (
    <div className={classes} {...props}>
      {children}
    </div>
  );
};

interface CardSectionProps extends HTMLAttributes<HTMLDivElement> {
  children: ReactNode;
  className?: string;
}

const CardHeader: React.FC<CardSectionProps> = ({ children, className = "", ...props }) => (
  <div className={`px-6 py-4 border-b border-gray-200 dark:border-gray-700 ${className}`} {...props}>
    {children}
  </div>
);

const CardBody: React.FC<CardSectionProps> = ({ children, className = "", ...props }) => (
  <div className={`px-6 py-4 ${className}`} {...props}>
    {children}
  </div>
);

const CardFooter: React.FC<CardSectionProps> = ({ children, className = "", ...props }) => (
  <div className={`px-6 py-4 border-t border-gray-200 dark:border-gray-700 ${className}`} {...props}>
    {children}
  </div>
);

// Attach subcomponents
Card.Header = CardHeader;
Card.Body = CardBody;
Card.Footer = CardFooter;

export default Card;
