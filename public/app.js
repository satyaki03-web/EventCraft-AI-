/**
 * Frontend JavaScript module for EventCraft AI.
 * Securely communicates with the Gemini API via Netlify Serverless Function proxy
 * to prevent exposure of API keys on the client side.
 */

const FALLBACK_ERROR_MESSAGE = 'The AI is currently resting. Please try again.';

function updateUIErrorState(message = FALLBACK_ERROR_MESSAGE) {
  const targetSelectors = [
    '#ai-error',
    '#error-message',
    '#ai-status',
    '#ai-response',
    '#event-output',
    '.ai-error-message',
    '.ai-status-message'
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
    if (!fallbackEl) {
      fallbackEl = document.createElement('div');
      fallbackEl.id = 'ai-error';
      document.body.appendChild(fallbackEl);
    }
    fallbackEl.textContent = message;
    fallbackEl.style.display = 'block';
  }
}

async function generateEvent(promptInput) {
  const prompt = typeof promptInput === 'string' 
    ? promptInput 
    : (promptInput && promptInput.prompt ? promptInput.prompt : JSON.stringify(promptInput || ''));

  try {
    const response = await fetch('/.netlify/functions/generate-event', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ prompt }),
    });

    if (!response.ok) {
      throw new Error(`Proxy returned status ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    updateUIErrorState(FALLBACK_ERROR_MESSAGE);
    return null;
  }
}

if (typeof window !== 'undefined') {
  window.generateEvent = generateEvent;
  window.generateEventWithGemini = generateEvent;
  window.callGemini = generateEvent;
  window.updateUIErrorState = updateUIErrorState;
}
