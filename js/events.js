/**
 * Event Listeners and Form Handling Module for EventCraft AI.
 * Coordinates input validation, submit interception, and UI feedback loops.
 * @module events
 */

import { validateEventInput } from './validation.js';
import { generateEvent } from './api.js';
import {
  renderValidationWarning,
  clearValidationWarning,
  renderErrorCard,
  DEFAULT_ERROR_CARD_MESSAGE,
} from './ui.js';

/**
 * Extracts form field values into a structured event data object.
 *
 * @param {HTMLFormElement} formEl - The form element containing event inputs.
 * @returns {object} The extracted event input payload.
 */
export function extractFormData(formEl) {
  if (!formEl || !(formEl instanceof HTMLFormElement)) {
    return {};
  }

  const formData = new FormData(formEl);
  return {
    title: String(formData.get('title') || '').trim(),
    eventType: String(formData.get('eventType') || '').trim(),
    eventDate: String(formData.get('eventDate') || '').trim(),
    guestCount: parseInt(String(formData.get('guestCount') || '0'), 10),
    totalBudget: parseFloat(String(formData.get('totalBudget') || '0')),
    city: String(formData.get('city') || '').trim(),
    themePreference: String(formData.get('themePreference') || '').trim(),
    isOutdoor: formEl.querySelector('#isOutdoor')?.matches(':checked') || false,
  };
}

/**
 * Handles the event form submission with strict client-side validation.
 * Prevents API calls if budget <= 0 or required fields are blank,
 * rendering a visual warning alert in the UI.
 *
 * @param {SubmitEvent|Event} evt - The form submission event.
 * @returns {Promise<boolean>} Resolves to true if submission and API call succeed, false otherwise.
 */
export async function handleEventFormSubmit(evt) {
  if (evt && typeof evt.preventDefault === 'function') {
    evt.preventDefault();
  }

  const formEl = evt?.target instanceof HTMLFormElement
    ? evt.target
    : document.querySelector('#event-form');

  if (!formEl) {
    return false;
  }

  const eventData = extractFormData(formEl);
  const validation = validateEventInput(eventData);

  if (!validation.isValid) {
    // Prevent the API call and display a visual warning in the UI
    renderValidationWarning(validation.errors);
    return false;
  }

  // Clear previous warnings when validation passes
  clearValidationWarning();

  const promptText = `Plan a ${eventData.eventType} titled "${eventData.title}" for ${eventData.guestCount} guests in ${eventData.city} with a budget of ${eventData.totalBudget}.`;
  
  const result = await generateEvent(promptText);

  if (!result) {
    renderErrorCard(DEFAULT_ERROR_CARD_MESSAGE);
    return false;
  }

  return true;
}

/**
 * Initializes DOM event listeners across the application.
 *
 * @returns {void}
 */
export function initEventListeners() {
  if (typeof document === 'undefined') {
    return;
  }

  const form = document.querySelector('#event-form');
  if (form) {
    form.addEventListener('submit', handleEventFormSubmit);
  }

  // Real-time clearance of validation warning on input change
  const budgetInput = document.querySelector('#totalBudget');
  if (budgetInput) {
    budgetInput.addEventListener('input', () => {
      const val = parseFloat((budgetInput).value || '0');
      if (val > 0) {
        clearValidationWarning();
      }
    });
  }
}
