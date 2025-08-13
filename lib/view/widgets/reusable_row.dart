import 'package:flutter/material.dart';

class ReusabelRow extends StatelessWidget {
  final String title, value;
  const ReusabelRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    final valueStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: titleStyle),
              Text(value, style: valueStyle),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
