import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/utils/formatter.dart';
import 'package:flutter/material.dart';

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

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: AppSizes.paddingMini),
      elevation: 0,
      child: Column(
        children: [
          // Parent row (tappable + chevron)
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => widget.onParentTap?.call(widget.parentAccount),
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
                        Text(
                          '${formatCurrency(widget.parentAccount.balance)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
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
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
              child: Divider(height: 1, color:  const Color.fromARGB(255, 240, 228, 255)),
            ),

          // Expanded children
          if (_expanded)
            ...List.generate(widget.childAccounts.length, (i) {
              final child = widget.childAccounts[i];

              return Column(
                children: [
                   
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium),
                      child: Divider(height: 1, color:   Color.fromARGB(255, 240, 228, 255)),
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
                              Text(
                                'Balance: ${formatCurrency(child.balance)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => widget.onChildTap?.call(child),
                  ),
                  if (i == widget.childAccounts.length - 1) SizedBox(height: AppSizes.paddingSmall,)
                ],
              );
            }),
        ],
      ),
    );
  }
}
