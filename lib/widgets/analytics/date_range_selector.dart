import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSelector extends StatelessWidget {
  final String selectedPreset;
  final DateTimeRange? customRange;
  final Function(String) onPresetSelected;
  final Function(DateTimeRange) onCustomRangeSelected;

  const DateRangeSelector({
    super.key,
    required this.selectedPreset,
    this.customRange,
    required this.onPresetSelected,
    required this.onCustomRangeSelected,
  });

  static const List<String> presets = [
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
    'All Time',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index < presets.length) {
                final preset = presets[index];
                final isActive = selectedPreset == preset;
                return _PresetChip(
                  label: preset,
                  isActive: isActive,
                  onTap: () => onPresetSelected(preset),
                );
              }

              // Custom range chip
              final isCustom = selectedPreset == 'Custom';
              return _PresetChip(
                label: isCustom && customRange != null
                    ? '${DateFormat('MM/dd').format(customRange!.start)}-${DateFormat('MM/dd').format(customRange!.end)}'
                    : 'Custom',
                isActive: isCustom,
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: now,
                    initialDateRange: customRange ?? DateTimeRange(
                      start: now.subtract(const Duration(days: 30)),
                      end: now,
                    ),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: const Color(0xFF00BFA6),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    onCustomRangeSelected(picked);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00BFA6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF00BFA6) : Colors.grey.shade300,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF00BFA6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
