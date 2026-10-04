import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/user_model.dart';

class StepsView extends StatelessWidget {
  final UserModel? userData;
  final List<Map<String, dynamic>> pastWeeklySteps;

  const StepsView({
    super.key,
    required this.userData,
    required this.pastWeeklySteps,
  });

  String _formatDate(dynamic date) {
    if (date == null) return '----/--/--';
    DateTime dt;
    if (date is Timestamp) {
      dt = date.toDate().toLocal();
    } else if (date is DateTime) {
      dt = date.toLocal();
    } else if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed == null) return date;
      dt = parsed.toLocal();
    } else {
      return '----/--/--';
    }
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  /// 年月日 ＋ 時分秒フォーマット (例: 2026/09/08 14:30:15)
  String _formatDateTime(dynamic date) {
    if (date == null) return '----/--/-- --:--:--';
    DateTime dt;
    if (date is Timestamp) {
      dt = date.toDate().toLocal();
    } else if (date is DateTime) {
      dt = date.toLocal();
    } else if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed == null) return date;
      dt = parsed.toLocal();
    } else {
      return '----/--/-- --:--:--';
    }
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor = isDarkMode
        ? Colors.black.withOpacity(0.40)
        : Colors.white.withOpacity(0.40);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.50);
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    final now = DateTime.now();
    final startDateStr = _formatDate(now.subtract(const Duration(days: 6)));
    final endDateStr = _formatDate(now);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧊 1. 歩数概要パネル
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 本日の歩数
                    Text(
                      l10n.stepsToday(userData?.steps ?? 0),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.stepsUpdatedAt(_formatDateTime(DateTime.now())),
                      style: TextStyle(fontSize: 12, color: subTextColor),
                    ),

                    const SizedBox(height: 16),
                    Divider(color: borderColor, height: 1),
                    const SizedBox(height: 16),

                    // 累計（総）歩数
                    Text(
                      l10n.stepsTotal(userData?.totalSteps ?? 0),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ⭕️ userData.appStartDate（アカウント作成・初回登録日時）を表示
                    Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 14, color: subTextColor),
                        const SizedBox(width: 4),
                        Text(
                          l10n.stepsStartDate(_formatDateTime(userData?.appStartDate)),
                          style: TextStyle(fontSize: 12, color: subTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🧊 2. 過去7日間の歩数パネル
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.stepsPast7Days,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$startDateStr ~ $endDateStr',
                      style: TextStyle(fontSize: 12, color: subTextColor),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 240,
                      child: pastWeeklySteps.isEmpty
                          ? const SizedBox.shrink()
                          : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 15000,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (_) => Colors.deepPurple
                                        .withOpacity(0.85),
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        l10n.stepsChartTooltip(
                                            rod.toY.toInt()),
                                        const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        if (value % 5000 == 0) {
                                          return Text(
                                            '${(value / 1000).toInt()}k',
                                            style: TextStyle(
                                                color: subTextColor,
                                                fontSize: 11),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index >= 0 &&
                                            index < pastWeeklySteps.length) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              pastWeeklySteps[index]
                                                  ['dayLabel'],
                                              style: TextStyle(
                                                color: primaryTextColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: borderColor,
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups:
                                    pastWeeklySteps.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final steps =
                                      (entry.value['steps'] as num).toDouble();
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: steps,
                                        color: isDarkMode
                                            ? Colors.purpleAccent[100]
                                            : Colors.deepPurple,
                                        width: 16,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(6)),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}