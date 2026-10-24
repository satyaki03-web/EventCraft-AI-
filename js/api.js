/**
 * API Service Module for EventCraft AI.
 * Wrapped in an IIFE to eliminate global variables.
 * Communicates with the secure Netlify Serverless Function proxy at
 * /.netlify/functions/generate-event with an AbortController enforcing a 10-second timeout.
 * @module api
 */

import {
  updateUIErrorState,
  renderErrorCard,
  FALLBACK_ERROR_MESSAGE,
  DEFAULT_ERROR_CARD_MESSAGE,
} from './ui.js';

const ApiModule = (() => {
  'use strict';

  /**
   * Top-level CONSTANTS object storing network configuration, timeouts, and messages.
   * @readonly
   * @type {object}
   */
  const CONSTANTS = Object.freeze({
    API_ENDPOINT: '/.netlify/functions/generate-event',
    HTTP_METHOD_POST: 'POST',
    CONTENT_TYPE_HEADER: 'Content-Type',
    CONTENT_TYPE_JSON: 'application/json',
    FETCH_TIMEOUT_MS: 10000, // Strict 10-second timeout
    ERROR_MALFORMED_JSON: 'Malformed JSON received from AI service.',
    ERROR_PROXY_PREFIX: 'Proxy returned status ',
    FALLBACK_ERROR_MESSAGE,
    DEFAULT_ERROR_CARD_MESSAGE,
    EMPTY_STRING: '',
  });

  /**
   * Fetches event recommendations from the Netlify serverless proxy.
   * Includes an AbortController with a 10-second timeout and strict JSON parsing.
   *
   * @param {string} prompt - The prompt text to transmit in the request body.
   * @param {object} [options={}] - Additional fetch options.
   * @param {number} [options.timeoutMs=CONSTANTS.FETCH_TIMEOUT_MS] - Request timeout in milliseconds.
   * @returns {Promise<any>} The parsed JSON data from the proxy response.
   * @throws {Error} If the HTTP response is not ok, times out, or returns invalid JSON.
   */
  async function fetchEventPlanFromProxy(prompt, options = {}) {
    const timeoutMs = typeof options.timeoutMs === 'number' ? options.timeoutMs : CONSTANTS.FETCH_TIMEOUT_MS;
    const controller = typeof AbortController !== 'undefined' ? new AbortController() : null;
    const timeoutId = controller ? setTimeout(() => controller.abort(), timeoutMs) : null;

    try {
      const fetchOptions = {
        method: CONSTANTS.HTTP_METHOD_POST,
        headers: {
          [CONSTANTS.CONTENT_TYPE_HEADER]: CONSTANTS.CONTENT_TYPE_JSON,
        },
        body: JSON.stringify({ prompt }),
        signal: controller ? controller.signal : undefined,
      };

      const response = await fetch(CONSTANTS.API_ENDPOINT, fetchOptions);

      if (!response.ok) {
        throw new Error(`${CONSTANTS.ERROR_PROXY_PREFIX}${response.status}`);
      }

      let parsedData;
      try {
        parsedData = await response.json();
      } catch {
        throw new Error(CONSTANTS.ERROR_MALFORMED_JSON);
      }

      return parsedData;
    } finally {
      if (timeoutId) {
        clearTimeout(timeoutId);
      }
    }
  }

  /**
   * Generates an event plan or recommendations by communicating with the serverless function.
   * Wraps calls in strict try/catch to ensure graceful UI degradation without console.error.
   * Automatically triggers UI error state on failure, abort, or timeout.
   *
   * @param {string|object} promptInput - The prompt string or object containing a prompt property.
   * @returns {Promise<any>} Resolves with the parsed data object or null if the call fails.
   */
  async function generateEvent(promptInput) {
    let promptText = CONSTANTS.EMPTY_STRING;

    if (typeof promptInput === 'string') {
      promptText = promptInput;
    } else if (promptInput && typeof promptInput === 'object') {
      promptText = typeof promptInput.prompt === 'string' ? promptInput.prompt : JSON.stringify(promptInput);
    }

    try {
      const data = await fetchEventPlanFromProxy(promptText);
      return data;
    } catch {
      // Graceful error state in the UI triggered upon error, timeout, or abort
      updateUIErrorState(CONSTANTS.FALLBACK_ERROR_MESSAGE);
      renderErrorCard(CONSTANTS.DEFAULT_ERROR_CARD_MESSAGE);
      return null;
    }
  }

  return {
    CONSTANTS,
    fetchEventPlanFromProxy,
    generateEvent,
    generateEventWithGemini: generateEvent,
    callGemini: generateEvent,
    generateIdeas: generateEvent,
  };
})();

export const {
  CONSTANTS,
  fetchEventPlanFromProxy,
  generateEvent,
  generateEventWithGemini,
  callGemini,
  generateIdeas,
} = ApiModule;

export default generateEvent;
