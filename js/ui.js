/**
 * UI Rendering and DOM Manipulation Module for EventCraft AI.
 * Wrapped in an IIFE to eliminate global variables.
 * Strictly uses textContent to prevent Cross-Site Scripting (XSS) risks.
 * Centralizes all DOM selectors and messages in top-level CONSTANTS.
 * @module ui
 */

import { formatCurrency } from './formatting.js';

const UIModule = (() => {
  'use strict';

  /**
   * Top-level CONSTANTS object storing DOM selectors, class names, and messages.
   * @readonly
   * @type {object}
   */
  const CONSTANTS = Object.freeze({
    DEFAULT_ERROR_CARD_MESSAGE: 'Unable to generate plan. Please verify your inputs and try again.',
    FALLBACK_ERROR_MESSAGE: 'The AI is currently resting. Please try again.',
    NOTICE_HEADING: 'Unable to generate plan',
    VALIDATION_HEADING: 'Please correct the following inputs:',
    BUDGET_TITLE_PREFIX: 'Budget Breakdown: ',
    ROLE_ALERT: 'alert',
    ARIA_LIVE_POLITE: 'polite',
    ARIA_LIVE_ASSERTIVE: 'assertive',
    DISPLAY_BLOCK: 'block',
    DISPLAY_NONE: 'none',
    EMPTY_STRING: '',
    FALLBACK_TARGET_SELECTORS: Object.freeze([
      '#ai-error',
      '#error-message',
      '#ai-status',
      '#ai-response',
      '#event-output',
      '.ai-error-message',
      '.ai-status-message',
    ]),
    SELECTORS: Object.freeze({
      VALIDATION_WARNING: '#validation-warning',
      ERROR_CARD: '#error-card',
      AI_ERROR: '#ai-error',
      ERROR_MESSAGE: '#error-message',
      AI_STATUS: '#ai-status',
      AI_RESPONSE: '#ai-response',
      BUDGET_OUTPUT: '#budget-output',
      TIMELINE_OUTPUT: '#timeline-output',
      VENDORS_OUTPUT: '#vendors-output',
    }),
    CLASSES: Object.freeze({
      ERROR_CARD: 'ai-error-card bg-rose-50 border-2 border-rose-300 rounded-xl p-4 text-rose-900 warm-card-shadow my-4',
      ERROR_HEADER: 'flex items-center space-x-2 mb-1',
      ERROR_TITLE: 'text-sm font-bold text-rose-950 uppercase tracking-wide',
      ERROR_MESSAGE: 'text-xs font-medium text-rose-800 leading-relaxed',
      VALIDATION_CARD: 'validation-warning-card bg-amber-50 border-2 border-amber-300 rounded-xl p-4 my-3 text-amber-950',
      VALIDATION_TITLE: 'text-xs font-black uppercase tracking-wider text-amber-900 mb-1',
      VALIDATION_LIST: 'list-disc list-inside text-xs space-y-1 font-semibold',
      BUDGET_WRAPPER: 'budget-card bg-white rounded-xl p-5 border border-stone-200 shadow-sm',
      BUDGET_HEADING: 'text-base font-bold text-stone-900 mb-3',
      BUDGET_ADVICE: 'text-xs text-stone-600 mb-4',
      BUDGET_LIST: 'space-y-2 text-xs',
      BUDGET_ITEM: 'flex justify-between items-center py-1.5 border-b border-stone-100',
      TIMELINE_SECTION: 'timeline-section space-y-3',
      TIMELINE_CARD: 'p-3 bg-white rounded-lg border border-stone-200',
      TIMELINE_HEADER: 'flex justify-between items-center mb-1',
      TIMELINE_LABEL: 'text-[11px] font-bold text-stone-500 uppercase',
      TIMELINE_DATE: 'text-[11px] font-semibold text-stone-600',
      TIMELINE_TITLE: 'text-xs font-bold text-stone-900',
      TIMELINE_DESC: 'text-[11px] text-stone-600 mt-0.5',
      VENDOR_LIST: 'space-y-3',
      VENDOR_CARD: 'p-3 bg-white rounded-lg border border-stone-200',
      VENDOR_TITLE: 'text-xs font-bold text-stone-900',
      VENDOR_LEAD: 'inline-block text-[10px] font-semibold text-stone-500 mt-1',
    }),
  });

  /**
   * Resolves a DOM target element safely from a string selector, element object, or fallback ID.
   *
   * @param {HTMLElement|string|null} container - The container reference or selector.
   * @param {string[]} [fallbackIds=[]] - List of element IDs to inspect if container is null.
   * @returns {any} The resolved DOM element or null.
   */
  function resolveContainer(container, fallbackIds = []) {
    if (typeof document === 'undefined') {
      return null;
    }
    if (typeof container === 'string') {
      return document.querySelector(container);
    }
    if (typeof HTMLElement !== 'undefined' && container instanceof HTMLElement) {
      return container;
    }
    if (container && typeof container === 'object') {
      return container;
    }
    for (const id of fallbackIds) {
      const el = document.getElementById(id) || document.querySelector(`#${id}`);
      if (el) return el;
    }
    return null;
  }

  /**
   * Renders a styled, accessible error card into a specified DOM container.
   * Uses textContent exclusively to eliminate XSS vulnerabilities.
   *
   * @param {string} [message=CONSTANTS.DEFAULT_ERROR_CARD_MESSAGE] - The user-friendly error message to display.
   * @param {HTMLElement|string|null} [container=null] - The container element or selector where the error card will be rendered.
   * @returns {HTMLElement|null} The created error card element, or null if running in a non-browser environment.
   */
  function renderErrorCard(message = CONSTANTS.DEFAULT_ERROR_CARD_MESSAGE, container = null) {
    if (typeof document === 'undefined') {
      return null;
    }

    const targetEl = resolveContainer(container, ['error-card', 'ai-error-card']);

    if (typeof document.createElement !== 'function') {
      if (targetEl && 'textContent' in targetEl) {
        targetEl.textContent = message;
        if (targetEl.style) targetEl.style.display = CONSTANTS.DISPLAY_BLOCK;
      }
      return targetEl;
    }

    const card = document.createElement('article');
    card.className = CONSTANTS.CLASSES.ERROR_CARD;
    card.setAttribute('role', CONSTANTS.ROLE_ALERT);
    card.setAttribute('aria-live', CONSTANTS.ARIA_LIVE_POLITE);

    const headerDiv = document.createElement('div');
    headerDiv.className = CONSTANTS.CLASSES.ERROR_HEADER;

    const titleEl = document.createElement('h4');
    titleEl.className = CONSTANTS.CLASSES.ERROR_TITLE;
    titleEl.textContent = CONSTANTS.NOTICE_HEADING;

    headerDiv.appendChild(titleEl);

    const messageEl = document.createElement('p');
    messageEl.className = CONSTANTS.CLASSES.ERROR_MESSAGE;
    messageEl.textContent = message;

    card.appendChild(headerDiv);
    card.appendChild(messageEl);

    if (targetEl) {
      if (typeof targetEl.replaceChildren === 'function') {
        targetEl.replaceChildren(card);
      } else if (typeof targetEl.appendChild === 'function') {
        targetEl.textContent = CONSTANTS.EMPTY_STRING;
        targetEl.appendChild(card);
      } else {
        targetEl.textContent = message;
      }
      if (targetEl.style) {
        targetEl.style.display = CONSTANTS.DISPLAY_BLOCK;
      }
    }

    return card;
  }

  /**
   * Renders an accessible validation warning box listing all input issues.
   *
   * @param {string[]} errors - Array of validation error descriptions.
   * @param {HTMLElement|string|null} [container=null] - The target DOM container for the warning.
   * @returns {HTMLElement|null} The warning container element, or null if document is undefined.
   */
  function renderValidationWarning(errors, container = null) {
    if (typeof document === 'undefined') {
      return null;
    }

    let targetEl = resolveContainer(container, ['validation-warning']);

    if (!targetEl && typeof document.createElement === 'function') {
      targetEl = document.createElement('div');
      targetEl.id = 'validation-warning';
      if (document.body) {
        document.body.prepend(targetEl);
      }
    }

    if (!targetEl) return null;

    if (typeof targetEl.replaceChildren === 'function') {
      targetEl.replaceChildren();
    } else {
      targetEl.textContent = CONSTANTS.EMPTY_STRING;
    }

    if (!errors || errors.length === 0) {
      if (targetEl.style) {
        targetEl.style.display = CONSTANTS.DISPLAY_NONE;
      }
      return targetEl;
    }

    if (typeof document.createElement !== 'function') {
      targetEl.textContent = errors.join(', ');
      if (targetEl.style) targetEl.style.display = CONSTANTS.DISPLAY_BLOCK;
      return targetEl;
    }

    const warningCard = document.createElement('div');
    warningCard.className = CONSTANTS.CLASSES.VALIDATION_CARD;
    warningCard.setAttribute('role', CONSTANTS.ROLE_ALERT);
    warningCard.setAttribute('aria-live', CONSTANTS.ARIA_LIVE_ASSERTIVE);

    const title = document.createElement('h4');
    title.className = CONSTANTS.CLASSES.VALIDATION_TITLE;
    title.textContent = CONSTANTS.VALIDATION_HEADING;
    warningCard.appendChild(title);

    const list = document.createElement('ul');
    list.className = CONSTANTS.CLASSES.VALIDATION_LIST;

    for (const err of errors) {
      const li = document.createElement('li');
      li.textContent = err;
      list.appendChild(li);
    }

    warningCard.appendChild(list);
    targetEl.appendChild(warningCard);
    if (targetEl.style) {
      targetEl.style.display = CONSTANTS.DISPLAY_BLOCK;
    }

    return targetEl;
  }

  /**
   * Clears any active validation warnings from the DOM.
   *
   * @param {HTMLElement|string|null} [container=null] - Target container to clear.
   * @returns {void}
   */
  function clearValidationWarning(container = null) {
    if (typeof document === 'undefined') {
      return;
    }
    const targetEl = resolveContainer(container, ['validation-warning']);
    if (targetEl) {
      if (typeof targetEl.replaceChildren === 'function') {
        targetEl.replaceChildren();
      } else {
        targetEl.textContent = CONSTANTS.EMPTY_STRING;
      }
      if (targetEl.style) {
        targetEl.style.display = CONSTANTS.DISPLAY_NONE;
      }
    }
  }

  /**
   * Updates DOM error elements to display a graceful fallback error message.
   * Maintains compatibility with existing tests and UI integrations.
   *
   * @param {string} [message=CONSTANTS.FALLBACK_ERROR_MESSAGE] - Error message to inject safely via textContent.
   * @returns {void}
   */
  function updateUIErrorState(message = CONSTANTS.FALLBACK_ERROR_MESSAGE) {
    let elementFound = false;

    for (const selector of CONSTANTS.FALLBACK_TARGET_SELECTORS) {
      const el = typeof document !== 'undefined' ? document.querySelector(selector) : null;
      if (el) {
        el.textContent = message;
        if (el.style) {
          el.style.display = CONSTANTS.DISPLAY_BLOCK;
        }
        elementFound = true;
      }
    }

    if (!elementFound && typeof document !== 'undefined' && document.body) {
      let fallbackEl = document.getElementById('ai-error');
      if (!fallbackEl && typeof document.createElement === 'function') {
        fallbackEl = document.createElement('div');
        fallbackEl.id = 'ai-error';
        fallbackEl.setAttribute('aria-live', CONSTANTS.ARIA_LIVE_POLITE);
        document.body.appendChild(fallbackEl);
      }
      if (fallbackEl) {
        fallbackEl.textContent = message;
        fallbackEl.style.display = CONSTANTS.DISPLAY_BLOCK;
      }
    }
  }

  /**
   * Renders the deterministic budget allocation plan into a DOM container.
   * Strictly uses textContent to prevent XSS.
   *
   * @param {object} budgetPlan - The calculated budget breakdown object.
   * @param {HTMLElement|string} container - The target DOM container for the budget.
   * @returns {void}
   */
  function renderBudget(budgetPlan, container) {
    if (typeof document === 'undefined' || typeof document.createElement !== 'function') return;
    const targetEl = typeof container === 'string' ? document.querySelector(container) : container;
    if (!targetEl || !budgetPlan) return;

    targetEl.replaceChildren();
    targetEl.setAttribute('aria-live', CONSTANTS.ARIA_LIVE_POLITE);

    const wrapper = document.createElement('article');
    wrapper.className = CONSTANTS.CLASSES.BUDGET_WRAPPER;

    const heading = document.createElement('h3');
    heading.className = CONSTANTS.CLASSES.BUDGET_HEADING;
    heading.textContent = `${CONSTANTS.BUDGET_TITLE_PREFIX}${formatCurrency(budgetPlan.totalBudget, budgetPlan.currencySymbol)}`;
    wrapper.appendChild(heading);

    if (budgetPlan.advice) {
      const advice = document.createElement('p');
      advice.className = CONSTANTS.CLASSES.BUDGET_ADVICE;
      advice.textContent = budgetPlan.advice;
      wrapper.appendChild(advice);
    }

    if (Array.isArray(budgetPlan.lines)) {
      const list = document.createElement('ul');
      list.className = CONSTANTS.CLASSES.BUDGET_LIST;

      for (const line of budgetPlan.lines) {
        const item = document.createElement('li');
        item.className = CONSTANTS.CLASSES.BUDGET_ITEM;

        const catSpan = document.createElement('span');
        catSpan.className = 'font-semibold text-stone-800';
        catSpan.textContent = `${line.category} (${line.percentage}%)`;

        const amtSpan = document.createElement('span');
        amtSpan.className = 'font-bold text-stone-950';
        amtSpan.textContent = formatCurrency(line.amount, budgetPlan.currencySymbol);

        item.appendChild(catSpan);
        item.appendChild(amtSpan);
        list.appendChild(item);
      }
      wrapper.appendChild(list);
    }

    targetEl.appendChild(wrapper);
  }

  /**
   * Renders the milestone timeline into a DOM container.
   * Strictly uses textContent to prevent XSS.
   *
   * @param {Array<object>} milestones - List of milestone objects.
   * @param {HTMLElement|string} container - The target DOM container for the timeline.
   * @returns {void}
   */
  function renderTimeline(milestones, container) {
    if (typeof document === 'undefined' || typeof document.createElement !== 'function') return;
    const targetEl = typeof container === 'string' ? document.querySelector(container) : container;
    if (!targetEl || !Array.isArray(milestones)) return;

    targetEl.replaceChildren();
    targetEl.setAttribute('aria-live', CONSTANTS.ARIA_LIVE_POLITE);

    const section = document.createElement('section');
    section.className = CONSTANTS.CLASSES.TIMELINE_SECTION;

    for (const m of milestones) {
      const item = document.createElement('article');
      item.className = CONSTANTS.CLASSES.TIMELINE_CARD;

      const header = document.createElement('div');
      header.className = CONSTANTS.CLASSES.TIMELINE_HEADER;

      const label = document.createElement('span');
      label.className = CONSTANTS.CLASSES.TIMELINE_LABEL;
      label.textContent = m.timeFrameLabel || CONSTANTS.EMPTY_STRING;

      const date = document.createElement('span');
      date.className = CONSTANTS.CLASSES.TIMELINE_DATE;
      date.textContent = m.targetDate || CONSTANTS.EMPTY_STRING;

      header.appendChild(label);
      header.appendChild(date);

      const title = document.createElement('h4');
      title.className = CONSTANTS.CLASSES.TIMELINE_TITLE;
      title.textContent = m.title || CONSTANTS.EMPTY_STRING;

      const desc = document.createElement('p');
      desc.className = CONSTANTS.CLASSES.TIMELINE_DESC;
      desc.textContent = m.description || CONSTANTS.EMPTY_STRING;

      item.appendChild(header);
      item.appendChild(title);
      item.appendChild(desc);
      section.appendChild(item);
    }

    targetEl.appendChild(section);
  }

  /**
   * Renders the vendor action checklist into a DOM container.
   * Strictly uses textContent to prevent XSS.
   *
   * @param {Array<object>} vendors - List of vendor objects.
   * @param {HTMLElement|string} container - The target DOM container for vendors.
   * @returns {void}
   */
  function renderVendors(vendors, container) {
    if (typeof document === 'undefined' || typeof document.createElement !== 'function') return;
    const targetEl = typeof container === 'string' ? document.querySelector(container) : container;
    if (!targetEl || !Array.isArray(vendors)) return;

    targetEl.replaceChildren();
    targetEl.setAttribute('aria-live', CONSTANTS.ARIA_LIVE_POLITE);

    const list = document.createElement('ul');
    list.className = CONSTANTS.CLASSES.VENDOR_LIST;

    for (const v of vendors) {
      const li = document.createElement('li');
      li.className = CONSTANTS.CLASSES.VENDOR_CARD;

      const title = document.createElement('h4');
      title.className = CONSTANTS.CLASSES.VENDOR_TITLE;
      title.textContent = `${v.category}: ${v.name}`;

      const lead = document.createElement('span');
      lead.className = CONSTANTS.CLASSES.VENDOR_LEAD;
      lead.textContent = `Lead time: ${v.leadTime || 'Standard'}`;

      li.appendChild(title);
      li.appendChild(lead);
      list.appendChild(li);
    }

    targetEl.appendChild(list);
  }

  return {
    CONSTANTS,
    resolveContainer,
    renderErrorCard,
    renderValidationWarning,
    clearValidationWarning,
    updateUIErrorState,
    renderBudget,
    renderTimeline,
    renderVendors,
    FALLBACK_ERROR_MESSAGE: CONSTANTS.FALLBACK_ERROR_MESSAGE,
    DEFAULT_ERROR_CARD_MESSAGE: CONSTANTS.DEFAULT_ERROR_CARD_MESSAGE,
  };
})();

export const {
  CONSTANTS,
  resolveContainer,
  renderErrorCard,
  renderValidationWarning,
  clearValidationWarning,
  updateUIErrorState,
  renderBudget,
  renderTimeline,
  renderVendors,
  FALLBACK_ERROR_MESSAGE,
  DEFAULT_ERROR_CARD_MESSAGE,
} = UIModule;

export default UIModule;
