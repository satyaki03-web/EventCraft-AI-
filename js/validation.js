/**
 * Validation Module for EventCraft AI.
 * Wrapped in an IIFE to prevent global namespace pollution.
 * Enforces strict boundary validations explicitly blocking past dates and budgets <= 0.
 * @module validation
 */

const ValidationModule = (() => {
  'use strict';

  /**
   * Top-level CONSTANTS object for validation boundaries and messages.
   * @readonly
   * @type {object}
   */
  const CONSTANTS = Object.freeze({
    MIN_BUDGET_BOUNDARY: 0,
    MIN_GUESTS_BOUNDARY: 0,
    ERROR_MISSING_DETAILS: 'Event details are required.',
    ERROR_MISSING_TITLE: 'Event title is required and cannot be blank.',
    ERROR_MISSING_CATEGORY: 'Event category is required.',
    ERROR_MISSING_DATE: 'Event date is required.',
    ERROR_PAST_DATE: 'Event date cannot be in the past.',
    ERROR_INVALID_GUESTS: 'Guest count must be greater than zero.',
    ERROR_INVALID_BUDGET: 'Total budget must be a positive number greater than zero.',
    ERROR_MISSING_CITY: 'City or region is required.',
  });

  /**
   * Validates if a date string represents a past date relative to today.
   *
   * @param {string} dateStr - Date string formatted as YYYY-MM-DD or standard date format.
   * @returns {boolean} True if date is strictly before today's start of day, false otherwise.
   */
  function isPastDate(dateStr) {
    if (!dateStr || typeof dateStr !== 'string') {
      return false;
    }
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const parts = dateStr.split('-').map(Number);
    if (parts.length === 3 && !isNaN(parts[0]) && !isNaN(parts[1]) && !isNaN(parts[2])) {
      const candidate = new Date(parts[0], parts[1] - 1, parts[2], 0, 0, 0, 0);
      return candidate.getTime() < today.getTime();
    }

    const parsed = new Date(dateStr);
    if (!isNaN(parsed.getTime())) {
      parsed.setHours(0, 0, 0, 0);
      return parsed.getTime() < today.getTime();
    }

    return false;
  }

  /**
   * Validates the event input data with strict boundary checks.
   * Explicitly blocks budgets <= 0, past dates, and blank required fields.
   *
   * @param {object} eventData - The event details submitted by the user.
   * @param {string} [eventData.title] - The title or name of the event.
   * @param {string} [eventData.eventType] - The vertical category (e.g., 'wedding', 'birthday', 'community').
   * @param {string} [eventData.eventDate] - The ISO or date string for the event.
   * @param {number} [eventData.guestCount] - The estimated number of guests.
   * @param {number} [eventData.totalBudget] - The total allocated budget.
   * @param {string} [eventData.city] - The city or location where the event takes place.
   * @returns {{ isValid: boolean, errors: string[] }} An object indicating validity and a list of human-readable error messages.
   */
  function validateEventInput(eventData) {
    const errors = [];

    if (!eventData || typeof eventData !== 'object') {
      return {
        isValid: false,
        errors: [CONSTANTS.ERROR_MISSING_DETAILS],
      };
    }

    // Required: Event Title
    if (!eventData.title || typeof eventData.title !== 'string' || eventData.title.trim() === '') {
      errors.push(CONSTANTS.ERROR_MISSING_TITLE);
    }

    // Required: Event Category / Vertical
    if (!eventData.eventType || typeof eventData.eventType !== 'string' || eventData.eventType.trim() === '') {
      errors.push(CONSTANTS.ERROR_MISSING_CATEGORY);
    }

    // Required: Event Date and Boundary: explicitly block past dates
    if (!eventData.eventDate || typeof eventData.eventDate !== 'string' || eventData.eventDate.trim() === '') {
      errors.push(CONSTANTS.ERROR_MISSING_DATE);
    } else if (isPastDate(eventData.eventDate)) {
      errors.push(CONSTANTS.ERROR_PAST_DATE);
    }

    // Boundary: Guest Count > 0
    const guests = Number(eventData.guestCount);
    if (isNaN(guests) || guests <= CONSTANTS.MIN_GUESTS_BOUNDARY) {
      errors.push(CONSTANTS.ERROR_INVALID_GUESTS);
    }

    // Strict Boundary: Budget > 0 (explicitly blocks <= 0)
    const budget = Number(eventData.totalBudget);
    if (isNaN(budget) || budget <= CONSTANTS.MIN_BUDGET_BOUNDARY) {
      errors.push(CONSTANTS.ERROR_INVALID_BUDGET);
    }

    // Required: City / Region
    if (!eventData.city || typeof eventData.city !== 'string' || eventData.city.trim() === '') {
      errors.push(CONSTANTS.ERROR_MISSING_CITY);
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }

  return {
    CONSTANTS,
    isPastDate,
    validateEventInput,
  };
})();

export const { CONSTANTS, isPastDate, validateEventInput } = ValidationModule;
export default validateEventInput;
