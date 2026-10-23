/**
 * Validation Module for EventCraft AI.
 * Enforces strict input validation to prevent invalid API calls and ensure data integrity.
 * @module validation
 */

/**
 * Validates the event input data before submission or AI generation.
 * Enforces budget > 0, guest count > 0, and non-blank required fields.
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
export function validateEventInput(eventData) {
  const errors = [];

  if (!eventData || typeof eventData !== 'object') {
    return {
      isValid: false,
      errors: ['Event details are required.'],
    };
  }

  // Required: Event Title
  if (!eventData.title || typeof eventData.title !== 'string' || eventData.title.trim() === '') {
    errors.push('Event title is required and cannot be blank.');
  }

  // Required: Event Category / Vertical
  if (!eventData.eventType || typeof eventData.eventType !== 'string' || eventData.eventType.trim() === '') {
    errors.push('Event category is required.');
  }

  // Required: Event Date
  if (!eventData.eventDate || typeof eventData.eventDate !== 'string' || eventData.eventDate.trim() === '') {
    errors.push('Event date is required.');
  }

  // Required: Guest Count > 0
  const guests = Number(eventData.guestCount);
  if (isNaN(guests) || guests <= 0) {
    errors.push('Guest count must be greater than zero.');
  }

  // Required: Budget > 0 (prevents 0 or negative budgets)
  const budget = Number(eventData.totalBudget);
  if (isNaN(budget) || budget <= 0) {
    errors.push('Total budget must be a positive number greater than zero.');
  }

  // Required: City / Region
  if (!eventData.city || typeof eventData.city !== 'string' || eventData.city.trim() === '') {
    errors.push('City or region is required.');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
}
