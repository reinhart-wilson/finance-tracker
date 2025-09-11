import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/viewmodels/view_models.dart';
import 'package:finance_tracker/views/widgets/nullable_date_field.dart';
import 'package:finance_tracker/views/widgets/transaction/child_account_item_widget.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/utils/formatter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/themes/app_sizes.dart';

class AccountDetailView extends StatefulWidget {
  const AccountDetailView({super.key});

  @override
  State<StatefulWidget> createState() => AccountDetailViewState();
}

class AccountDetailViewState extends State<AccountDetailView> {
  final now = DateTime.now();
  DateTime? _dueStartDate;
  DateTime? _dueEndDate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final account = ModalRoute.of(context)!.settings.arguments as Account;
      context.read<AccountDetailViewmodel>().loadAccountInfo(account);
    });

    final now = DateTime.now();
    _dueEndDate = DateTime(now.year, now.month + 1, 0);
  }

  // TODO: add tabs and spendings charts
  // TODO: add edit account functionality
  @override
  Widget build(BuildContext context) {
    final account = ModalRoute.of(context)!.settings.arguments as Account;
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).colorScheme.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Selector<AccountDetailViewmodel, bool>(
        selector: (_, vm) => vm.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final parentUnsettledAmount =
              context.select<AccountDetailViewmodel, double>(
                  (vm) => vm.parentAccountUnsettled ?? 0);
          final childAccounts =
              context.select<AccountDetailViewmodel, List<Account>>(
                  (vm) => vm.childAccountList);

          final parentSettledAmount =
              context.select<AccountDetailViewmodel, double>(
                  (vm) => vm.parentAccountSettled ?? 0);
          final parentProjectedAmount = account.balance + parentUnsettledAmount;

          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Scaffold(
              body: ListView(
                children: [
                  Card(
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
                              Text(
                                account.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    letterSpacing: 0.25),
                              ),
                              IconButton(
                                color: Theme.of(context).colorScheme.onPrimary,
                                icon: const Icon(Icons.edit),
                                onPressed: () {},
                                iconSize: theme.textTheme.titleMedium?.fontSize,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Rp",
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                        fontSize: theme
                                            .textTheme.titleMedium?.fontSize),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                width: theme.textTheme.bodySmall?.fontSize,
                              ),
                              Text(
                                formatCurrency(account.balance,
                                    includeCurrency: false),
                                style: Theme.of(context).textTheme.displaySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingLarge),
                            child: Center(
                              child: RichText(
                                  text: TextSpan(
                                      text: 'Projected: ',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color:
                                                  theme.colorScheme.onPrimary),
                                      children: [
                                    TextSpan(
                                      text: formatCurrency(
                                          parentProjectedAmount,
                                          shorten: true),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: parentProjectedAmount > 0
                                                  ? Colors.green
                                                  : Colors.red),
                                    )
                                  ])),
                            ),
                          ),
                          if (childAccounts.isNotEmpty)
                            const SizedBox(height: AppSizes.paddingSmall),
                          if (childAccounts.isNotEmpty)
                            Selector<AccountDetailViewmodel, Map<int, double>>(
                              selector: (_, vm) =>
                                  vm.unsettledAmountByAccountId,
                              builder: (context, unsettledAmounts, __) =>
                                  SizedBox(
                                height:
                                    110, // beri tinggi untuk ListView horizontal
                                child: buildChildAccountItem(
                                    context, childAccounts, unsettledAmounts),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text("Settled Transactions",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                                child: Text(
                              formatCurrency(parentSettledAmount),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: (parentSettledAmount >= 0)
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold),
                            )),
                          ],
                        ),
                        Selector<AccountDetailViewmodel, List<Transaction>>(
                          selector: (_, vm) => vm.settledTransactions,
                          builder: (context, settledTransactions, _) =>
                              buildTransactionItem(context, settledTransactions,
                                  disableScrollPhysics: true),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text("Transactions Due",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                                icon: Icon(
                                  Icons.calendar_month,
                                  size: theme.textTheme.bodyLarge?.fontSize,
                                ),
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                          title: const Text(
                                              'Filter Unsettled Transactions'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: NullableDateField(
                                                        label: "Start date",
                                                        value: _dueStartDate,
                                                        onChanged: (date) {
                                                          setState(() {
                                                            _dueStartDate =
                                                                date;
                                                          });
                                                        }),
                                                  ),
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: AppSizes
                                                                .paddingMedium),
                                                    child: Text('_'),
                                                  ),
                                                  Expanded(
                                                    child: NullableDateField(
                                                        label: "End date",
                                                        value: _dueEndDate,
                                                        onChanged: (date) {
                                                          setState(() {
                                                            _dueEndDate = date;
                                                          });
                                                        }),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: AppSizes
                                                            .paddingSmall),
                                                child: Text(
                                                  'This will also affect projected balances.',
                                                  style: theme
                                                      .textTheme.labelSmall,
                                                ),
                                              ),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    context
                                                        .read<
                                                            AccountDetailViewmodel>()
                                                        .applyUnsettledFilter(
                                                            startDate:
                                                                _dueStartDate,
                                                            endDate:
                                                                _dueEndDate);
                                                  },
                                                  child: const Text('Apply'))
                                            ],
                                          )));
                                }),
                            Expanded(
                              child: Text(
                                formatCurrency(parentUnsettledAmount),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    color: (parentUnsettledAmount >= 0)
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        Selector<AccountDetailViewmodel, List<Transaction>>(
                          selector: (_, vm) => vm.unsettledTransactions,
                          builder: (context, unsettledTransactions, _) =>
                              buildTransactionItem(
                                  context, unsettledTransactions,
                                  disableScrollPhysics: true),
                        ),
                        const SizedBox(
                          height: AppSizes.paddingSmall,
                        ),
                        Text(
                          "*Changing date range affects projected balances.",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: theme.textTheme.bodySmall?.fontSize),
                        ),
                        const SizedBox(
                          height: AppSizes.paddingSmall,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
