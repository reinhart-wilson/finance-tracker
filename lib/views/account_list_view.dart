import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/utils/formatter.dart';
import 'package:finance_tracker/views/account_detail_view.dart';
import 'package:finance_tracker/views/widgets/account/parent_account_card.dart';
import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:finance_tracker/viewmodels/account/account_list_viewmodel.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/views/widgets/account/account_form_widget.dart';

class AccountListView extends StatelessWidget {
  const AccountListView({super.key});

  String formatBalance(double balance) {
    final formatter = NumberFormat("#,###", "id_ID");
    return "Rp. ${formatter.format(balance)}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    context.read<AccountListViewmodel>().filter = null;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).colorScheme.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
            title: Text(
          "Overview",
          style: GoogleFonts.manrope(
              textStyle: theme.textTheme.titleLarge,
              fontWeight: FontWeight.w600),
        )),
        body: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total Balance',
                              textAlign: TextAlign.start,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 4), // optional spacing
                            Icon(
                              Icons.wallet,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ],
                        ),
                        Selector<AccountListViewmodel, double>(
                          selector: (_, vm) => vm.totalBalance,
                          builder: (context, totalBalance, _) {
                            return RichText(
                                text: TextSpan(
                              text: "Rp ",
                              style: theme.textTheme.displaySmall?.copyWith(
                                  fontSize:
                                      theme.textTheme.titleMedium?.fontSize,
                                  color: theme.colorScheme.onPrimary),
                              children: [
                                TextSpan(
                                  text: formatCurrency(totalBalance,
                                      includeCurrency: false),
                                  style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w600,
                                      color: totalBalance < 0
                                          ? Colors.red
                                          : theme.colorScheme.onPrimary,
                                      textStyle: theme.textTheme.headlineSmall),
                                ),
                              ],
                            ));
                          },
                        ),
                        Selector<AccountListViewmodel, double>(
                            selector: (_, vm) => vm.balanceGrowth,
                            builder: (_, growth, __) {
                              Color color;
                              IconData icon;
                              if (growth > 0) {
                                color = Colors.green;
                                icon = Icons.trending_up;
                              } else if (growth < 0) {
                                color = Colors.red;
                                icon = Icons.trending_down;
                              } else {
                                color = Colors.grey;
                                icon = Icons.trending_neutral;
                              }

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    size: theme.textTheme.labelMedium?.fontSize,
                                    color: color,
                                  ),
                                  const SizedBox(width: 4),
                                  RichText(
                                    text: TextSpan(
                                        text: formatPercentage(growth),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(color: color),
                                        children: [
                                          TextSpan(text: ' from last month')
                                        ]),
                                  ),
                                ],
                              );
                            }),
                        const SizedBox(
                          height: AppSizes.paddingSmall,
                        ),
                        Divider(
                          thickness: 1,
                          height: AppSizes.paddingLarge,
                          color: theme.colorScheme.surface,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Total Due',
                                        textAlign: TextAlign.start,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.schedule,
                                        size: 14,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: AppSizes.paddingMini,
                                  ),
                                  Selector<AccountListViewmodel, double>(
                                      selector: (_, vm) => vm.unsettledSum,
                                      builder: (__, unsettledSum, _) => Text(
                                            formatCurrency(unsettledSum,
                                                shorten: true),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: unsettledSum < 0
                                                    ? Colors.red
                                                    : theme
                                                        .colorScheme.onPrimary),
                                          )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              child: VerticalDivider(
                                width: AppSizes.paddingLarge,
                                thickness: 1,
                                color: theme.colorScheme.surface,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Proj. Balance',
                                        textAlign: TextAlign.start,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons
                                            .trending_up, // 👈 recommended icon
                                        size: 14,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: AppSizes.paddingMini,
                                  ),
                                  Selector<AccountListViewmodel, double>(
                                      selector: (_, vm) => vm.projectedBalance,
                                      builder: (__, projectedBalance, _) =>
                                          Text(
                                            formatCurrency(projectedBalance,
                                                shorten: true),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: projectedBalance < 0
                                                    ? Colors.red
                                                    : theme
                                                        .colorScheme.onPrimary),
                                          )),
                                ],
                              ),
                            ),
                          ],
                        )
                      ]),
                ),
              ),
              SizedBox(
                height: AppSizes.paddingMedium,
              ),
              Text(
                "Your Accounts",
                style: GoogleFonts.manrope(
                    textStyle: theme.textTheme.titleMedium,
                    fontWeight: FontWeight.w600),
              ),
              Selector<AccountListViewmodel, List<Account>>(
                selector: (_, vm) => vm.accountList,
                builder: (context, accounts, _) {
                  final parentAccounts =
                      accounts.where((acc) => acc.parentId == null).toList();
                  final childAccounts = getChildren(accounts);

                  return Expanded(
                    child: ListView.builder(
                        itemCount: parentAccounts.length,
                        itemBuilder: (context, index) {
                          final parent = parentAccounts[index];
                          final children = childAccounts[parent.id] ?? [];

                          return ParentAccountCard(
                            parentAccount: parent,
                            childAccounts: children,
                            onParentTap: (account) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AccountDetailView(),
                                  settings: RouteSettings(arguments: account),
                                ),
                              );
                            },
                            onChildTap: (account) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AccountDetailView(),
                                  settings: RouteSettings(arguments: account),
                                ),
                              );
                            },
                          );
                        }),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16))),
                  builder: (context) {
                    return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          left: 16,
                          right: 16,
                          top: 24,
                        ),
                        child: const AccountFormView());
                  });
            },
            child: const Icon(Icons.add)),
      ),
    );
  }
}

void _buildTree(TreeNode treeRoot, List<Account> accounts) {
  treeRoot.clear();

  for (var parent in accounts.where((a) => a.parentId == null)) {
    final parentNode = TreeNode<Account>(
      data: parent,
      key: parent.id.toString(),
    );

    final children = accounts
        .where((account) => account.parentId == parent.id)
        .map((child) => TreeNode<Account>(
              data: child,
              key: child.id.toString(),
            ))
        .toList();

    parentNode.addAll(children);
    treeRoot.add(parentNode);
  }
}

Map<int, List<Account>> getChildren(List<Account> accounts) {
  final Map<int, List<Account>> childrenMap = {};
  for (final acc in accounts) {
    if (acc.parentId != null) {
      childrenMap.putIfAbsent(acc.parentId!, () => []).add(acc);
    }
  }

  return childrenMap;
}
