import 'package:flutter/material.dart';

import '../../data/models/city.dart';

// Chips for quickly switching back to a recently viewed city.
class RecentCitiesList extends StatelessWidget {
  const RecentCitiesList({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onSelected,
  });

  final List<City> cities;
  final City? selectedCity;
  final ValueChanged<City> onSelected;

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = cities[index];
          final selected = city == selectedCity;
          return ChoiceChip(
            label: Text(city.name),
            selected: selected,
            onSelected: (_) => onSelected(city),
          );
        },
      ),
    );
  }
}
