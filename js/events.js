/**
 * Event Listeners and Form Handling Module for EventCraft AI.
 * Wrapped in an IIFE to eliminate global variables.
 * Coordinates input validation, submit interception, and UI feedback loops.
 * Centralizes all form selectors, field keys, and prompt templates in a top-level CONSTANTS object.
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

const EventsModule = (() => {
  'use strict';

  /**
   * Top-level CONSTANTS object storing form selectors, input keys, defaults, and templates.
   * @readonly
   * @type {object}
   */
  const CONSTANTS = Object.freeze({
    SELECTORS: Object.freeze({
      EVENT_FORM: '#event-form',
      IS_OUTDOOR: '#isOutdoor',
      TOTAL_BUDGET: '#totalBudget',
      CHECKED_PSEUDO: ':checked',
    }),
    FIELDS: Object.freeze({
      TITLE: 'title',
      EVENT_TYPE: 'eventType',
      EVENT_DATE: 'eventDate',
      GUEST_COUNT: 'guestCount',
      TOTAL_BUDGET: 'totalBudget',
      CITY: 'city',
      THEME_PREFERENCE: 'themePreference',
    }),
    DEFAULTS: Object.freeze({
      EMPTY_STRING: '',
      FALLBACK_NUMBER_STRING: '0',
      ZERO_BUDGET_THRESHOLD: 0,
      RADIX_DECIMAL: 10,
    }),
    DOM_EVENTS: Object.freeze({
      SUBMIT: 'submit',
      INPUT: 'input',
    }),
    PROMPT_TEMPLATE: Object.freeze({
      PREFIX: 'Plan a ',
      TITLED: ' titled "',
      FOR: '" for ',
      GUESTS_IN: ' guests in ',
      WITH_BUDGET: ' with a budget of ',
      PERIOD: '.',
    }),
  });

  /**
   * Extracts form field values into a structured event data object.
   *
   * @param {HTMLFormElement} formEl - The form element containing event inputs.
   * @returns {object} The extracted event input payload.
   */
  function extractFormData(formEl) {
    if (!formEl || !(formEl instanceof HTMLFormElement)) {
      return {};
    }

    const formData = new FormData(formEl);
    const titleVal = formData.get(CONSTANTS.FIELDS.TITLE);
    const eventTypeVal = formData.get(CONSTANTS.FIELDS.EVENT_TYPE);
    const eventDateVal = formData.get(CONSTANTS.FIELDS.EVENT_DATE);
    const guestCountVal = formData.get(CONSTANTS.FIELDS.GUEST_COUNT);
    const budgetVal = formData.get(CONSTANTS.FIELDS.TOTAL_BUDGET);
    const cityVal = formData.get(CONSTANTS.FIELDS.CITY);
    const themeVal = formData.get(CONSTANTS.FIELDS.THEME_PREFERENCE);

    const outdoorCheckbox = formEl.querySelector(CONSTANTS.SELECTORS.IS_OUTDOOR);
    const isOutdoorChecked = outdoorCheckbox ? outdoorCheckbox.matches(CONSTANTS.SELECTORS.CHECKED_PSEUDO) : false;

    return {
      title: String(titleVal || CONSTANTS.DEFAULTS.EMPTY_STRING).trim(),
      eventType: String(eventTypeVal || CONSTANTS.DEFAULTS.EMPTY_STRING).trim(),
      eventDate: String(eventDateVal || CONSTANTS.DEFAULTS.EMPTY_STRING).trim(),
      guestCount: parseInt(String(guestCountVal || CONSTANTS.DEFAULTS.FALLBACK_NUMBER_STRING), CONSTANTS.DEFAULTS.RADIX_DECIMAL),
      totalBudget: parseFloat(String(budgetVal || CONSTANTS.DEFAULTS.FALLBACK_NUMBER_STRING)),
      city: String(cityVal || CONSTANTS.DEFAULTS.EMPTY_STRING).trim(),
      themePreference: String(themeVal || CONSTANTS.DEFAULTS.EMPTY_STRING).trim(),
      isOutdoor: isOutdoorChecked,
    };
  }

  /**
   * Builds the AI prompt string from the validated event data.
   *
   * @param {object} eventData - The validated event data object.
   * @returns {string} The constructed prompt string.
   */
  function constructPrompt(eventData) {
    return `${CONSTANTS.PROMPT_TEMPLATE.PREFIX}${eventData.eventType}${CONSTANTS.PROMPT_TEMPLATE.TITLED}${eventData.title}${CONSTANTS.PROMPT_TEMPLATE.FOR}${eventData.guestCount}${CONSTANTS.PROMPT_TEMPLATE.GUESTS_IN}${eventData.city}${CONSTANTS.PROMPT_TEMPLATE.WITH_BUDGET}${eventData.totalBudget}${CONSTANTS.PROMPT_TEMPLATE.PERIOD}`;
  }

  /**
   * Handles the event form submission with strict client-side validation.
   * Prevents API calls if budget <= 0 or required fields are blank/invalid,
   * rendering a visual warning alert in the UI.
   *
   * @param {SubmitEvent|Event} [evt] - The form submission event.
   * @returns {Promise<boolean>} Resolves to true if submission and API call succeed, false otherwise.
   */
  async function handleEventFormSubmit(evt) {
    if (evt && typeof evt.preventDefault === 'function') {
      evt.preventDefault();
    }

    let formEl = null;
    if (evt && evt.target instanceof HTMLFormElement) {
      formEl = evt.target;
    } else if (typeof document !== 'undefined') {
      formEl = document.querySelector(CONSTANTS.SELECTORS.EVENT_FORM);
    }

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

    const promptText = constructPrompt(eventData);
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
  function initEventListeners() {
    if (typeof document === 'undefined') {
      return;
    }

    const form = document.querySelector(CONSTANTS.SELECTORS.EVENT_FORM);
    if (form) {
      form.addEventListener(CONSTANTS.DOM_EVENTS.SUBMIT, handleEventFormSubmit);
    }

    // Real-time clearance of validation warning on positive budget input
    const budgetInput = document.querySelector(CONSTANTS.SELECTORS.TOTAL_BUDGET);
    if (budgetInput) {
      budgetInput.addEventListener(CONSTANTS.DOM_EVENTS.INPUT, () => {
        const val = parseFloat(budgetInput.value || CONSTANTS.DEFAULTS.FALLBACK_NUMBER_STRING);
        if (val > CONSTANTS.DEFAULTS.ZERO_BUDGET_THRESHOLD) {
          clearValidationWarning();
        }
      });
    }
  }

  return {
    CONSTANTS,
    extractFormData,
    constructPrompt,
    handleEventFormSubmit,
    initEventListeners,
  };
})();

export const {
  CONSTANTS,
  extractFormData,
  constructPrompt,
  handleEventFormSubmit,
  initEventListeners,
} = EventsModule;

export default initEventListeners;
