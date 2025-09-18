import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/utils/formatter.dart';
import 'package:finance_tracker/viewmodels/view_models.dart';
import 'package:finance_tracker/views/widgets/account/child_account_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final childAccounts = context.select<AccountDetailViewmodel, List<Account>>(
        (vm) => vm.childAccountList);

    final parentSettledAmount = context.select<AccountDetailViewmodel, double>(
        (vm) => vm.parentAccountSettled ?? 0);

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.paddingLarge),
          bottomRight: Radius.circular(AppSizes.paddingLarge),
        ),
      ),
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Selector<AccountDetailViewmodel, Account>(
                    selector: (_, vm) => vm.parentAccount!,
                    builder: (context, account, __) => Text(
                          account.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              letterSpacing: 0.25),
                        )),
                IconButton(
                  color: Theme.of(context).colorScheme.onPrimary,
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                  iconSize: theme.textTheme.titleMedium?.fontSize,
                ),
              ],
            ),
            Row(
              // Displays total balance
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rp",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: theme.textTheme.titleMedium?.fontSize),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: theme.textTheme.bodySmall?.fontSize,
                ),
                Selector<AccountDetailViewmodel, Account>(
                  // Selector in case account data is updated
                  selector: (_, vm) => vm.parentAccount!,
                  builder: (context, account, _) {
                    return Text(
                      formatCurrency(account.balance, includeCurrency: false),
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    );
                  },
                )
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
              child: Center(
                child: Selector<AccountDetailViewmodel, double>(
                    // Displays projected balance
                    selector: (_, vm) => vm.parentAccountUnsettled!,
                    builder: (_, parentUnsettledAmount, __) {
                      return RichText(
                          text: TextSpan(
                              text: 'Projected: ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary),
                              children: [
                            TextSpan(
                              text: formatCurrency(
                                  parentUnsettledAmount +
                                      context
                                          .read<AccountDetailViewmodel>()
                                          .parentAccount!
                                          .balance,
                                  shorten: true),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: parentUnsettledAmount +
                                              parentSettledAmount >
                                          0
                                      ? Colors.green
                                      : Colors.red),
                            )
                          ]));
                    }),
              ),
            ),
            if (childAccounts.isNotEmpty)
              const SizedBox(height: AppSizes.paddingSmall),
            if (childAccounts.isNotEmpty)
              Selector<AccountDetailViewmodel, Map<int, double>>(
                selector: (_, vm) => vm.unsettledAmountByAccountId,
                builder: (context, unsettledAmounts, __) => SizedBox(
                  height: 110, // beri tinggi untuk ListView horizontal
                  child: buildChildAccountItem(
                      context, childAccounts, unsettledAmounts),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
