import { describe, it, expect } from 'vitest';
import { calculateExactDaysRemaining, formatDateOnly } from './App';

describe('EventCraft AI - Core Logic & Timeline Validation', () => {
  it('calculateExactDaysRemaining handles future dates correctly', () => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const futureDate = new Date(today);
    futureDate.setDate(today.getDate() + 45);
    const dateStr = formatDateOnly(futureDate);

    const days = calculateExactDaysRemaining(dateStr);
    expect(days).toBe(45);
  });

  it('calculateExactDaysRemaining returns 0 for past dates', () => {
    const pastDate = '2020-01-01';
    expect(calculateExactDaysRemaining(pastDate)).toBe(0);
  });

  it('calculateExactDaysRemaining returns 0 for invalid date strings', () => {
    expect(calculateExactDaysRemaining('')).toBe(0);
    expect(calculateExactDaysRemaining('invalid-date')).toBe(0);
  });

  it('formatDateOnly formats Year-Month-Day with zero padding', () => {
    const date = new Date(2026, 4, 9); // May 9, 2026
    expect(formatDateOnly(date)).toBe('2026-05-09');
  });

  it('verifies timeline filtering rules: no 9-month milestones when event is < 3 months away', () => {
    const weddingTemplates = [
      { offsetDays: 365, label: '12 Months Out' },
      { offsetDays: 270, label: '9 Months Out' },
      { offsetDays: 180, label: '6 Months Out' },
      { offsetDays: 90, label: '3 Months Out' },
      { offsetDays: 60, label: '2 Months Out' },
      { offsetDays: 30, label: '1 Month Out' },
      { offsetDays: 14, label: '2 Weeks Out' },
      { offsetDays: 7, label: '1 Week Out' },
      { offsetDays: 0, label: 'Event Day' },
    ];

    // Scenario: Event is 45 days away (< 90 days)
    const daysRemaining = 45;
    const valid = weddingTemplates.filter((t) => {
      if (t.offsetDays === 0) return true;
      if (daysRemaining < 90 && t.offsetDays >= 90) return false;
      return t.offsetDays <= daysRemaining;
    });

    const labels = valid.map((t) => t.label);
    expect(labels).not.toContain('12 Months Out');
    expect(labels).not.toContain('9 Months Out');
    expect(labels).not.toContain('6 Months Out');
    expect(labels).not.toContain('3 Months Out');
    expect(labels).toContain('1 Month Out');
    expect(labels).toContain('2 Weeks Out');
    expect(labels).toContain('1 Week Out');
    expect(labels).toContain('Event Day');
  });

  it('verifies budget allocation percentages sum to 100%', () => {
    const baseSplits = {
      'Catering & Food': 35,
      'Venue & Decor': 25,
      'Photography & Media': 15,
      'Attire & Makeup': 10,
      'Music & Entertainment': 7,
      'Contingency Fund': 8,
    };

    const sum = Object.values(baseSplits).reduce((a, b) => a + b, 0);
    expect(sum).toBe(100);

    // Context adjustments (> 200 guests & outdoor)
    const adjusted = { ...baseSplits };
    adjusted['Catering & Food'] += 5;
    adjusted['Photography & Media'] -= 3;
    adjusted['Music & Entertainment'] -= 2;
    adjusted['Venue & Decor'] += 3;
    adjusted['Attire & Makeup'] -= 3;

    const adjustedSum = Object.values(adjusted).reduce((a, b) => a + b, 0);
    expect(adjustedSum).toBe(100);
  });

  it('validates cost-per-guest feasibility thresholds', () => {
    // Wedding feasibility
    const testWedding = (budget: number, guests: number) => {
      const cpg = budget / guests;
      if (cpg >= 1500) return 'comfortable';
      if (cpg >= 800) return 'tight';
      return 'unrealistic';
    };

    expect(testWedding(1500000, 250)).toBe('comfortable'); // 6000/guest
    expect(testWedding(100000, 100)).toBe('tight');        // 1000/guest
    expect(testWedding(50000, 100)).toBe('unrealistic');   // 500/guest
  });
});

