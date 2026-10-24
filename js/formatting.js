/**
 * Formatting and Sanitization Module for EventCraft AI.
 * Wrapped in an IIFE to prevent global namespace pollution.
 * Centralizes all formatting constants and guarantees safe XSS sanitization.
 * @module formatting
 */

const FormattingModule = (() => {
  'use strict';

  /**
   * Top-level CONSTANTS object for formatting and sanitization defaults.
   * @readonly
   * @type {object}
   */
  const CONSTANTS = Object.freeze({
    DEFAULT_CURRENCY_SYMBOL: '₹',
    EMPTY_AMOUNT_FALLBACK: '0',
    DATE_PAD_LENGTH: 2,
    DATE_PAD_CHAR: '0',
    DATE_SEPARATOR: '-',
    EMPTY_STRING: '',
    AMP_REGEX: /&/g,
    LT_REGEX: /</g,
    GT_REGEX: />/g,
    QUOTE_REGEX: /"/g,
    APOS_REGEX: /'/g,
    AMP_ENTITY: '&amp;',
    LT_ENTITY: '&lt;',
    GT_ENTITY: '&gt;',
    QUOTE_ENTITY: '&quot;',
    APOS_ENTITY: '&#39;',
  });

  /**
   * Formats a numeric amount with the given currency symbol and locale-aware commas.
   *
   * @param {number|string} amount - The numeric monetary amount to format.
   * @param {string} [currencySymbol=CONSTANTS.DEFAULT_CURRENCY_SYMBOL] - The prefix currency symbol.
   * @returns {string} The formatted currency string (e.g., '₹15,00,000').
   */
  function formatCurrency(amount, currencySymbol = CONSTANTS.DEFAULT_CURRENCY_SYMBOL) {
    const numericValue = Number(amount);
    if (isNaN(numericValue)) {
      return `${currencySymbol}${CONSTANTS.EMPTY_AMOUNT_FALLBACK}`;
    }
    return `${currencySymbol}${Math.round(numericValue).toLocaleString()}`;
  }

  /**
   * Formats a Date instance or date string into a standardized YYYY-MM-DD format.
   *
   * @param {Date|string} dateInput - The Date object or date string to format.
   * @returns {string} The formatted ISO-style date string (YYYY-MM-DD).
   */
  function formatDate(dateInput) {
    const dateObj = typeof dateInput === 'string' ? new Date(dateInput) : dateInput;
    if (!dateObj || isNaN(dateObj.getTime())) {
      return CONSTANTS.EMPTY_STRING;
    }
    const year = dateObj.getFullYear();
    const month = String(dateObj.getMonth() + 1).padStart(CONSTANTS.DATE_PAD_LENGTH, CONSTANTS.DATE_PAD_CHAR);
    const day = String(dateObj.getDate()).padStart(CONSTANTS.DATE_PAD_LENGTH, CONSTANTS.DATE_PAD_CHAR);
    return `${year}${CONSTANTS.DATE_SEPARATOR}${month}${CONSTANTS.DATE_SEPARATOR}${day}`;
  }

  /**
   * Strips or safely escapes HTML special characters to prevent Cross-Site Scripting (XSS).
   *
   * @param {string} rawString - The untrusted raw string to sanitize.
   * @returns {string} The safe, sanitized plain text representation.
   */
  function sanitizeText(rawString) {
    if (typeof rawString !== 'string') {
      return rawString === null || rawString === undefined ? CONSTANTS.EMPTY_STRING : String(rawString);
    }
    return rawString
      .replace(CONSTANTS.AMP_REGEX, CONSTANTS.AMP_ENTITY)
      .replace(CONSTANTS.LT_REGEX, CONSTANTS.LT_ENTITY)
      .replace(CONSTANTS.GT_REGEX, CONSTANTS.GT_ENTITY)
      .replace(CONSTANTS.QUOTE_REGEX, CONSTANTS.QUOTE_ENTITY)
      .replace(CONSTANTS.APOS_REGEX, CONSTANTS.APOS_ENTITY);
  }

  return {
    CONSTANTS,
    formatCurrency,
    formatDate,
    sanitizeText,
  };
})();

export const { CONSTANTS, formatCurrency, formatDate, sanitizeText } = FormattingModule;
export default FormattingModule;
