/**
 * API Service Module for EventCraft AI.
 * Communicates with the secure Netlify Serverless Function proxy at
 * /.netlify/functions/generate-event to protect API credentials.
 * @module api
 */

import { updateUIErrorState, renderErrorCard, FALLBACK_ERROR_MESSAGE, DEFAULT_ERROR_CARD_MESSAGE } from './ui.js';

/**
 * Fetches event recommendations from the Netlify serverless proxy.
 * Includes abort timeout handling and strict JSON validation.
 *
 * @param {string} prompt - The prompt text to transmit in the request body.
 * @param {object} [options={}] - Additional fetch options.
 * @param {number} [options.timeoutMs=15000] - Request timeout in milliseconds.
 * @returns {Promise<any>} The parsed JSON data from the proxy response.
 * @throws {Error} If the HTTP response is not ok, times out, or returns invalid JSON.
 */
export async function fetchEventPlanFromProxy(prompt, options = {}) {
  const timeoutMs = options.timeoutMs || 15000;
  const controller = typeof AbortController !== 'undefined' ? new AbortController() : null;
  const timeoutId = controller ? setTimeout(() => controller.abort(), timeoutMs) : null;

  try {
    const fetchOptions = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ prompt }),
      signal: controller ? controller.signal : undefined,
    };

    const response = await fetch('/.netlify/functions/generate-event', fetchOptions);

    if (!response.ok) {
      throw new Error(`Proxy returned status ${response.status}`);
    }

    let parsedData;
    try {
      parsedData = await response.json();
    } catch {
      throw new Error('Malformed JSON received from AI service.');
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
 *
 * @param {string|object} promptInput - The prompt string or object containing a prompt property.
 * @returns {Promise<any>} Resolves with the parsed data object or null if the call fails.
 */
export async function generateEvent(promptInput) {
  let promptText = '';

  if (typeof promptInput === 'string') {
    promptText = promptInput;
  } else if (promptInput && typeof promptInput === 'object') {
    promptText = typeof promptInput.prompt === 'string' ? promptInput.prompt : JSON.stringify(promptInput);
  }

  try {
    const data = await fetchEventPlanFromProxy(promptText);
    return data;
  } catch {
    // Graceful error state in the UI without relying on console.error
    updateUIErrorState(FALLBACK_ERROR_MESSAGE);
    renderErrorCard(DEFAULT_ERROR_CARD_MESSAGE);
    return null;
  }
}

export const generateEventWithGemini = generateEvent;
export const callGemini = generateEvent;
export const generateIdeas = generateEvent;
