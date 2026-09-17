import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_settings_provider.dart';
import '../services/app_strings.dart';
import '../widgets/app_theme.dart';

class FilterDialog extends StatelessWidget {
  final AppSettingsProvider settings;

  const FilterDialog({Key? key, required this.settings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = settings.isDarkMode;
    final lang = settings.language;

    final impacts = [
      {'name': 'High', 'label': AppStrings.impactHighLabel(lang), 'color': AppTheme.impactHigh},
      {'name': 'Medium', 'label': AppStrings.impactMediumLabel(lang), 'color': AppTheme.impactMedium},
      {'name': 'Low', 'label': AppStrings.impactLowLabel(lang), 'color': AppTheme.impactLow},
    ];

    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'NZD'];

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF181B22) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          const Icon(Icons.tune_rounded, color: AppTheme.myfxOrange, size: 20),
          const SizedBox(width: 8),
          Text(
            AppStrings.filterTitle(lang),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppStrings.impactLevel(lang)}:',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            ...impacts.map((item) {
              final name = item['name'] as String;
              final label = item['label'] as String;
              final color = item['color'] as Color;
              final isSelected = settings.impactFilter.contains(name);

              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.myfxOrange,
                title: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                value: isSelected,
                onChanged: (_) {
                  HapticFeedback.selectionClick();
                  settings.toggleImpactFilter(name);
                },
              );
            }).toList(),

            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 6),

            Text(
              '${AppStrings.currencies(lang)}:',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: currencies.map((curr) {
                final isSelected = settings.currencyFilter.contains(curr);
                return FilterChip(
                  label: Text(
                    curr,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.black
                          : (isDark ? Colors.white : const Color(0xFF212121)),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.myfxOrange,
                  checkmarkColor: Colors.black,
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    settings.toggleCurrencyFilter(curr);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
          },
          child: Text(
            AppStrings.close(lang),
            style: GoogleFonts.inter(color: AppTheme.myfxOrange, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
