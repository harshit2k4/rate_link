String formatRate(double value) {
  final parts = value.abs().toStringAsFixed(2).split('.');
  final intStr = parts[0];
  final decStr = parts[1];
  final buffer = StringBuffer();
  for (int i = 0; i < intStr.length; i++) {
    if (i > 0 && (intStr.length - i) % 3 == 0) buffer.write('.');
    buffer.write(intStr[i]);
  }
  return '${value < 0 ? '-' : ''}${buffer.toString()},$decStr';
}

String formatChange(double change) {
  if (change.abs() < 0.005) return '0';
  final sign = change > 0 ? '+ ' : '- ';
  return '$sign${formatRate(change.abs())}';
}

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
