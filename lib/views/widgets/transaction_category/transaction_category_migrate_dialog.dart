import 'package:finance_tracker/models/transaction/transaction_category.dart';
import 'package:flutter/material.dart';

class TransactionCategoryMigrateDialog extends StatefulWidget {
  final List<TransactionCategory> categoryList;
  final TransactionCategory? previousCategory;

  @override
  State<TransactionCategoryMigrateDialog> createState() =>
      _TransactionCategoryMigrateDialogState();

  const TransactionCategoryMigrateDialog(
      {required this.categoryList, this.previousCategory, super.key});
}

class _TransactionCategoryMigrateDialogState
    extends State<TransactionCategoryMigrateDialog> {
  TransactionCategory? _selectedCategory;
  late final TransactionCategory _noneCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.previousCategory;
    _noneCategory = TransactionCategory(
      name: "None",
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Migrate Transactions'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Target category:'),
        DropdownButton(
            value: _noneCategory,
            items: [
              DropdownMenuItem<TransactionCategory?>(
                value: _noneCategory, // "None" sentinel
                child: const Text('None'),
              ),
              ...widget.categoryList
                  .where((category) => category != widget.previousCategory)
                  .map((category) => DropdownMenuItem<TransactionCategory>(
                        value: category,
                        child: Text(category.name),
                      ))
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            })
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedCategory),
          child: const Text('Migrate'),
        ),
      ],
    );
  }
}
