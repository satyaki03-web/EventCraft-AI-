/**
 * Formatting and Sanitization Module for EventCraft AI.
 * Handles numbers, dates, currency strings, and text sanitization against XSS.
 * @module formatting
 */

/**
 * Formats a numeric amount with the given currency symbol and locale-aware commas.
 *
 * @param {number|string} amount - The numeric monetary amount to format.
 * @param {string} [currencySymbol='₹'] - The prefix currency symbol.
 * @returns {string} The formatted currency string (e.g., '₹15,00,000').
 */
export function formatCurrency(amount, currencySymbol = '₹') {
  const numericValue = Number(amount);
  if (isNaN(numericValue)) {
    return `${currencySymbol}0`;
  }
  return `${currencySymbol}${Math.round(numericValue).toLocaleString()}`;
}

/**
 * Formats a Date instance or date string into a standardized YYYY-MM-DD format.
 *
 * @param {Date|string} dateInput - The Date object or date string to format.
 * @returns {string} The formatted ISO-style date string (YYYY-MM-DD).
 */
export function formatDate(dateInput) {
  const dateObj = typeof dateInput === 'string' ? new Date(dateInput) : dateInput;
  if (!dateObj || isNaN(dateObj.getTime())) {
    return '';
  }
  const year = dateObj.getFullYear();
  const month = String(dateObj.getMonth() + 1).padStart(2, '0');
  const day = String(dateObj.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * Strips or safely escapes HTML special characters to prevent Cross-Site Scripting (XSS).
 *
 * @param {string} rawString - The untrusted raw string to sanitize.
 * @returns {string} The safe, sanitized plain text representation.
 */
export function sanitizeText(rawString) {
  if (typeof rawString !== 'string') {
    return rawString === null || rawString === undefined ? '' : String(rawString);
  }
  return rawString
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}
