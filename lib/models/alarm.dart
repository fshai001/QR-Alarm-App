import 'dart:convert';

class Alarm {
  final String id;
  final String time; // Format "HH:mm" (e.g., "07:30")
  final String label;
  final bool isActive;
  final String qrValue; // Target string inside the QR code to dismiss
  final List<String> days; // Repetition (e.g. ["Mon", "Tue", "Wed"])

  Alarm({
    required this.id,
    required this.time,
    required this.label,
    required this.isActive,
    required this.qrValue,
    required this.days,
  });

  // Convert Alarm to JSON for local persistence (SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'label': label,
      'isActive': isActive ? 1 : 0,
      'qrValue': qrValue,
      'days': days,
    };
  }

  // Restore Alarm from JSON format
  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      time: map['time'],
      label: map['label'],
      isActive: map['isActive'] == 1,
      qrValue: map['qrValue'] ?? 'DEFAULT_QR_KEY',
      days: List<String>.from(map['days'] ?? []),
    );
  }

  Alarm copyWith({
    String? id,
    String? time,
    String? label,
    bool? isActive,
    String? qrValue,
    List<String>? days,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
      qrValue: qrValue ?? this.qrValue,
      days: days ?? this.days,
    );
  }
}
