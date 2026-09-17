import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'app_theme.dart';

class CalendarShimmerLoading extends StatelessWidget {
  final bool isDark;

  const CalendarShimmerLoading({Key? key, required this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? const Color(0xFF1E222A) : const Color(0xFFE2E6EC);
    final highlightColor = isDark ? const Color(0xFF2C323E) : const Color(0xFFF4F6F9);

    return ListView.builder(
      itemCount: 8,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF23272F) : const Color(0xFFEDEFF3),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Strip + Waktu shimmer
                Container(
                  width: 3.5,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 35, height: 12, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 25, height: 9, color: Colors.white),
                  ],
                ),
                const SizedBox(width: 14),
                // Bendera & Mata uang
                Container(
                  width: 36,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                // Judul & Metrik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 140,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(width: 45, height: 10, color: Colors.white),
                          const SizedBox(width: 14),
                          Container(width: 45, height: 10, color: Colors.white),
                          const SizedBox(width: 14),
                          Container(width: 45, height: 10, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
