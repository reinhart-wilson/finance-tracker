import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/utils/formatter.dart';
import 'package:finance_tracker/viewmodels/view_models.dart';
import 'package:finance_tracker/views/widgets/account/account_transaction_filter_dialog.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_action_dialog.dart';
import 'package:finance_tracker/views/widgets/transaction/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountTransactionSection extends StatefulWidget {
  final String title;
  final void Function(DateTime?) onStartDateChanged;
  final void Function(DateTime?) onEndDateChanged;
  final void Function() onApply;
  final List<Transaction> Function(AccountDetailViewmodel) txListSelector;
  final double Function(AccountDetailViewmodel) txAmountSelector;
  final bool limitDate;
  final bool nullable;
  final String? note;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const AccountTransactionSection({
    super.key,
    required this.title,
    required this.txListSelector,
    required this.txAmountSelector,
    this.initialStartDate,
    this.initialEndDate,
    this.limitDate = false,
    this.nullable = false,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onApply,
    this.note,
  });

  @override
  State<AccountTransactionSection> createState() =>
      _AccountTransactionSectionState();
}

class _AccountTransactionSectionState extends State<AccountTransactionSection> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    final childAccounts = context.select<AccountDetailViewmodel, List<Account>>(
      (vm) => vm.childAccountList,
    );
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(widget.title,
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
                  builder: (context) => AccountTransactionFilterDialog(
                    note: widget.note,
                    isLimitDate: widget.limitDate,
                    isNullable: widget.nullable,
                    title: "Filter ${widget.title} Transactions",
                    startDate: startDate,
                    endDate: endDate,
                    onStartDateChanged: (date) {
                      setState(() {
                        startDate = date;
                      });
                      widget.onStartDateChanged(date);
                    },
                    onEndDateChanged: (date) {
                      setState(() {
                        endDate = date;
                      });
                      widget.onEndDateChanged(date);
                    },
                    onApply: widget.onApply,
                  ),
                );
              },
            ),
            Expanded(
              child: Selector<AccountDetailViewmodel, double>(
                selector: (_, vm) => widget.txAmountSelector(vm),
                builder: (context, amount, _) {
                  return Text(
                    formatCurrency(amount),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: (amount >= 0) ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Selector<AccountDetailViewmodel, List<Transaction>>(
          selector: (_, vm) => widget.txListSelector(vm),
          builder: (context, txList, _) {
            final vm = context.read<AccountDetailViewmodel>();
            if (txList.isEmpty) {
              return const Text(
                "No transactions found for the current filter.",
              );
            }
            return TransactionItem(
              disableScrollPhysics: true,
              transactions: txList,
              getAccountNameCallback: (tx) => vm.accountNameOfId(tx.accountId),
              getSubtitleCallback: (tx, accountName) {
                final categoryName = tx.category ?? 'None';
                return childAccounts.isEmpty
                    ? categoryName
                    : '$accountName: $categoryName';
              },
              onLongPressCallback: (tx) async {
                showDialog(
                  context: context,
                  builder: (context) => TransactionActionDialog(
                    tx: tx,
                    onDelete: vm.deleteTransaction,
                    onMarkSettled: vm.markTransactionAsSettled,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
