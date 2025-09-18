import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionSearchField extends StatefulWidget {
  @override
  State<TransactionSearchField> createState() => _TransactionSearchFieldState();
}

class _TransactionSearchFieldState extends State<TransactionSearchField> {
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