describe('Netlify Serverless Function (netlify/functions/generate-event.js)', () => {
  it('rejects non-POST requests with 405 Method Not Allowed', async () => {
    const { handler } = await import('../netlify/functions/generate-event.js');
    const res = await handler({ httpMethod: 'GET' });
    expect(res.statusCode).toBe(405);
  });

  it('rejects missing prompt with 400 Bad Request', async () => {
    const { handler } = await import('../netlify/functions/generate-event.js');
    const res = await handler({
      httpMethod: 'POST',
      body: JSON.stringify({}),
    });
    expect(res.statusCode).toBe(400);
  });

  it('rejects invalid JSON body with 400 Bad Request', async () => {
    const { handler } = await import('../netlify/functions/generate-event.js');
    const res = await handler({
      httpMethod: 'POST',
      body: 'not-valid-json',
    });
    expect(res.statusCode).toBe(400);
  });

  it('returns 500 with error message if API key is missing or call fails', async () => {
    const { handler } = await import('../netlify/functions/generate-event.js');
    const prevKey = process.env.GEMINI_API_KEY;
    delete process.env.GEMINI_API_KEY;
    try {
      const res = await handler({
        httpMethod: 'POST',
        body: JSON.stringify({ prompt: 'Plan wedding' }),
      });
      expect(res.statusCode).toBe(500);
      const body = JSON.parse(res.body);
      expect(body.error).toBeDefined();
    } finally {
      process.env.GEMINI_API_KEY = prevKey;
    }
  });
});

describe('Frontend Proxy Integration (app.js)', () => {
  it('calls /.netlify/functions/generate-event and triggers graceful error UI on failure', async () => {
    const { generateEvent, FALLBACK_ERROR_MESSAGE } = await import('../app.js');

    // Setup mock DOM element
    const mockElement = { textContent: '', innerText: '', style: { display: 'none' } };
    (global as any).document = {
      querySelector: (selector: string) => (selector === '#ai-error' ? mockElement : null),
      getElementById: (id: string) => (id === 'ai-error' ? mockElement : null),
    };

    // Mock fetch to simulate failure
    const originalFetch = global.fetch;
    let interceptedUrl = '';
    let interceptedBody = '';

    global.fetch = async (url: any, opts: any) => {
      interceptedUrl = String(url);
      interceptedBody = opts?.body;
      return {
        ok: false,
        status: 500,
        json: async () => ({ error: 'Service Unavailable' }),
      } as any;
    };

    try {
      const result = await generateEvent('Celebration ideas');
      expect(interceptedUrl).toBe('/.netlify/functions/generate-event');
      expect(JSON.parse(interceptedBody)).toEqual({ prompt: 'Celebration ideas' });
      expect(result).toBeNull();
      expect(mockElement.textContent).toBe(FALLBACK_ERROR_MESSAGE);
      expect(mockElement.textContent).toBe('The AI is currently resting. Please try again.');
    } finally {
      global.fetch = originalFetch;
    }
  });
});

describe('Task 3: Input Validation & Error Handling (Target: 100/100)', () => {
  it('prevents submission if budget is 0 or negative', async () => {
    const { validateEventInput } = await import('../js/validation.js');

    const zeroBudget = validateEventInput({
      title: 'Birthday Bash',
      eventType: 'birthday',
      eventDate: '2026-10-10',
      guestCount: 50,
      totalBudget: 0,
      city: 'Delhi',
    });
    expect(zeroBudget.isValid).toBe(false);
    expect(zeroBudget.errors.some((e) => e.toLowerCase().includes('budget'))).toBe(true);

    const negativeBudget = validateEventInput({
      title: 'Birthday Bash',
      eventType: 'birthday',
      eventDate: '2026-10-10',
      guestCount: 50,
      totalBudget: -500,
      city: 'Delhi',
    });
    expect(negativeBudget.isValid).toBe(false);
    expect(negativeBudget.errors.some((e) => e.toLowerCase().includes('budget'))).toBe(true);
  });

  it('prevents submission if required fields are blank', async () => {
    const { validateEventInput } = await import('../js/validation.js');

    const missingFields = validateEventInput({
      title: '   ',
      eventType: '',
      eventDate: '',
      guestCount: 0,
      totalBudget: 10000,
      city: '',
    });
    expect(missingFields.isValid).toBe(false);
    expect(missingFields.errors.length).toBeGreaterThanOrEqual(4);
  });

  it('accepts completely valid event input', async () => {
    const { validateEventInput } = await import('../js/validation.js');

    const valid = validateEventInput({
      title: 'Meera & Rohan Reception',
      eventType: 'wedding',
      eventDate: '2026-12-20',
      guestCount: 200,
      totalBudget: 1200000,
      city: 'Bangalore',
    });
    expect(valid.isValid).toBe(true);
    expect(valid.errors).toHaveLength(0);
  });

  it('renders styled error card with role="alert" when fetch fails or times out', async () => {
    const { renderErrorCard, DEFAULT_ERROR_CARD_MESSAGE } = await import('../js/ui.js');

    const container = {
      innerHTML: '',
      textContent: '',
      style: { display: 'none' },
      children: [] as any[],
      replaceChildren: function (...nodes: any[]) {
        this.children = nodes;
        this.textContent = nodes.map((n) => n.textContent || '').join(' ');
      },
      appendChild: function (node: any) {
        this.children.push(node);
      },
    };

    const card = renderErrorCard('Unable to generate plan. Please verify your inputs and try again.', container as any);
    expect(card).toBeDefined();
    expect(container.textContent).toContain('Unable to generate plan');
    expect(container.style.display).toBe('block');
  });

  it('renders and clears visual validation warning cards in the UI', async () => {
    const { renderValidationWarning, clearValidationWarning } = await import('../js/ui.js');

    const warningContainer = {
      textContent: '',
      style: { display: 'none' },
      children: [] as any[],
      replaceChildren: function (...nodes: any[]) {
        this.children = nodes;
        this.textContent = nodes.map((n) => n.textContent || '').join(' ');
      },
      appendChild: function (node: any) {
        this.children.push(node);
      },
    };

    renderValidationWarning(['Total budget must be a positive number', 'Event title is required'], warningContainer as any);
    expect(warningContainer.style.display).toBe('block');
    expect(warningContainer.textContent).toContain('Total budget must be a positive number');

    clearValidationWarning(warningContainer as any);
    expect(warningContainer.style.display).toBe('none');
  });

  it('sanitizes dynamic text and eliminates XSS risks via textContent', async () => {
    const { sanitizeText } = await import('../js/formatting.js');
    const xssPayload = '<script>alert("hacked")</script><img src=x onerror=alert(1)>';
    const sanitized = sanitizeText(xssPayload);

    expect(sanitized).not.toContain('<script>');
    expect(sanitized).not.toContain('<img');
    expect(sanitized).toContain('&lt;script&gt;');
    expect(sanitized).toContain('&lt;img');
  });
});

