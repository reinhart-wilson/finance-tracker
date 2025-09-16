import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/utils/formatter.dart';
import 'package:finance_tracker/viewmodels/account/account_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParentAccountCard extends StatelessWidget {
  final Account parentAccount;
  final List<Account> childAccounts;
  final void Function(Account)? onChildTap;

  const ParentAccountCard({
    super.key,
    required this.parentAccount,
    required this.childAccounts,
    this.onChildTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<AccountListViewmodel>();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          title: Text(
            parentAccount.name,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${formatCurrency(parentAccount.balance)}',
            style: theme.textTheme.bodySmall,
          ),
          children: [
            for (var i = 0; i < childAccounts.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium),
                title: Text(childAccounts[i].name),
                subtitle: RichText(
                  text: TextSpan(
                      text: '${formatCurrency(childAccounts[i].balance)} ',
                      style: theme.textTheme.bodySmall,
                      children: [
                        if (vm
                                .getUnsettledSumForId(childAccounts[i].id!) !=
                            null)
                          TextSpan(
                              text:
                                  '(${formatCurrency(vm.getUnsettledSumForId(childAccounts[i].id!)!)})',
                              style: TextStyle(
                                  color: childAccounts[i].balance > 0
                                      ? Colors.green
                                      : Colors.red))
                      ]),
                ),
                onTap: () => onChildTap?.call(childAccounts[i]),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
