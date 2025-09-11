import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_list_viewmodel.dart';
import 'package:finance_tracker/views/transaction_form_view.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_filter_widget.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_item_widget.dart';
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
      appBar: AppBar(title: const Text("Transactions")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
          ),
          Expanded(
            child: Selector<TransactionListViewmodel, List<Transaction>>(
              selector: (_, vm) => vm.filteredTransactions,
              builder: (context, filteredTransactions, child) {
                return buildTransactionItem(context, filteredTransactions,
                    getAccountNameCallback: vm.accountNameOfId,
                    onLongPressCallback: (tx) async {
                  await showDialog(
                    context: context,
                    builder: (context) {
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
                                        text:
                                            'Are you sure you want to delete transaction ',
                                        style: const TextStyle(
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: tx.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const TextSpan(text: '?'),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirmed != null && confirmed) {
                                try {
                                  vm.deleteTransaction(tx);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Deletion failed: $e')),
                                  );
                                } finally {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              }
                            },
                            child: const Text('Delete transaction'),
                          ),
                          if (tx.settledDate == null)
                            SimpleDialogOption(
                              child: const Text('Mark as settled'),
                              onPressed: () async {
                                try {
                                  await vm.markTransactionAsSettled(tx);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Transaction marked as settled.')),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Deletion failed: $e')),
                                  );
                                } finally {
                                  if (context.mounted) Navigator.pop(context);
                                }
                              },
                            )
                        ],
                      );
                    },
                  ); //showdialog
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