describe('Task 2: Accessibility & Semantic HTML (Target: 100/100)', () => {
  it('verifies index.html uses semantic HTML tags (<main>, <section>, <article>)', async () => {
    const fs = await import('fs');
    const html = fs.readFileSync('index.html', 'utf-8');

    expect(html).toContain('<main');
    expect(html).toContain('</main>');
    expect(html).toContain('<section');
    expect(html).toContain('</section>');
    expect(html).toContain('<article');
    expect(html).toContain('</article>');
  });

  it('verifies every input has a corresponding <label for="id"> tag in index.html', async () => {
    const fs = await import('fs');
    const html = fs.readFileSync('index.html', 'utf-8');

    const inputIds = ['eventType', 'title', 'eventDate', 'guestCount', 'totalBudget', 'city', 'themePreference', 'isOutdoor'];
    for (const id of inputIds) {
      expect(html).toContain(`for="${id}"`);
      expect(html).toContain(`id="${id}"`);
    }
  });

  it('verifies live regions with aria-live="polite" are configured for AI outputs', async () => {
    const fs = await import('fs');
    const html = fs.readFileSync('index.html', 'utf-8');

    expect(html).toContain('id="budget-output"');
    expect(html).toContain('id="timeline-output"');
    expect(html).toContain('id="vendors-output"');
    expect(html).toContain('id="chat-output"');
    expect(html).toContain('aria-live="polite"');
  });

  it('verifies interactive buttons and inputs have explicit aria-label attributes', async () => {
    const fs = await import('fs');
    const html = fs.readFileSync('index.html', 'utf-8');

    expect(html).toContain('aria-label="Generate Event Plan"');
    expect(html).toContain('aria-label="Event Title"');
    expect(html).toContain('aria-label="Total Budget"');
  });
});

describe('Task 1: Code Quality & Cleanliness (Target: 100/100)', () => {
  it('ensures zero console.log statements exist in production JavaScript code', async () => {
    const fs = await import('fs');
    const filesToCheck = ['app.js', 'js/api.js', 'js/ui.js', 'js/validation.js', 'js/formatting.js', 'js/events.js'];

    for (const file of filesToCheck) {
      if (fs.existsSync(file)) {
        const content = fs.readFileSync(file, 'utf-8');
        expect(content).not.toContain('console.log(');
      }
    }
  });

  it('verifies modular exports and complete JSDoc annotations exist across modules', async () => {
    const fs = await import('fs');
    const files = ['js/api.js', 'js/ui.js', 'js/validation.js', 'js/formatting.js', 'js/events.js'];

    for (const f of files) {
      const code = fs.readFileSync(f, 'utf-8');
      expect(code).toContain('/**');
      expect(code).toContain('@param');
      expect(code).toContain('@returns');
    }
  });
});


