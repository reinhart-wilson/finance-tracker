import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction_category.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_category_viewmodel.dart';
import 'package:finance_tracker/views/widgets/transaction_category/transaction_category_form.dart';
import 'package:finance_tracker/views/widgets/transaction_category/transaction_category_migrate_dialog.dart';
import 'package:flutter/foundation.dart';
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
        body: Selector<TransactionCategoryViewmodel, List<TransactionCategory>>(
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

class _CategoryOptions extends StatefulWidget {
  final TransactionCategory category;

  const _CategoryOptions({required this.category});

  @override
  State<_CategoryOptions> createState() => _CategoryOptionsState();
}

class _CategoryOptionsState extends State<_CategoryOptions> {
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
              builder: (_) =>
                  TransactionCategoryForm(category: widget.category),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete'),
          onTap: () async {
            final categoryId = widget.category.id!;
            bool isMigrate = false;

            // 1) Ask for delete confirmation
            final isDeleteConfirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return _DeleteConfirmationDialog(
                  category: widget.category,
                  value: isMigrate,
                  onMigrateChanged: (value) {
                    isMigrate = value ?? isMigrate;
                  },
                );
              },
            );

            // If user canceled or didn't confirm deletion -> stop.
            if (isDeleteConfirmed != true) return;

            // 2) If migrate chosen, show migration target dialog (cancelable).
            if (isMigrate) {
              final TransactionCategory? target =
                  await showDialog<TransactionCategory?>(
                context: context,
                builder: (_) {
                  return TransactionCategoryMigrateDialog(
                    categoryList: vm.categories,
                    previousCategory: widget.category,
                  );
                },
              );

              // If user cancelled the migration dialog, abort deletion.
              if (target == null) return;

              // Try to migrate before deleting.
              try {
                await vm.migrateCategory(categoryId, target.id!);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Migration failed: ${e.toString()}')),
                  );
                }
                return;
              }
            }

            // 3) Proceed with deletion. nullCategory should be true when NOT migrating.
            var message = 'Successfully deleted ${widget.category.name}.';
            try {
              await vm.deleteCategory(widget.category,
                  nullCategory: !isMigrate);
            } catch (e) {
              message =
                  'Failed to delete ${widget.category.name}: ${e.toString()}';
                  debugPrintStack();
            } finally {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            }
          },
        ),
      ],
    );
  }
}

class _DeleteConfirmationDialog extends StatefulWidget {
  final TransactionCategory category;
  final void Function(bool?) onMigrateChanged;
  final bool value;

  const _DeleteConfirmationDialog(
      {required this.category,
      required this.onMigrateChanged,
      required this.value});

  @override
  State<_DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<_DeleteConfirmationDialog> {
  late bool _isMigrate;

  @override
  void initState() {
    super.initState();
    _isMigrate = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Deletion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              text: 'Are you sure you want to delete transaction ',
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: widget.category.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          Builder(builder: (context) {
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: _isMigrate,
              onChanged: (value) {
                setState(() {
                  _isMigrate = value ?? _isMigrate;
                  widget.onMigrateChanged(value);
                });
              },
              title: const Text('Migrate associated transactions'),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
