import 'package:flutter/material.dart';
import '../constants.dart';

class FilterTag extends StatelessWidget {
  final String label;
  final bool active;

  const FilterTag({
    required this.label,
    this.active = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.sidebarItemActive : Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.textLight : AppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
