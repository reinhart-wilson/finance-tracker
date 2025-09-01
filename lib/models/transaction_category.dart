class TransactionCategory {
  final String id;
  final String name;
  final String type;
  final int? defaultAccountId;
  final String? color;

  TransactionCategory({
    required this.id,
    required this.name,
    required this.type,
    this.defaultAccountId,
    this.color,
  });
}
