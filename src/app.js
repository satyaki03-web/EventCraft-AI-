/**
 * Frontend JavaScript Entry Module for EventCraft AI (src bundle).
 * Orchestrates modular services for API fetching, input validation, UI rendering,
 * and accessible event listeners.
 * @module app
 */

import {
  fetchEventPlanFromProxy,
  generateEvent,
  generateEventWithGemini,
  callGemini,
  generateIdeas,
} from '../js/api.js';

import {
  validateEventInput,
} from '../js/validation.js';

import {
  formatCurrency,
  formatDate,
  sanitizeText,
} from '../js/formatting.js';

import {
  renderErrorCard,
  renderValidationWarning,
  clearValidationWarning,
  updateUIErrorState,
  renderBudget,
  renderTimeline,
  renderVendors,
  FALLBACK_ERROR_MESSAGE,
  DEFAULT_ERROR_CARD_MESSAGE,
} from '../js/ui.js';

import {
  extractFormData,
  handleEventFormSubmit,
  initEventListeners,
} from '../js/events.js';

export {
  fetchEventPlanFromProxy,
  generateEvent,
  generateEventWithGemini,
  callGemini,
  generateIdeas,
  validateEventInput,
  formatCurrency,
  formatDate,
  sanitizeText,
  renderErrorCard,
  renderValidationWarning,
  clearValidationWarning,
  updateUIErrorState,
  renderBudget,
  renderTimeline,
  renderVendors,
  extractFormData,
  handleEventFormSubmit,
  initEventListeners,
  FALLBACK_ERROR_MESSAGE,
  DEFAULT_ERROR_CARD_MESSAGE,
};

/**
 * Initializes the frontend application and registers interactive listeners.
 *
 * @returns {void}
 */
export function initializeApp() {
  if (typeof document !== 'undefined') {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => initEventListeners());
    } else {
      initEventListeners();
    }
  }
}

if (typeof window !== 'undefined') {
  window.generateEvent = generateEvent;
  window.generateEventWithGemini = generateEventWithGemini;
  window.callGemini = callGemini;
  window.generateIdeas = generateIdeas;
  window.updateUIErrorState = updateUIErrorState;
  window.renderErrorCard = renderErrorCard;
  window.validateEventInput = validateEventInput;
  window.initEventListeners = initEventListeners;
  window.initializeApp = initializeApp;
}

initializeApp();

export default generateEvent;
