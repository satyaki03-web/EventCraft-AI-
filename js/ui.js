/**
 * UI Rendering and DOM Manipulation Module for EventCraft AI.
 * Strictly uses textContent to prevent Cross-Site Scripting (XSS) risks.
 * Manages accessible error cards, validation warnings, and live region updates.
 * @module ui
 */

import { formatCurrency } from './formatting.js';

export const DEFAULT_ERROR_CARD_MESSAGE = 'Unable to generate plan. Please verify your inputs and try again.';
export const FALLBACK_ERROR_MESSAGE = 'The AI is currently resting. Please try again.';

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
 * @param {string} [message=DEFAULT_ERROR_CARD_MESSAGE] - The user-friendly error message to display.
 * @param {HTMLElement|string|null} [container=null] - The container element or selector where the error card will be rendered.
 * @returns {HTMLElement|null} The created error card element, or null if running in a non-browser environment.
 */
export function renderErrorCard(message = DEFAULT_ERROR_CARD_MESSAGE, container = null) {
  if (typeof document === 'undefined') {
    return null;
  }

  const targetEl = resolveContainer(container, ['error-card', 'ai-error-card']);

  if (typeof document.createElement !== 'function') {
    if (targetEl && 'textContent' in targetEl) {
      targetEl.textContent = message;
      if (targetEl.style) targetEl.style.display = 'block';
    }
    return targetEl;
  }

  // Create styled error card element
  const card = document.createElement('article');
  card.className = 'ai-error-card bg-rose-50 border-2 border-rose-300 rounded-xl p-4 text-rose-900 warm-card-shadow my-4';
  card.setAttribute('role', 'alert');
  card.setAttribute('aria-live', 'polite');

  const headerDiv = document.createElement('div');
  headerDiv.className = 'flex items-center space-x-2 mb-1';

  const titleEl = document.createElement('h4');
  titleEl.className = 'text-sm font-bold text-rose-950 uppercase tracking-wide';
  titleEl.textContent = 'Unable to generate plan';

  headerDiv.appendChild(titleEl);

  const messageEl = document.createElement('p');
  messageEl.className = 'text-xs font-medium text-rose-800 leading-relaxed';
  // Enforce textContent to prevent XSS
  messageEl.textContent = message;

  card.appendChild(headerDiv);
  card.appendChild(messageEl);

  if (targetEl) {
    if (typeof targetEl.replaceChildren === 'function') {
      targetEl.replaceChildren(card);
    } else if (typeof targetEl.appendChild === 'function') {
      targetEl.textContent = '';
      targetEl.appendChild(card);
    } else {
      targetEl.textContent = message;
    }
    if (targetEl.style) {
      targetEl.style.display = 'block';
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
export function renderValidationWarning(errors, container = null) {
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
    targetEl.textContent = '';
  }

  if (!errors || errors.length === 0) {
    if (targetEl.style) {
      targetEl.style.display = 'none';
    }
    return targetEl;
  }

  if (typeof document.createElement !== 'function') {
    targetEl.textContent = errors.join(', ');
    if (targetEl.style) targetEl.style.display = 'block';
    return targetEl;
  }

  const warningCard = document.createElement('div');
  warningCard.className = 'validation-warning-card bg-amber-50 border-2 border-amber-300 rounded-xl p-4 my-3 text-amber-950';
  warningCard.setAttribute('role', 'alert');
  warningCard.setAttribute('aria-live', 'assertive');

  const title = document.createElement('h4');
  title.className = 'text-xs font-black uppercase tracking-wider text-amber-900 mb-1';
  title.textContent = 'Please correct the following inputs:';
  warningCard.appendChild(title);

  const list = document.createElement('ul');
  list.className = 'list-disc list-inside text-xs space-y-1 font-semibold';

  for (const err of errors) {
    const li = document.createElement('li');
    // Enforce textContent to prevent XSS
    li.textContent = err;
    list.appendChild(li);
  }

  warningCard.appendChild(list);
  targetEl.appendChild(warningCard);
  if (targetEl.style) {
    targetEl.style.display = 'block';
  }

  return targetEl;
}

/**
 * Clears any active validation warnings from the DOM.
 *
 * @param {HTMLElement|string|null} [container=null] - Target container to clear.
 * @returns {void}
 */
export function clearValidationWarning(container = null) {
  if (typeof document === 'undefined') {
    return;
  }
  const targetEl = resolveContainer(container, ['validation-warning']);
  if (targetEl) {
    if (typeof targetEl.replaceChildren === 'function') {
      targetEl.replaceChildren();
    } else {
      targetEl.textContent = '';
    }
    if (targetEl.style) {
      targetEl.style.display = 'none';
    }
  }
}

/**
 * Updates DOM error elements to display a graceful fallback error message.
 * Maintains compatibility with existing tests and UI integrations.
 *
 * @param {string} [message=FALLBACK_ERROR_MESSAGE] - Error message to inject safely via textContent.
 * @returns {void}
 */
export function updateUIErrorState(message = FALLBACK_ERROR_MESSAGE) {
  const targetSelectors = [
    '#ai-error',
    '#error-message',
    '#ai-status',
    '#ai-response',
    '#event-output',
    '.ai-error-message',
    '.ai-status-message',
  ];

  let elementFound = false;

  for (const selector of targetSelectors) {
    const el = typeof document !== 'undefined' ? document.querySelector(selector) : null;
    if (el) {
      el.textContent = message;
      if (el.style) {
        el.style.display = 'block';
      }
      elementFound = true;
    }
  }

  if (!elementFound && typeof document !== 'undefined' && document.body) {
    let fallbackEl = document.getElementById('ai-error');
    if (!fallbackEl && typeof document.createElement === 'function') {
      fallbackEl = document.createElement('div');
      fallbackEl.id = 'ai-error';
      fallbackEl.setAttribute('aria-live', 'polite');
      document.body.appendChild(fallbackEl);
    }
    if (fallbackEl) {
      fallbackEl.textContent = message;
      fallbackEl.style.display = 'block';
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
export function renderBudget(budgetPlan, container) {
  if (typeof document === 'undefined' || typeof document.createElement !== 'function') return;
  const targetEl = typeof container === 'string' ? document.querySelector(container) : container;
  if (!targetEl || !budgetPlan) return;

  targetEl.replaceChildren();
  targetEl.setAttribute('aria-live', 'polite');

  const wrapper = document.createElement('article');
  wrapper.className = 'budget-card bg-white rounded-xl p-5 border border-stone-200 shadow-sm';

  const heading = document.createElement('h3');
  heading.className = 'text-base font-bold text-stone-900 mb-3';
  heading.textContent = `Budget Breakdown: ${formatCurrency(budgetPlan.totalBudget, budgetPlan.currencySymbol)}`;
  wrapper.appendChild(heading);

  if (budgetPlan.advice) {
    const advice = document.createElement('p');
    advice.className = 'text-xs text-stone-600 mb-4';
    advice.textContent = budgetPlan.advice;
    wrapper.appendChild(advice);
  }

  if (Array.isArray(budgetPlan.lines)) {
    const list = document.createElement('ul');
    list.className = 'space-y-2 text-xs';

    for (const line of budgetPlan.lines) {
      const item = document.createElement('li');
      item.className = 'flex justify-between items-center py-1.5 border-b border-stone-100';

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
export function renderTimeline(milestones, container) {
  if (typeof document === 'undefined' || typeof document.createElement !== 'function') return;
  const targetEl = typeof container === 'string' ? document.querySelector(container) : container;
  if (!targetEl || !Array.isArray(milestones)) return;

  targetEl.replaceChildren();
  targetEl.setAttribute('aria-live', 'polite');

  const section = document.createElement('section');
  section.className = 'timeline-section space-y-3';

  for (const m of milestones) {
    const item = document.createElement('article');
    item.className = 'p-3 bg-white rounded-lg border border-stone-200';

    const header = document.createElement('div');
    header.className = 'flex justify-between items-center mb-1';

    const label = document.createElement('span');
    label.className = 'text-[11px] font-bold text-stone-500 uppercase';
    label.textContent = m.timeFrameLabel || '';

    const date = document.createElement('span');
    date.className = 'text-[11px] font-semibold text-stone-600';
    date.textContent = m.targetDate || '';

    header.appendChild(label);
    header.appendChild(date);

    const title = document.createElement('h4');
    title.className = 'text-xs font-bold text-stone-900';
    title.textContent = m.title || '';

    const desc = document.createElement('p');
    desc.className = 'text-[11px] text-stone-600 mt-0.5';
    desc.textContent = m.description || '';

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
export function renderVendors(vendors, container) {
  if (typeof document === 'undefined' || typeof document.createElement !== 'function') return;
  const targetEl = typeof container === 'string' ? document.querySelector(container) : container;
  if (!targetEl || !Array.isArray(vendors)) return;

  targetEl.replaceChildren();
  targetEl.setAttribute('aria-live', 'polite');

  const list = document.createElement('ul');
  list.className = 'space-y-3';

  for (const v of vendors) {
    const li = document.createElement('li');
    li.className = 'p-3 bg-white rounded-lg border border-stone-200';

    const title = document.createElement('h4');
    title.className = 'text-xs font-bold text-stone-900';
    title.textContent = `${v.category}: ${v.name}`;

    const lead = document.createElement('span');
    lead.className = 'inline-block text-[10px] font-semibold text-stone-500 mt-1';
    lead.textContent = `Lead time: ${v.leadTime || 'Standard'}`;

    li.appendChild(title);
    li.appendChild(lead);
    list.appendChild(li);
  }

  targetEl.appendChild(list);
}
