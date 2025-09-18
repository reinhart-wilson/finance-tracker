import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_list_viewmodel.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_action_dialog.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionList extends StatelessWidget {
  @override
  Widget build(context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.paddingSmall),
            Expanded(
              child: Selector<TransactionListViewmodel, List<Transaction>>(
                selector: (_, vm) => vm.filteredTransactions,
                builder: (context, filteredTransactions, child) {
                  final vm = context.read<TransactionListViewmodel>();
                  if (filteredTransactions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      child:
                          Text("No transactions found for the current filter."),
                    );
                  }
                  return TransactionItem(
                    transactions: filteredTransactions,
                    getAccountNameCallback: (tx) =>
                        vm.accountNameOfId(tx.accountId),
                    getSubtitleCallback: (tx, accountName) =>
                        '$accountName: ${tx.category ?? 'None'}',
                    onLongPressCallback: (tx) async {
                      showDialog(
                        context: context,
                        builder: (context) => TransactionActionDialog(
                          tx: tx,
                          onDelete: vm.deleteTransaction,
                          onMarkSettled: vm.markTransactionAsSettled,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
          ],
        ),
      ),
    );
  }
}
