import 'package:flutter/material.dart';
import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/utils/formatter.dart'; // Assuming you have a formatCurrency, formatDate, etc.

class TransactionDetailDialog extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return AlertDialog(
      title: Text(transaction.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow("Amount", formatCurrency(transaction.amount)),
          const SizedBox(height: 8),
          _buildRow("Account ID", transaction.accountId.toString()),
          const SizedBox(height: 8),
          _buildRow("Category", transaction.category ?? "None"),
          const SizedBox(height: 8),
          _buildRow("Transaction Date", formatDate(transaction.date)),
          const SizedBox(height: 8),
          if (transaction.dueDate != null)
            _buildRow("Due Date", formatDate(transaction.dueDate!)),
          if (transaction.settledDate != null)
            _buildRow("Settled Date", formatDate(transaction.settledDate!)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        )
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }
}
