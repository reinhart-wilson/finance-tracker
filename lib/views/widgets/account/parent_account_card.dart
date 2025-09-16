import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/utils/formatter.dart';
import 'package:finance_tracker/viewmodels/account/account_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParentAccountCard extends StatefulWidget {
  final Account parentAccount;
  final List<Account> childAccounts;
  final void Function(Account)? onParentTap;
  final void Function(Account)? onChildTap;

  const ParentAccountCard({
    super.key,
    required this.parentAccount,
    required this.childAccounts,
    this.onParentTap,
    this.onChildTap,
  });

  @override
  State<ParentAccountCard> createState() => _ParentAccountCardState();
}

class _ParentAccountCardState extends State<ParentAccountCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<AccountListViewmodel>();

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: AppSizes.paddingMini),
      elevation: 0,
      child: Column(
        children: [
          // Parent row (tappable + chevron)
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => widget.onParentTap?.call(widget.parentAccount),
            onLongPress: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => const ConfirmationDialog(
                  title: 'Confirm Deletion',
                  content: 'Are you sure you want to delete this account?',
                ),
              );

              if (confirmed == true) {
                try {
                  await vm.deleteAccount(widget.parentAccount.id!);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deletion failed: $e')),
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.parentAccount.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Builder(builder: (_) {
                          final unsettled = vm.getUnsettledSumForId(
                                  widget.parentAccount.id!) ??
                              0;

                          return RichText(
                            text: TextSpan(
                              text:
                                  '${formatCurrency(widget.parentAccount.balance)} ',
                              style: theme.textTheme.bodySmall,
                              children: [
                                if (unsettled != 0)
                                  TextSpan(
                                    text: '(${formatCurrency(unsettled)})',
                                    style: TextStyle(
                                      color: unsettled >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  if (widget.childAccounts.isNotEmpty)
                    IconButton(
                      icon: AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: _expanded ? 0.5 : 0,
                        child: const Icon(Icons.expand_more),
                      ),
                      onPressed: () {
                        setState(() => _expanded = !_expanded);
                      },
                    )
                ],
              ),
            ),
          ),

          // Divider between parent and children
          if (_expanded && widget.childAccounts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium),
              child: Divider(
                  height: 1, color: const Color.fromARGB(255, 240, 228, 255)),
            ),

          // Expanded children
          if (_expanded)
            ...List.generate(widget.childAccounts.length, (i) {
              final child = widget.childAccounts[i];
              final childUnsettled = vm.getUnsettledSumForId(child.id!);

              return Column(
                children: [
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium),
                      child: Divider(
                          height: 1, color: Color.fromARGB(255, 240, 228, 255)),
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        // Left color strip
                        SizedBox(
                          width: 30,
                        ),
                        // Text and content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(child.name),
                              RichText(
                                text: TextSpan(
                                    text: '${formatCurrency(child.balance)} ',
                                    style: theme.textTheme.bodySmall,
                                    children: [
                                      if (childUnsettled != 0)
                                        TextSpan(
                                            text:
                                                '(${formatCurrency(childUnsettled!)})',
                                            style: TextStyle(
                                                color: childUnsettled >= 0
                                                    ? Colors.green
                                                    : Colors.red))
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => widget.onChildTap?.call(child),
                    onLongPress: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => const ConfirmationDialog(
                          title: 'Confirm Deletion',
                          content:
                              'Are you sure you want to delete this account?',
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          await vm.deleteAccount(child.id!);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deletion failed: $e')),
                          );
                        }
                      }
                    },
                  ),
                  if (i == widget.childAccounts.length - 1)
                    const SizedBox(
                      height: AppSizes.paddingSmall,
                    )
                ],
              );
            }),
        ],
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
