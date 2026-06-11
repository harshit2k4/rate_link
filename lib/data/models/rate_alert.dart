import 'dart:convert';

enum AlertDirection { above, below }

class RateAlert {
  final String id;
  final String baseCurrency;
  final String targetCurrency;
  final double threshold;
  final AlertDirection direction;
  final bool isEnabled;
  final bool hasTriggered;
  final DateTime createdAt;

  const RateAlert({
    required this.id,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.threshold,
    required this.direction,
    this.isEnabled = true,
    this.hasTriggered = false,
    required this.createdAt,
  });

  RateAlert copyWith({bool? isEnabled, bool? hasTriggered}) => RateAlert(
    id: id,
    baseCurrency: baseCurrency,
    targetCurrency: targetCurrency,
    threshold: threshold,
    direction: direction,
    isEnabled: isEnabled ?? this.isEnabled,
    hasTriggered: hasTriggered ?? this.hasTriggered,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'baseCurrency': baseCurrency,
    'targetCurrency': targetCurrency,
    'threshold': threshold,
    'direction': direction.name,
    'isEnabled': isEnabled,
    'hasTriggered': hasTriggered,
    'createdAt': createdAt.toIso8601String(),
  };

  factory RateAlert.fromJson(Map<String, dynamic> json) => RateAlert(
    id: json['id'] as String,
    baseCurrency: json['baseCurrency'] as String,
    targetCurrency: json['targetCurrency'] as String,
    threshold: (json['threshold'] as num).toDouble(),
    direction: AlertDirection.values.firstWhere(
      (d) => d.name == json['direction'],
      orElse: () => AlertDirection.above,
    ),
    isEnabled: json['isEnabled'] as bool? ?? true,
    hasTriggered: json['hasTriggered'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  String toJsonString() => jsonEncode(toJson());
  factory RateAlert.fromJsonString(String s) =>
      RateAlert.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
