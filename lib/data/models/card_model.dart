class CardModel {
  const CardModel({
    required this.id,
    required this.actionLabel,
    required this.durationSeconds,
    required this.sortOrder,
    required this.createdAt,
    this.goalLabel,
    this.isArchived = false,
  });

  final String id;
  final String? goalLabel;
  final String actionLabel;
  final int durationSeconds;
  final int sortOrder;
  final int createdAt;
  final bool isArchived;

  String get durationLabel {
    final minutes = durationSeconds ~/ 60;
    return '$minutes min';
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'goalLabel': goalLabel,
      'actionLabel': actionLabel,
      'durationSeconds': durationSeconds,
      'sortOrder': sortOrder,
      'createdAt': createdAt,
      'isArchived': isArchived ? 1 : 0,
    };
  }

  factory CardModel.fromMap(Map<String, Object?> map) {
    return CardModel(
      id: map['id'] as String,
      goalLabel: map['goalLabel'] as String?,
      actionLabel: map['actionLabel'] as String,
      durationSeconds: map['durationSeconds'] as int,
      sortOrder: map['sortOrder'] as int,
      createdAt: map['createdAt'] as int,
      isArchived: (map['isArchived'] as int? ?? 0) == 1,
    );
  }
}
