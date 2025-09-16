import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/viewmodels/view_models.dart';
import 'package:finance_tracker/views/widgets/nullable_date_field.dart';
import 'package:finance_tracker/views/widgets/account/child_account_item_widget.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_action_dialog.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_list_item.dart';
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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final account = ModalRoute.of(context)!.settings.arguments as Account;
      context.read<AccountDetailViewmodel>().loadAccountInfo(account);
    });
  }

  // TODO: add tabs and spendings charts
  // TODO: add edit account functionality
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.primary,
          statusBarIconBrightness: Brightness.light,
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Selector<AccountDetailViewmodel, bool>(
            selector: (_, vm) => vm.isLoading,
            builder: (context, isLoading, child) {
              return isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _AccountDetailContent();
            },
            child: _AccountDetailContent(),
          ),
        ));
  }
}

class _AccountDetailContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountDetailContentState();
}

class _AccountDetailContentState extends State<_AccountDetailContent> {
  final now = DateTime.now();
  DateTime? _dueStartDate;
  DateTime? _dueEndDate;
  DateTime? _settledStartDate;
  DateTime? _settledEndDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _dueEndDate = DateTime(now.year, now.month + 1, 0);
    _settledStartDate = DateTime(now.year, now.month, 1);
    _settledEndDate = now;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final childAccounts = context.select<AccountDetailViewmodel, List<Account>>(
        (vm) => vm.childAccountList);

    final parentSettledAmount = context.select<AccountDetailViewmodel, double>(
        (vm) => vm.parentAccountSettled ?? 0);

    return Scaffold(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rp",
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                                fontSize:
                                    theme.textTheme.titleMedium?.fontSize),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        width: theme.textTheme.bodySmall?.fontSize,
                      ),
                      Selector<AccountDetailViewmodel, Account>(
                        selector: (_, vm) => vm.parentAccount!,
                        builder: (context, account, _) {
                          return Text(
                            formatCurrency(account.balance,
                                includeCurrency: false),
                            style: Theme.of(context).textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          );
                        },
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingLarge),
                    child: Center(
                      child: Selector<AccountDetailViewmodel, double>(
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
                                            context.read<AccountDetailViewmodel>().parentAccount!.balance,
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
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text("Settled",
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    IconButton(
                        icon: Icon(
                          Icons.calendar_month,
                          size: theme.textTheme.bodyLarge?.fontSize,
                        ),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) => TransactionFilterDialog(
                                    isLimitEndDate: true,
                                    isNullable: false,
                                    title: "Filter Settled Transactions",
                                    startDate: _settledStartDate,
                                    endDate: _settledEndDate,
                                    onStartDateChanged: (date) {
                                      _settledStartDate = date;
                                    },
                                    onEndDateChanged: (date) {
                                      _settledEndDate = date;
                                    },
                                    onApply: () {
                                      context
                                          .read<AccountDetailViewmodel>()
                                          .applySettledFilter(
                                            startDate: _settledStartDate,
                                            endDate: _settledEndDate,
                                          );
                                    },
                                  ));
                        }),
                    Expanded(
                        child: Selector<AccountDetailViewmodel, double>(
                            selector: (_, vm) => vm.parentAccountSettled!,
                            builder: (context, parentSettledAmount, _) {
                              return Text(
                                formatCurrency(parentSettledAmount),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    color: (parentSettledAmount >= 0)
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold),
                              );
                            })),
                  ],
                ),
                Selector<AccountDetailViewmodel, List<Transaction>>(
                    selector: (_, vm) => vm.settledTransactions,
                    builder: (context, settledTransactions, _) {
                      final vm = context.read<AccountDetailViewmodel>();
                      return TransactionItem(
                          disableScrollPhysics: true,
                          transactions: settledTransactions,
                          getAccountNameCallback: (tx) =>
                              vm.accountNameOfId(tx.accountId),
                          getSubtitleCallback: (tx, accountName) =>
                              childAccounts.isEmpty
                                  ? '${tx.category}'
                                  : '${accountName}: ${tx.category}',
                          onLongPressCallback: (tx) async {
                            showDialog(
                                context: context,
                                builder: (context) => TransactionActionDialog(
                                    tx: tx,
                                    onDelete: vm.deleteTransaction,
                                    onMarkSettled:
                                        vm.markTransactionAsSettled));
                          });
                    }),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text("Due",
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    IconButton(
                        icon: Icon(
                          Icons.calendar_month,
                          size: theme.textTheme.bodyLarge?.fontSize,
                        ),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) => TransactionFilterDialog(
                                    isNullable: true,
                                    title: "Filter Unsettled Transactions",
                                    startDate: _dueStartDate,
                                    endDate: _dueEndDate,
                                    onStartDateChanged: (date) {
                                      _dueStartDate = date;
                                    },
                                    onEndDateChanged: (date) {
                                      _dueEndDate = date;
                                    },
                                    onApply: () {
                                      context
                                          .read<AccountDetailViewmodel>()
                                          .applyUnsettledFilter(
                                            startDate: _dueStartDate,
                                            endDate: _dueEndDate,
                                          );
                                    },
                                    note:
                                        "This also affects projected balances.",
                                  ));
                        }),
                    Expanded(
                      child: Selector<AccountDetailViewmodel, double>(
                          selector: (_, vm) => vm.parentAccountUnsettled!,
                          builder: (_, parentUnsettledAmount, __) {
                            return Text(
                              formatCurrency(parentUnsettledAmount),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: (parentUnsettledAmount >= 0)
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold),
                            );
                          }),
                    )
                  ],
                ),
                Selector<AccountDetailViewmodel, List<Transaction>>(
                    selector: (_, vm) => vm.unsettledTransactions,
                    builder: (context, unsettledTransactions, _) {
                      final vm = context.read<AccountDetailViewmodel>();
                      return TransactionItem(
                          disableScrollPhysics: true,
                          transactions: unsettledTransactions,
                          getAccountNameCallback: (tx) =>
                              vm.accountNameOfId(tx.accountId),
                          getSubtitleCallback: (tx, accountName) =>
                              childAccounts.isEmpty
                                  ? '${tx.category}'
                                  : '${accountName}: ${tx.category}',
                          onLongPressCallback: (tx) async {
                            showDialog(
                                context: context,
                                builder: (context) => TransactionActionDialog(
                                    tx: tx,
                                    onDelete: vm.deleteTransaction,
                                    onMarkSettled:
                                        vm.markTransactionAsSettled));
                          });
                    }),
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
    );
  }
}

class TransactionFilterDialog extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final VoidCallback onApply;
  final String title;
  final String? note;

  final bool isLimitEndDate;

  final bool isNullable;

  const TransactionFilterDialog({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onApply,
    this.note,
    this.isLimitEndDate = false,
    this.isNullable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TransactionFilterDateField(
                  isNullable: isNullable,
                  label: "Start date",
                  value: startDate,
                  onChanged: onStartDateChanged,
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                child: Text('_'),
              ),
              Expanded(
                child: TransactionFilterDateField(
                  isLimitEndDate: isLimitEndDate,
                  isNullable: isNullable,
                  label: "End date",
                  value: endDate,
                  onChanged: onEndDateChanged,
                ),
              ),
            ],
          ),
          if (note != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
              child: Text(
                note!,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ElevatedButton(
            onPressed: () {
              onApply(); // Apply filter logic
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
