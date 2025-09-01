class Account {
  final int? id;
  final String name;
  final double balance;
  final int? parentId;

  Account({
    this.id,
    required this.name,
    required this.balance,
    this.parentId,
  });

  Account copyWith({
    int? id,
    String? name,
    double? balance,
    int? parentId,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      parentId: parentId ?? this.parentId,
    );
  }
}