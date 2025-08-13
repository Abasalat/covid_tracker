import 'package:flutter/material.dart';
import 'package:covid_tracker/theme/app_colors.dart';

class ProgressStatRow extends StatelessWidget {
  final String label;
  final String valueText;
  final double value; // 0..1
  final Color color;

  const ProgressStatRow({
    super.key,
    required this.label,
    required this.valueText,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = alpha(color, 0.15);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(valueText),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: value.clamp(0, 1),
            backgroundColor: bg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
