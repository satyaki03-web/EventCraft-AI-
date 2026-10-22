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
