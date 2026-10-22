/// Utility class for formatting currency and dates without external locale bloat.
class AppFormatters {
  /// Format currency amount with symbol and thousands separators.
  static String formatCurrency(double amount, {String symbol = '₹'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(0).split('');
    final buffer = StringBuffer();

    int count = 0;
    for (int i = parts.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(parts[i]);
      count++;
    }

    final formattedInt = buffer.toString().split('').reversed.join('');
    final signStr = isNegative ? '-' : '';
    return '$signStr$symbol$formattedInt';
  }

  /// Format date to YYYY-MM-DD string.
  static String formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Human friendly date display e.g. "Oct 24, 2026"
  static String formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final monthStr = months[date.month - 1];
    return '$monthStr ${date.day}, ${date.year}';
  }
}
