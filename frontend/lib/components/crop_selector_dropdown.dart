import 'package:flutter/material.dart';
import '../constants/theme.dart';

class CropSelectorDropdown extends StatelessWidget {
  final String selectedCrop;
  final ValueChanged<String?> onChanged;
  final bool includeAllOption;

  static const List<String> crops = ['Guava', 'Papaya', 'Brinjal', 'Castor', 'Cumin'];

  const CropSelectorDropdown({
    Key? key,
    required this.selectedCrop,
    required this.onChanged,
    this.includeAllOption = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = includeAllOption ? ['All', ...crops] : crops;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: list.contains(selectedCrop) ? selectedCrop : list.first,
          isExpanded: true,
          icon: const Icon(Icons.eco, color: AppTheme.primaryGreen),
          items: list.map((crop) {
            return DropdownMenuItem<String>(
              value: crop,
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: AppTheme.accentLeaf),
                  const SizedBox(width: 8),
                  Text(
                    crop,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
