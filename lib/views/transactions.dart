import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/utils/formatter.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_list_viewmodel.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_form_view.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_action_dialog.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_filter_widget.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TransactionListView extends StatefulWidget {
  const TransactionListView({super.key});

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  late final TransactionListViewmodel _vm;

  @override
  void initState() {
    super.initState();
    _vm = context.read<TransactionListViewmodel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.searchTransaction('');
    }); //this calls notifyListeners(); Can't this be executed during build?
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        scrolledUnderElevation: 0,
        title: Text(
          "Transactions",
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
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
                    child: TextSelectionTheme(
                        data: TextSelectionThemeData(
                          cursorColor: Colors.white, // blinking cursor
                          selectionColor: Colors.grey.withOpacity(
                              0.4), // background highlight when selecting text
                          selectionHandleColor: const Color.fromARGB(
                              255, 189, 171, 255), // draggable handles color
                        ),
                        child: _TransactionSearchField())),
                const SizedBox(width: AppSizes.paddingSmall),
                Builder(builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.filter_list,
                        color: theme.colorScheme.onPrimary),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                }),
              ],
            ),
            const SizedBox(
              height: AppSizes.paddingMini,
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSmall,
                      vertical: AppSizes.paddingMedium),
                  child: _TransactionList()),
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

class _TransactionSearchField extends StatefulWidget {
  @override
  State<_TransactionSearchField> createState() =>
      _TransactionSearchFieldState();
}

class _TransactionSearchFieldState extends State<_TransactionSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<TransactionListViewmodel>();
    // TODO: implement build
    return TextField(
        controller: _controller,
        cursorColor: Colors.white,
        style: TextStyle(color: theme.colorScheme.onPrimary),
        onChanged: (value) {
          vm.searchTransaction(value);
          setState(() {});
        },
        decoration: InputDecoration(
          focusColor: Colors.white,
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: theme.colorScheme.surface.withOpacity(0.7),
            fontSize: 14,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onPrimary,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  color: theme.colorScheme.onPrimary,
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    vm.searchTransaction('');
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
              vertical: AppSizes.paddingSmall, horizontal: 12),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: theme.colorScheme.surface.withOpacity(0.7))),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.onPrimary)),
        ));
  }
}

class _TransactionList extends StatelessWidget {
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
