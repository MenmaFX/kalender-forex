enum ImpactLevel { high, medium, low, holiday, unknown }

enum SignalRecommendation {
  strongSellGoldBtc, // Dolar Kuat -> Emas & BTC Turun -> SELL
  strongBuyGoldBtc,  // Dolar Lemah -> Emas & BTC Naik -> BUY
  neutral,           // Netral / Wait & see
  notApplicable,     // Non-USD atau belum rilis
}

class EconomicEvent {
  final String title;
  final String country;
  final DateTime date;
  final String impact;
  final String forecast;
  final String previous;
  final String actual;

  EconomicEvent({
    required this.title,
    required this.country,
    required this.date,
    required this.impact,
    required this.forecast,
    required this.previous,
    this.actual = '',
  });

  ImpactLevel get impactLevel {
    switch (impact.toLowerCase()) {
      case 'high':
        return ImpactLevel.high;
      case 'medium':
      case 'med':
        return ImpactLevel.medium;
      case 'low':
        return ImpactLevel.low;
      case 'holiday':
        return ImpactLevel.holiday;
      default:
        return ImpactLevel.unknown;
    }
  }

  factory EconomicEvent.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date'] ?? '').toLocal();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return EconomicEvent(
      title: json['title'] ?? '',
      country: json['country'] ?? '',
      date: parsedDate,
      impact: json['impact'] ?? 'Low',
      forecast: json['forecast']?.toString() ?? '',
      previous: json['previous']?.toString() ?? '',
      actual: json['actual']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'country': country,
      'date': date.toIso8601String(),
      'impact': impact,
      'forecast': forecast,
      'previous': previous,
      'actual': actual,
    };
  }

  EconomicEvent copyWith({
    String? title,
    String? country,
    DateTime? date,
    String? impact,
    String? forecast,
    String? previous,
    String? actual,
  }) {
    return EconomicEvent(
      title: title ?? this.title,
      country: country ?? this.country,
      date: date ?? this.date,
      impact: impact ?? this.impact,
      forecast: forecast ?? this.forecast,
      previous: previous ?? this.previous,
      actual: actual ?? this.actual,
    );
  }

  // Helper untuk parsing angka dari string (contoh: "3.2%", "250K", "-1.5B")
  static double? _parseNumeric(String text) {
    if (text.isEmpty) return null;
    final cleaned = text.replaceAll(RegExp(r'[^0-9.-]'), '');
    return double.tryParse(cleaned);
  }

  // Evaluasi Performa Rilis (Lebih Baik / Lebih Buruk dari Perkiraan)
  // return: 1 (Lebih baik), -1 (Lebih buruk), 0 (Sama/Belum rilis)
  int get outcomeComparison {
    if (actual.isEmpty || forecast.isEmpty) return 0;
    final actVal = _parseNumeric(actual);
    final fctVal = _parseNumeric(forecast);
    if (actVal == null || fctVal == null) return 0;

    // Untuk berita pengangguran/klaim klaim (Unemployment, Jobless Claims), angka lebih rendah berarti ekonomi LEBIH BAGUS
    final isInverse = title.toLowerCase().contains('unemployment') ||
        title.toLowerCase().contains('jobless');

    if (actVal > fctVal) {
      return isInverse ? -1 : 1;
    } else if (actVal < fctVal) {
      return isInverse ? 1 : -1;
    }
    return 0;
  }

  // Analisa Sinyal Khusus XAU/USD (Emas) & BTC/USD
  SignalRecommendation get signalRecommendation {
    if (country.toUpperCase() != 'USD') return SignalRecommendation.notApplicable;
    if (actual.isEmpty) return SignalRecommendation.notApplicable;

    final comp = outcomeComparison;
    if (comp > 0) {
      // Data USD Bagus -> USD Menguat -> Emas & BTC Tertekan (SELL)
      return SignalRecommendation.strongSellGoldBtc;
    } else if (comp < 0) {
      // Data USD Jelek -> USD Melemah -> Emas & BTC Terdongkrak (BUY)
      return SignalRecommendation.strongBuyGoldBtc;
    }
    return SignalRecommendation.neutral;
  }

  // Bendera Emoji berdasarkan Kode Negara/Mata Uang
  String get flagEmoji {
    switch (country.toUpperCase()) {
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'JPY':
        return '🇯🇵';
      case 'AUD':
        return '🇦🇺';
      case 'CAD':
        return '🇨🇦';
      case 'CHF':
        return '🇨🇭';
      case 'NZD':
        return '🇳🇿';
      case 'CNY':
        return '🇨🇳';
      case 'IDR':
        return '🇮🇩';
      case 'SGD':
        return '🇸🇬';
      case 'ALL':
        return '🌐';
      default:
        return '🌐';
    }
  }

  // Penjelasan Edukasi Ramah Pemula
  String get beginnerExplanation {
    final lower = title.toLowerCase();
    if (lower.contains('cpi') || lower.contains('inflation')) {
      return 'Indeks Harga Konsumen (CPI) mengukur kenaikan harga barang/inflasi. Jika angka aktual tinggi, bank sentral cenderung menaikkan suku bunga. Dolar biasanya menguat, sedangkan Emas & Kripto cenderung turun.';
    } else if (lower.contains('non-farm') || lower.contains('nfp') || lower.contains('payrolls')) {
      return 'Non-Farm Payrolls (NFP) menghitung penambahan tenaga kerja baru di AS. Angka yang melampaui ramalan membuktikan lapangan kerja kokoh, memicu lonjakan Dolar dan koreksi tajam pada Emas.';
    } else if (lower.contains('interest rate') || lower.contains('fed') || lower.contains('rate')) {
      return 'Keputusan Suku Bunga merupakan penggerak utama pasar finansial. Suku bunga tinggi membuat simpanan Dolar lebih diminati, sementara aset tanpa bunga seperti Emas kerap ditinggalkan.';
    } else if (lower.contains('unemployment') || lower.contains('jobless')) {
      return 'Klaim Pengangguran melacak berapa banyak warga mengajukan tunjangan. Semakin rendah angkanya, semakin sehat ekonomi negara tersebut.';
    } else if (lower.contains('gdp') || lower.contains('gross domestic')) {
      return 'Pertumbuhan Ekonomi (PDB/GDP) mencerminkan nilai total produksi barang & jasa. Pertumbuhan yang subur memperkuat mata uang lokal.';
    } else if (lower.contains('retail sales')) {
      return 'Penjualan Ritel mengukur kekuatan belanja masyarakat. Jika rakyat rajin berbelanja, ekonomi bertumbuh pesat dan mata uang terdorong naik.';
    } else if (lower.contains('pmi')) {
      return 'Indeks Manajer Pembelian (PMI) mengukur optimisme para bos pabrik & bisnis. Angka di atas 50 berarti bisnis sedang berekspansi pesat.';
    } else {
      return 'Berita kalender ekonomi ini dapat memicu fluktuasi pergerakan harga jangka pendek pada pasangan mata uang terkait serta aset komoditas seperti Emas (XAU/USD).';
    }
  }
}

class HistoricalRelease {
  final DateTime date;
  final String actual;
  final String forecast;
  final String previous;

  HistoricalRelease({
    required this.date,
    required this.actual,
    required this.forecast,
    required this.previous,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'actual': actual,
    'forecast': forecast,
    'previous': previous,
  };

  factory HistoricalRelease.fromJson(Map<String, dynamic> json) => HistoricalRelease(
    date: DateTime.parse(json['date']),
    actual: json['actual'] ?? '',
    forecast: json['forecast'] ?? '',
    previous: json['previous'] ?? '',
  );
}
