import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_list_viewmodel.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_form_view.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_filter_widget.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_list.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_search_field.dart';
import 'package:flutter/material.dart';
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
                        child: TransactionSearchField())),
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
                  child: TransactionList()),
            ),
            const SizedBox(
              height: AppSizes.paddingSmall,
            )
          ],
        ),
      ),
    );
  }
}
