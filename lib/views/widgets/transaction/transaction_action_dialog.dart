import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:flutter/material.dart';

class TransactionActionDialog extends StatelessWidget {
  final Transaction tx;
  final Future<void> Function(Transaction) onDelete;
  final Future<void> Function(Transaction) onMarkSettled;

  const TransactionActionDialog({
    super.key,
    required this.tx,
    required this.onDelete,
    required this.onMarkSettled,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Action'),
      children: [
        SimpleDialogOption(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: Text.rich(
                    TextSpan(
                      text: 'Are you sure you want to delete transaction ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: tx.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '?'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes'),
                    ),
                  ],
                );
              },
            );

            if (confirmed == true) {
              try {
                await onDelete(tx);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deletion failed: $e')),
                );
              } finally {
                if (context.mounted) {
                  Navigator.pop(context); // close the SimpleDialog
                }
              }
            }
          },
          child: const Text('Delete transaction'),
        ),
        if (tx.settledDate == null)
          SimpleDialogOption(
            onPressed: () async {
              try {
                await onMarkSettled(tx);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction marked as settled.'),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Operation failed: $e')),
                );
              } finally {
                if (context.mounted) {
                  Navigator.pop(context); // close the SimpleDialog
                }
              }
            },
            child: const Text('Mark as settled'),
          ),
      ],
    );
  }
}
