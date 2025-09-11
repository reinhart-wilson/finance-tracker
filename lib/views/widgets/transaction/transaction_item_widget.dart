import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/utils/formatter.dart';
ListView buildTransactionItem(
  BuildContext context,
  List<Transaction> transactions, {
  String Function(int)? getAccountNameCallback,
  Future<void> Function(Transaction)? onLongPressCallback,
  bool disableScrollPhysics = false,
}) {
  return ListView.builder(
    shrinkWrap: true,
    physics: disableScrollPhysics ? const NeverScrollableScrollPhysics() : null,
    padding: const EdgeInsets.all(AppSizes.paddingSmall),
    itemCount: transactions.length,
    itemBuilder: (context, index) {
      final tx = transactions[index];
      final isSettled = tx.settledDate != null;

      return Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 2),
        color: !isSettled
            ? Colors.orange.withOpacity(0.05)
            : Colors.white.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),

          onLongPress: () async {
            if (onLongPressCallback != null) {
              try {
                await onLongPressCallback(tx);
              } catch (e, st) {
                debugPrint('onLongPressCallback error: $e\n$st');
              }
            }
          },

          title: Text(
            tx.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            getAccountNameCallback == null
                ? (tx.category ?? 'None')
                : getAccountNameCallback(tx.accountId),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatCurrency(tx.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tx.amount >= 0 ? Colors.green : Colors.red,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSettled)
                    const Icon(Icons.schedule, size: 14, color: Colors.orange),
                  Text(
                    ' ${formatDate(isSettled ? tx.date : tx.dueDate!)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
