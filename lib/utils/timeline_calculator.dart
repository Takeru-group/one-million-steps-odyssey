import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

/// 計算結果を保持するデータモデル
class AppDateResult {
  final String era; // '紀元前' または '西暦' (または 'BCE' / 'CE')
  final int year; // 年（例: 713）
  final int month; // 月（例: 9）
  final int day; // 日（例: 13）

  AppDateResult({
    required this.era,
    required this.year,
    required this.month,
    required this.day,
  });

  /// 表示用フォーマット (例: "紀元前713年9月13日")
  String toJapaneseString() => '$era${year}年$month月$day日';

  /// 🌐 多言語（l10n）対応の表示フォーマット
  String toLocalizedFormattedString(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return toJapaneseString();

    if (era == '紀元前' || era == 'BCE') {
      return l10n.dateBceFormat(year, month, day);
    } else {
      return l10n.dateCeFormat(year, month, day);
    }
  }

  /// ISO風フォーマット (例: "BCE 0713-09-13" や "CE 2026-08-11")
  String toIsoFormat() {
    final eraCode = (era == '紀元前' || era == 'BCE') ? 'BCE' : 'CE';
    return '$eraCode ${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  /// 世紀（int）を算出
  /// 紀元前（BC）: 前1年〜100年 ➔ 前1世紀、前101年〜200年 ➔ 前2世紀、前201年〜300年 ➔ 前3世紀
  /// 西暦（AD）: 1〜99年 ➔ 1世紀、100〜199年（100年代） ➔ 2世紀、200〜299年（200年代） ➔ 3世紀
  int get century {
    if (era == '紀元前' || era == 'BCE') {
      final c = ((year - 1) ~/ 100) + 1;
      return -c;
    } else {
      return (year ~/ 100) + 1;
    }
  }

  /// 10年単位の年代（Decade）表示用ラベル生成（例: 前109年 ➔ BC100年代）
  String get eraLabel {
    final isBce = (era == '紀元前' || era == 'BCE');
    final prefix = isBce ? 'BC' : 'AD';
    final roundedYear = (year ~/ 10) * 10;
    return '$prefix$roundedYear';
  }

  @override
  String toString() => toJapaneseString();
}

/// タイムライン・日付計算ロジックをまとめたクラス
class TimelineCalculator {
  /// 1. 基準日（西暦）から1,000,000日前（アプリ開始日）を算出
  static AppDateResult calculateAppStartDate(
    DateTime baseDate, {
    int daysToSubtract = 1000000,
  }) {
    final currentJdn = _dateToJdn('西暦', baseDate.year, baseDate.month, baseDate.day);
    final targetJdn = currentJdn - daysToSubtract;
    return _jdnToAppDate(targetJdn);
  }

  /// 2. 指定した「紀元・年・月・日」から「歩数（または日数）」分進んだ日付を算出
  static AppDateResult addStepsToDate({
    required String era,
    required int year,
    required int month,
    required int day,
    required int steps,
    int stepsPerDay = 1,
  }) {
    final daysToAdd = steps ~/ stepsPerDay;

    return addDaysToDate(
      era: era,
      year: year,
      month: month,
      day: day,
      daysToAdd: daysToAdd,
    );
  }

  /// 3. 指定した「紀元・年・月・日」から「指定日数」進んだ日付を直接算出
  static AppDateResult addDaysToDate({
    required String era,
    required int year,
    required int month,
    required int day,
    required int daysToAdd,
  }) {
    final baseJdn = _dateToJdn(era, year, month, day);
    final targetJdn = baseJdn + daysToAdd;
    return _jdnToAppDate(targetJdn);
  }

  // --- 内部ヘルパー関数 (JDNアルゴリズム - 天文学的0年補正含む) ---

  /// 日付 ➔ ユリウス日(JDN) 変換（西暦1年の前日は紀元前1年）
  static int _dateToJdn(String era, int year, int month, int day) {
    final rawYear = (era == '紀元前' || era == 'BCE') ? -(year - 1) : year;
    final a = (14 - month) ~/ 12;
    final y = rawYear + 4800 - a;
    final m = month + 12 * a - 3;
    return day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
  }

  /// ユリウス日(JDN) ➔ AppDateResult 変換
  static AppDateResult _jdnToAppDate(int jdn) {
    final f = jdn + 1401 + (((4 * jdn + 274274) ~/ 146097) * 3) ~/ 4 - 38;
    final e = 4 * f + 3;
    final g = (e % 1461) ~/ 4;
    final h = 5 * g + 2;

    final resDay = (h % 153) ~/ 5 + 1;
    final resMonth = (h ~/ 153 + 2) % 12 + 1;
    final rawYear = (e ~/ 1461) - 4716 + (12 + 2 - resMonth) ~/ 12;

    final era = (rawYear <= 0) ? '紀元前' : '西暦';
    final resYear = (rawYear <= 0) ? rawYear.abs() + 1 : rawYear;

    return AppDateResult(
      era: era,
      year: resYear,
      month: resMonth,
      day: resDay,
    );
  }
}