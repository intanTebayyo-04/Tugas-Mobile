
import 'package:flutter/material.dart';

class TopNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const TopNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = [
      {
        'label': 'Beranda',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
      },
      {
        'label': 'Tentang',
        'icon': Icons.info_outline,
        'activeIcon': Icons.info,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(destinations.length, (index) {
          final isSelected = selectedIndex == index;
          final destination = destinations[index];

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected
                        ? destination['activeIcon'] as IconData
                        : destination['icon'] as IconData,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(destination['label'] as String),
                ],
              ),
              onSelected: (_) => onDestinationSelected(index),
            ),
          );
        }),
      ),
    );
  }
}
