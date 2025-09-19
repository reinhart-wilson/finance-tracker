import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction_category.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_category_viewmodel.dart';
import 'package:finance_tracker/views/widgets/transaction_category/transaction_category_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionCategoryManagement extends StatefulWidget {
  const TransactionCategoryManagement({super.key});

  @override
  State<StatefulWidget> createState() => TransactionCategoryManagementState();
}

class TransactionCategoryManagementState
    extends State<TransactionCategoryManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const TransactionCategoryForm(),
              );
            }),
        appBar: AppBar(),
        body: Expanded(
          child:
              Selector<TransactionCategoryViewmodel, List<TransactionCategory>>(
            selector: (_, vm) => vm.categories,
            builder: (context, categories, _) {
              if (categories.isEmpty) return const Text('No categories found.');
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _CategoryItem(category: categories[index]);
                },
              );
            },
          ),
        ));
  }
}

class _CategoryItem extends StatelessWidget {
  final TransactionCategory category;
  final Color? color;

  const _CategoryItem({required this.category, this.color});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TransactionCategoryViewmodel>();

    return ListTile(
      title: Text(category.name),
      subtitle: Builder(builder: (context) {
        final String accountName;
        final Color? color;
        if (category.defaultAccountId == null) {
          accountName = 'No associated account';
          color = Colors.grey.withOpacity(0.8);
        } else {
          accountName =
              vm.accounts.searchById(category.defaultAccountId!)!.name;
          color = null;
        }
        return Text(
          accountName,
          style: TextStyle(color: color),
        );
      }),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) => SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingMedium,
                          horizontal: AppSizes.paddingSmall),
                      child: _CategoryOptions(category: category),
                    ),
                  ));
        },
      ),
    );
  }
}

class _CategoryOptions extends StatelessWidget {
  final TransactionCategory category;

  const _CategoryOptions({required this.category});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TransactionCategoryViewmodel>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit'),
          onTap: () async {
            Navigator.pop(context);
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => TransactionCategoryForm(category: category),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete'),
          onTap: () async {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

