import 'package:flutter/material.dart';
import 'package:covid_tracker/theme/app_colors.dart';

class PillChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const PillChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: alpha(color, 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: alpha(color, 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
