import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BilledItemCard extends StatelessWidget {
  final int index;
  final String weight;
  final String side1;
  final String side2;
  final String average;
  final String pureWeight;
  final bool showActions;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const BilledItemCard({
    super.key,
    required this.index,
    required this.weight,
    required this.side1,
    required this.side2,
    required this.average,
    required this.pureWeight,
    this.showActions = false,
    this.onDelete,
    this.onEdit,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the values are empty or dash placeholder
    final displaySide1 = (side1.isEmpty || side1 == '0.00') ? '----' : side1;
    final displaySide2 = (side2.isEmpty || side2 == '0.00') ? '----' : side2;

    final cardContent = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: showActions ? Colors.transparent : const Color(0xFFEFF6FF), // Soft light-blue tag
                    // border: showActions ? Border.all(color: Colors.white.withValues(alpha: 0.5)) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#$index',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: showActions ? Colors.white : const Color(0xFF2563EB), // Sleek royal blue
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Gross Weight',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: showActions ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            Text(
              weight,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: showActions ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(
          height: 1,
          thickness: 0.5,
          color: showActions ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFE2E8F0),
        ),
        const SizedBox(height: 8),
        _Row(label: 'Side 1', value: displaySide1, isWhiteText: showActions),
        _Row(label: 'Side 2', value: displaySide2, isWhiteText: showActions),
        _Row(
          label: 'Average (%)',
          value: '$average%',
          isBlue: !showActions,
          isWhiteText: showActions,
        ),
        const SizedBox(height: 8),
        Divider(
          height: 1,
          thickness: 0.5,
          color: showActions ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFE2E8F0),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pure Weight',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: showActions ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            Text(
              pureWeight,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: showActions ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: showActions ? const Color(0xFF7E8A9A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: showActions ? Colors.transparent : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Original card content (dimmed when actions are active)
            Padding(
              padding: const EdgeInsets.all(16),
              child: showActions ? Opacity(opacity: 0.35, child: cardContent) : cardContent,
            ),
            
            // Edit & Delete Actions overlay in the center
            if (showActions)
              Positioned.fill(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Delete button
                      ElevatedButton(
                        onPressed: onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00388D),
                          shape: const StadiumBorder(),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Edit button
                      OutlinedButton(
                        onPressed: onEdit,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 1.5),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBlue;
  final bool isWhiteText;

  const _Row({
    required this.label,
    required this.value,
    this.isBlue = false,
    this.isWhiteText = false,
  });

  @override
  Widget build(BuildContext context) {
    Color labelColor = const Color(0xFF64748B);
    Color valueColor = const Color(0xFF475569);

    if (isWhiteText) {
      labelColor = Colors.white.withValues(alpha: 0.8);
      valueColor = Colors.white;
    } else if (isBlue) {
      labelColor = const Color(0xFF2563EB);
      valueColor = const Color(0xFF2563EB);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isBlue ? FontWeight.w600 : FontWeight.w500,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBlue ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
