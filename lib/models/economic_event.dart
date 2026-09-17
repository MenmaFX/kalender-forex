enum ImpactLevel { high, medium, low, holiday, unknown }

enum SignalRecommendation {
  strongSellGoldBtc, // Dolar Kuat -> Emas & BTC Turun -> SELL GOLD / BUY USD
  strongBuyGoldBtc,  // Dolar Lemah -> Emas & BTC Naik -> BUY GOLD / SELL USD
  buyCurrency,       // Data kuat untuk mata uang non-USD (misal: BUY EUR)
  sellCurrency,      // Data lemah untuk mata uang non-USD (misal: SELL EUR)
  neutral,           // Netral / Sesuai Ekspektasi
  notApplicable,     // Tidak dapat dihitung
}

enum SignalType {
  buyGold,
  sellGold,
  buyCurrency,
  sellCurrency,
  neutral,
  projectedBuy,
  projectedSell,
  none,
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

  // Proyeksi awal untuk event mendatang (belum rilis): Forecast vs Previous
  // return: 1 (Proyeksi data membaik/menguat), -1 (Proyeksi memburuk/melemah), 0 (Sama / data kurang)
  int get projectionComparison {
    if (actual.isNotEmpty) return 0;
    if (forecast.isEmpty || previous.isEmpty) return 0;
    final fctVal = _parseNumeric(forecast);
    final prevVal = _parseNumeric(previous);
    if (fctVal == null || prevVal == null) return 0;

    final isInverse = title.toLowerCase().contains('unemployment') ||
        title.toLowerCase().contains('jobless');

    if (fctVal > prevVal) {
      return isInverse ? -1 : 1;
    } else if (fctVal < prevVal) {
      return isInverse ? 1 : -1;
    }
    return 0;
  }

  // Analisa Sinyal Berdasarkan Rilis Data Aktual
  SignalRecommendation get signalRecommendation {
    if (actual.isEmpty) return SignalRecommendation.notApplicable;

    final comp = outcomeComparison;
    final c = country.toUpperCase();

    if (c == 'USD') {
      if (comp > 0) {
        // Data USD Bagus -> USD Menguat -> Emas & BTC Tertekan (SELL GOLD / BUY USD)
        return SignalRecommendation.strongSellGoldBtc;
      } else if (comp < 0) {
        // Data USD Jelek -> USD Melemah -> Emas & BTC Terdongkrak (BUY GOLD / SELL USD)
        return SignalRecommendation.strongBuyGoldBtc;
      }
      return SignalRecommendation.neutral;
    } else {
      if (comp > 0) {
        return SignalRecommendation.buyCurrency;
      } else if (comp < 0) {
        return SignalRecommendation.sellCurrency;
      }
      return SignalRecommendation.neutral;
    }
  }

  // Teks Badge Sinyal untuk Kartu Kalender (Default)
  String? get signalBadgeText => signalBadgeTextLocalized('id');

  // Teks Badge Sinyal dengan Dukungan Multi-Bahasa
  String? signalBadgeTextLocalized(String lang) {
    final c = country.toUpperCase();
    final isEn = lang == 'en';

    if (actual.isNotEmpty) {
      // 1. Data Sudah Rilis
      if (c == 'USD') {
        if (outcomeComparison > 0) {
          return 'SELL GOLD';
        } else if (outcomeComparison < 0) {
          return 'BUY GOLD';
        } else {
          return isEn ? 'NEUTRAL' : 'NETRAL';
        }
      } else if (c.isNotEmpty && c != 'ALL') {
        if (outcomeComparison > 0) {
          return 'BUY $c';
        } else if (outcomeComparison < 0) {
          return 'SELL $c';
        } else {
          return isEn ? 'NEUTRAL' : 'NETRAL';
        }
      }
    } else {
      // 2. Data Belum Rilis (Mendatang) -> Tampilkan Proyeksi / Indikasi Arah Dampak
      final proj = projectionComparison;
      final projPrefix = isEn ? 'PROJECTED: ' : 'PROYEKSI: ';
      if (proj != 0) {
        if (c == 'USD') {
          return proj > 0 ? '${projPrefix}SELL GOLD' : '${projPrefix}BUY GOLD';
        } else if (c.isNotEmpty && c != 'ALL') {
          return proj > 0 ? '${projPrefix}BUY $c' : '${projPrefix}SELL $c';
        }
      } else if (impactLevel == ImpactLevel.high) {
        return isEn ? 'WAITING' : 'MENUNGGU RILIS';
      }
    }
    return null;
  }

