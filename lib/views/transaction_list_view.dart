import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_list_viewmodel.dart';
import 'package:finance_tracker/views/transaction_form_view.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TransactionListViewmodel>();
    return Scaffold(
      endDrawer: const Drawer(child: TransactionFilterWidget(),),
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
                    hintText: 'Cari...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                )),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    );
                  }
                ),
              ],
            ),
          ),
          Selector<TransactionListViewmodel, List<Transaction>>(
            selector: (_, vm) => vm.filteredTransactions,
            builder: (context, filteredTransactions, child) {
              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = filteredTransactions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Kiri
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.title, // dari atribut title
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                vm.accountNameOfId(tx.accountId),
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                tx.category == null
                                    ? 'None'
                                    : tx.category!, // dari atribut category
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          // Kanan
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${tx.amount}", // dari atribut amount
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: tx.amount >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              Text(
                                tx.date.toString(),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
