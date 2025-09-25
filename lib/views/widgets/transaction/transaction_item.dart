import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/utils/formatter.dart';

class TransactionItem extends StatelessWidget {
  final List<Transaction> transactions;
  final String Function(Transaction) getAccountNameCallback;
  final String Function(Transaction tx, String accountName) getSubtitleCallback;
  final Future<void> Function(Transaction) onLongPressCallback;
  final bool disableScrollPhysics;

  const TransactionItem({
    super.key,
    required this.transactions,
    required this.getAccountNameCallback,
    required this.getSubtitleCallback,
    required this.onLongPressCallback,
    this.disableScrollPhysics = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics:
          disableScrollPhysics ? const NeverScrollableScrollPhysics() : null,
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final accountName = getAccountNameCallback(tx);
        return TransactionItemTile(
          transaction: tx,
          accountName: accountName,
          getSubtitle: getSubtitleCallback,
          onLongPress: onLongPressCallback,
        );
      },
    );
  }
}

class TransactionItemTile extends StatelessWidget {
  final Transaction transaction;
  final String accountName;
  final String Function(Transaction, String) getSubtitle;
  final Future<void> Function(Transaction)? onLongPress;

  const TransactionItemTile({
    super.key,
    required this.transaction,
    required this.accountName,
    required this.getSubtitle,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isSettled = transaction.settledDate != null;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: !isSettled
          ? Colors.orange.withOpacity(0.05)
          : Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        onLongPress: () async {
          if (onLongPress != null) {
            try {
              await onLongPress!(transaction);
            } catch (e, st) {
              debugPrint('onLongPress error: $e\n$st');
            }
          }
        },
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => TransactionDetailDialog(transaction: transaction),
          );
        },
        title: Text(
          transaction.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          getSubtitle(transaction, accountName),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatCurrency(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.amount >= 0 ? Colors.green : Colors.red,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isSettled)
                  const Icon(Icons.schedule, size: 14, color: Colors.orange),
                Text(
                  ' ${formatDate(transaction.settledDate ?? transaction.dueDate!)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
