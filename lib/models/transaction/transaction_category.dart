class TransactionCategory {
  final int? id;
  final String name;
  final int? defaultAccountId;
  final String? color;

  TransactionCategory({
    this.id,
    required this.name,
    this.defaultAccountId,
    this.color,
  });

  TransactionCategory copyWith({
    int? id,
    String? name,
    int? defaultAccountId,
    String? color,
  }) {
    return TransactionCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