  // Kategori Tipe Sinyal untuk pewarnaan dan styling badge
  SignalType get signalType {
    final text = signalBadgeText;
    if (text == null) return SignalType.none;
    if (text.contains('BUY GOLD')) {
      return text.contains('PROYEKSI') || text.contains('PROJECTED') ? SignalType.projectedBuy : SignalType.buyGold;
    }
    if (text.contains('SELL GOLD')) {
      return text.contains('PROYEKSI') || text.contains('PROJECTED') ? SignalType.projectedSell : SignalType.sellGold;
    }
    if (text.contains('BUY')) {
      return text.contains('PROYEKSI') || text.contains('PROJECTED') ? SignalType.projectedBuy : SignalType.buyCurrency;
    }
    if (text.contains('SELL')) {
      return text.contains('PROYEKSI') || text.contains('PROJECTED') ? SignalType.projectedSell : SignalType.sellCurrency;
    }
    if (text.contains('NETRAL') || text.contains('NEUTRAL')) return SignalType.neutral;
    return SignalType.none;
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

  // Penjelasan Edukasi Ramah Pemula Multi-Bahasa
  String beginnerExplanationLocalized(String lang) {
    final isEn = lang == 'en';
    final lower = title.toLowerCase();

    if (lower.contains('cpi') || lower.contains('inflation')) {
      return isEn
          ? 'The Consumer Price Index (CPI) measures goods and services inflation. Higher actual inflation leads central banks to raise interest rates, strengthening the currency while putting downward pressure on Gold & Crypto.'
          : 'Indeks Harga Konsumen (CPI) mengukur kenaikan harga barang/inflasi. Jika angka aktual tinggi, bank sentral cenderung menaikkan suku bunga. Dolar biasanya menguat, sedangkan Emas & Kripto cenderung turun.';
    } else if (lower.contains('non-farm') || lower.contains('nfp') || lower.contains('payrolls')) {
      return isEn
          ? 'Non-Farm Payrolls (NFP) tracks newly created US jobs. Outperforming consensus indicates a robust labor market, sparking a Dollar rally and sharp correction in Gold.'
          : 'Non-Farm Payrolls (NFP) menghitung penambahan tenaga kerja baru di AS. Angka yang melampaui ramalan membuktikan lapangan kerja kokoh, memicu lonjakan Dolar dan koreksi tajam pada Emas.';
    } else if (lower.contains('interest rate') || lower.contains('fed') || lower.contains('rate')) {
      return isEn
          ? 'Interest Rate decisions are the primary catalyst of financial markets. Higher interest rates enhance currency yield appeal, causing non-yielding assets like Gold to retreat.'
          : 'Keputusan Suku Bunga merupakan penggerak utama pasar finansial. Suku bunga tinggi membuat simpanan Dolar lebih diminati, sementara aset tanpa bunga seperti Emas kerap ditinggalkan.';
    } else if (lower.contains('unemployment') || lower.contains('jobless')) {
      return isEn
          ? 'Jobless Claims track citizens applying for unemployment benefits. Lower figures indicate a healthier and stronger economy.'
          : 'Klaim Pengangguran melacak berapa banyak warga mengajukan tunjangan. Semakin rendah angkanya, semakin sehat ekonomi negara tersebut.';
    } else if (lower.contains('gdp') || lower.contains('gross domestic')) {
      return isEn
          ? 'Gross Domestic Product (GDP) represents total output of goods and services. Strong growth bolsters the local currency.'
          : 'Pertumbuhan Ekonomi (PDB/GDP) mencerminkan nilai total produksi barang & jasa. Pertumbuhan yang subur memperkuat mata uang lokal.';
    } else if (lower.contains('retail sales')) {
      return isEn
          ? 'Retail Sales evaluate consumer spending momentum. Vigorous consumer expenditure fuels economic growth and drives the currency higher.'
          : 'Penjualan Ritel mengukur kekuatan belanja masyarakat. Jika rakyat rajin berbelanja, ekonomi bertumbuh pesat dan mata uang terdorong naik.';
    } else if (lower.contains('pmi')) {
      return isEn
          ? 'Purchasing Managers\' Index (PMI) indicates manufacturing and services sentiment. Numbers above 50 reflect vigorous expansion.'
          : 'Indeks Manajer Pembelian (PMI) mengukur optimisme para bos pabrik & bisnis. Angka di atas 50 berarti bisnis sedang berekspansi pesat.';
    } else {
      return isEn
          ? 'This economic calendar release can trigger notable short-term volatility on associated currency pairs and commodities like Spot Gold (XAU/USD).'
          : 'Berita kalender ekonomi ini dapat memicu fluktuasi pergerakan harga jangka pendek pada pasangan mata uang terkait serta aset komoditas seperti Emas (XAU/USD).';
    }
  }

  String get beginnerExplanation => beginnerExplanationLocalized('id');
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
