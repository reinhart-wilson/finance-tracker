import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/utils/formatter.dart';
import 'package:finance_tracker/views/account_details.dart';
import 'package:finance_tracker/views/widgets/account/parent_account_card.dart';
import 'package:flutter/material.dart';
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
    final vm = context.read<AccountListViewmodel>();
    context.read<AccountListViewmodel>().filter = null;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).colorScheme.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            scrolledUnderElevation: 0,
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
              _OverviewCard(),
              const SizedBox(
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
                  final parentAccounts = vm.parentAccountList;
                  final childAccounts = vm.childrenMap;

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
              const SizedBox(
                height: AppSizes.paddingMedium,
              )
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

class _OverviewCard extends StatelessWidget {
  @override
  Widget build(context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total balance
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
                  const SizedBox(width: 4),
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
                        fontSize: theme.textTheme.titleMedium?.fontSize,
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
                              children: const [
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
                      child: _OverviewSubdetail(
                    title: 'Due this Month',
                    iconData: Icons.hourglass_top,
                    selector: (vm) => vm.unsettledSum,
                  )),
                  SizedBox(
                    height: 40,
                    child: VerticalDivider(
                      width: AppSizes.paddingLarge,
                      thickness: 1,
                      color: theme.colorScheme.surface,
                    ),
                  ),
                  Expanded(
                      child: _OverviewSubdetail(
                    title: 'Proj. Balance',
                    iconData: Icons.schedule,
                    selector: (vm) => vm.projectedBalance,
                  )),
                ],
              )
            ]),
      ),
    );
  }
}

class _OverviewSubdetail extends StatelessWidget {
  final String title;
  final IconData iconData;
  final double Function(AccountListViewmodel vm) selector;

  const _OverviewSubdetail(
      {required this.title, required this.iconData, required this.selector});

  @override
  Widget build(context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMini),
            Icon(
              iconData,
              size: 14,
              color: theme.colorScheme.onPrimary,
            ),
          ],
        ),
        const SizedBox(
          height: AppSizes.paddingMini,
        ),
        Selector<AccountListViewmodel, double>(
            selector: (_, vm) => selector(vm),
            builder: (__, value, _) {
              return Text(
                formatCurrency(value, shorten: true),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: value < 0 ? Colors.red : Colors.green),
              );
            }),
      ],
    );
  }
}
