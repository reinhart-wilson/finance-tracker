import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_list_viewmodel.dart';
import 'package:finance_tracker/views/transaction_form_view.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_action_dialog.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_filter_widget.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_list_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TransactionListViewmodel>();
    return Scaffold(
      endDrawer: const Drawer(
        child: TransactionFilterWidget(),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: false).push(
              MaterialPageRoute(
                builder: (context) => const TransactionFormView(),
              ),
            );
          },
          child: const Icon(Icons.add)),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
        title: const Text("Transactions"),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          // Providing an empty Container in actions ensures no default endDrawer icon appears.
          Container(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: TextField(
                  onChanged: (value) {
                    vm.searchTransaction(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                )),
                const SizedBox(width: 8),
                Builder(builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                }),
              ],
            ),
            const SizedBox(
              height: AppSizes.paddingSmall,
            ),
            Expanded(
              child: Selector<TransactionListViewmodel, List<Transaction>>(
                selector: (_, vm) => vm.filteredTransactions,
                builder: (context, filteredTransactions, child) {
                  final vm = context.read<TransactionListViewmodel>();
                  return TransactionListViewWidget(
                      transactions: filteredTransactions,
                      getAccountNameCallback: (tx) =>
                          vm.accountNameOfId(tx.accountId),
                      getSubtitleCallback: (tx, accountName) =>
                          '${accountName}: ${tx.category}',
                      onLongPressCallback: (tx) async {
                        showDialog(
                            context: context,
                            builder: (context) => TransactionActionDialog(
                                tx: tx,
                                onDelete: vm.deleteTransaction,
                                onMarkSettled: vm.markTransactionAsSettled));
                      });
                },
              ),
            ),
            SizedBox(
              height: AppSizes.paddingSmall,
            )
          ],
        ),
      ),
    );
  }
}
