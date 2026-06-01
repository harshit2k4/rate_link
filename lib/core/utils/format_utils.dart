class FormatPrefs {
  FormatPrefs._();

  static String _thousandsSep = ',';
  static String _decimalSep = '.';

  static const List<String> options = ['1.234,56', '1,234.56', '1 234.56'];

  static String get current {
    if (_thousandsSep == ',' && _decimalSep == '.') return options[1];
    if (_thousandsSep == ' ') return options[2];
    return options[0];
  }

  static void apply(String style) {
    switch (style) {
      case '1,234.56':
        _thousandsSep = ',';
        _decimalSep = '.';
        break;
      case '1 234.56':
        _thousandsSep = ' ';
        _decimalSep = '.';
        break;
      default: // '1.234,56'
        _thousandsSep = '.';
        _decimalSep = ',';
    }
  }
}

String formatRate(double value) {
  final parts = value.abs().toStringAsFixed(2).split('.');
  final intStr = parts[0];
  final decStr = parts[1];
  final buffer = StringBuffer();
  for (int i = 0; i < intStr.length; i++) {
    if (i > 0 && (intStr.length - i) % 3 == 0) {
      buffer.write(FormatPrefs._thousandsSep);
    }
    buffer.write(intStr[i]);
  }
  return '${value < 0 ? '-' : ''}${buffer.toString()}${FormatPrefs._decimalSep}$decStr';
}

String formatChange(double change) {
  if (isZeroChange(change)) return '0';
  final sign = change > 0 ? '+ ' : '- ';
  return '$sign${formatRate(change.abs())}';
}

// Used in views to decide whether to show the change row at all
bool isZeroChange(double change) => change.abs() < 0.005;

String formatDisplayDate(String isoDate) {
  if (isoDate.isEmpty) return '';
  final parts = isoDate.split('-');
  if (parts.length != 3) return isoDate;
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final month = int.tryParse(parts[1]) ?? 1;
  return '${parts[2]} ${months[month - 1]} ${parts[0]}';
}

String formatShortDate(String isoDate) {
  if (isoDate.isEmpty) return '';
  final parts = isoDate.split('-');
  if (parts.length != 3) return isoDate;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = int.tryParse(parts[1]) ?? 1;
  return '${parts[2]} ${months[month - 1]}';
}
