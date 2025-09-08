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
}
