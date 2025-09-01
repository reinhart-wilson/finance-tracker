class Transaction {
  final int? id;
  final String title;
  final double amount;
  final int accountId;
  final DateTime date;
  final DateTime? dueDate;
  final DateTime? settledDate;

  Transaction._internal({
    this.id,
    required this.title,
    required this.amount,
    required this.accountId,
    required this.date,
    this.dueDate,
    this.settledDate,
  });

  /// Factory untuk memastikan aturan settledDate
  factory Transaction({
    int? id,
    required String title,
    required double amount,
    required int accountId,
    required DateTime date,
    DateTime? dueDate,
    DateTime? settledDate,
  }) {
    DateTime? finalSettledDate;

    if (dueDate == null) {
      // aturan 1
      finalSettledDate = date;
    } else {
      // aturan 2
      finalSettledDate = settledDate; // bisa null
    }

    return Transaction._internal(
      id: id,
      title: title,
      amount: amount,
      accountId: accountId,
      date: date,
      dueDate: dueDate,
      settledDate: finalSettledDate,
    );
  }

  bool isDue() {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  copyWith({required id}) {
    return Transaction(
      id: id ?? this.id,
      title: title,
      amount: amount,
      accountId: accountId,
      date: date,
      dueDate: dueDate,
      settledDate: settledDate,
    );
  }
}
