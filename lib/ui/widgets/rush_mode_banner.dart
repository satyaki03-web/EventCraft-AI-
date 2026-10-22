import 'package:flutter/material.dart';

/// Banner shown when event date is under 30 days away (Rush Mode).
class RushModeBanner extends StatelessWidget {
  const RushModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade700, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, color: Colors.amber.shade900, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚡ RUSH MODE ACTIVE (Under 30 Days)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your timeline has been compressed. Focus on high-priority vendors (Caterer, Venue, Stage) first!',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
