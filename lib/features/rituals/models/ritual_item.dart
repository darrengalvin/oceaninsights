/// Type of ritual routine
enum RitualType {
  morning,
  evening,
  productivity,
}

/// Individual ritual item
class RitualItem {
  String id;
  String title;
  RitualType type;
  bool isDefault;
  bool isCompleted;
  int order;
  DateTime? lastCompletedDate;
  
  RitualItem({
    required this.id,
    required this.title,
    required this.type,
    this.isDefault = false,
    this.isCompleted = false,
    this.order = 0,
    this.lastCompletedDate,
  });
  
  /// Check if this item was completed today
  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final today = DateTime.now();
    return lastCompletedDate!.year == today.year &&
           lastCompletedDate!.month == today.month &&
           lastCompletedDate!.day == today.day;
  }
  
  /// Mark as completed for today
  void markCompleted() {
    isCompleted = true;
    lastCompletedDate = DateTime.now();
  }
  
  /// Mark as not completed
  void markIncomplete() {
    isCompleted = false;
  }
  
  /// Reset completion status (called daily)
  void resetDaily() {
    if (!isCompletedToday) {
      isCompleted = false;
    }
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.toString(),
      'isDefault': isDefault,
      'isCompleted': isCompleted,
      'order': order,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory RitualItem.fromJson(Map<String, dynamic> json) {
    return RitualItem(
      id: json['id'] as String,
      title: json['title'] as String,
      type: RitualType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => RitualType.morning,
      ),
      isDefault: json['isDefault'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
    );
  }
}
