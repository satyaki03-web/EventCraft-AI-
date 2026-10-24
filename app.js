/**
 * Frontend JavaScript Entry Module for EventCraft AI.
 * Wrapped in an IIFE to eliminate global namespace pollution.
 * Orchestrates modular services for API fetching, input validation, UI rendering,
 * and accessible event listeners.
 * @module app
 */

import {
  CONSTANTS as API_CONSTANTS,
  fetchEventPlanFromProxy,
  generateEvent,
  generateEventWithGemini,
  callGemini,
  generateIdeas,
} from './js/api.js';

import {
  CONSTANTS as VALIDATION_CONSTANTS,
  validateEventInput,
  isPastDate,
} from './js/validation.js';

import {
  CONSTANTS as FORMATTING_CONSTANTS,
  formatCurrency,
  formatDate,
  sanitizeText,
} from './js/formatting.js';

import {
  CONSTANTS as UI_CONSTANTS,
  renderErrorCard,
  renderValidationWarning,
  clearValidationWarning,
  updateUIErrorState,
  renderBudget,
  renderTimeline,
  renderVendors,
  FALLBACK_ERROR_MESSAGE,
  DEFAULT_ERROR_CARD_MESSAGE,
} from './js/ui.js';

import {
  CONSTANTS as EVENTS_CONSTANTS,
  extractFormData,
  constructPrompt,
  handleEventFormSubmit,
  initEventListeners,
} from './js/events.js';

const AppModule = (() => {
  'use strict';

  /**
   * Top-level CONSTANTS object aggregating module configurations and timeouts.
   * @readonly
   * @type {object}
   */
  const CONSTANTS = Object.freeze({
    FETCH_TIMEOUT_MS: API_CONSTANTS.FETCH_TIMEOUT_MS, // 10000ms
    MIN_BUDGET_BOUNDARY: VALIDATION_CONSTANTS.MIN_BUDGET_BOUNDARY,
    MIN_GUESTS_BOUNDARY: VALIDATION_CONSTANTS.MIN_GUESTS_BOUNDARY,
    FALLBACK_ERROR_MESSAGE,
    DEFAULT_ERROR_CARD_MESSAGE,
    API: API_CONSTANTS,
    VALIDATION: VALIDATION_CONSTANTS,
    FORMATTING: FORMATTING_CONSTANTS,
    UI: UI_CONSTANTS,
    EVENTS: EVENTS_CONSTANTS,
  });

  /**
   * Initializes the frontend application and registers interactive listeners.
   *
   * @returns {void}
   */
  function initializeApp() {
    if (typeof document !== 'undefined') {
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => initEventListeners());
      } else {
        initEventListeners();
      }
    }
  }

  // Window browser bindings for non-module script tag execution
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
    window.CONSTANTS = CONSTANTS;
  }

  return {
    CONSTANTS,
    initializeApp,
    fetchEventPlanFromProxy,
    generateEvent,
    generateEventWithGemini,
    callGemini,
    generateIdeas,
    validateEventInput,
    isPastDate,
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
    constructPrompt,
    handleEventFormSubmit,
    initEventListeners,
    FALLBACK_ERROR_MESSAGE,
    DEFAULT_ERROR_CARD_MESSAGE,
  };
})();

// Re-export all modular functionality for ES6 module consumers
export const {
  CONSTANTS,
  initializeApp,
  fetchEventPlanFromProxy,
  generateEvent,
  generateEventWithGemini,
  callGemini,
  generateIdeas,
  validateEventInput,
  isPastDate,
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
  constructPrompt,
  handleEventFormSubmit,
  initEventListeners,
  FALLBACK_ERROR_MESSAGE,
  DEFAULT_ERROR_CARD_MESSAGE,
} = AppModule;

// Auto-initialize when executing in the browser
initializeApp();

export default generateEvent;
