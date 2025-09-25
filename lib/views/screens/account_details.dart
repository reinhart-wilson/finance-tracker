import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/utils/date_calculator.dart';
import 'package:finance_tracker/viewmodels/view_models.dart';
import 'package:finance_tracker/views/widgets/account/account_overview_card.dart';
import 'package:finance_tracker/views/widgets/account/account_transaction_section.dart';
import 'package:flutter/material.dart';
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
    _dueEndDate = getLastDateOfMonth();
    _settledStartDate = getLastDateOfMonth();
    _settledEndDate = now;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        children: [
          AccountOverviewCard(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                AccountTransactionSection(
                  title: "Settled",
                  initialStartDate: _settledStartDate,
                  initialEndDate: _settledEndDate,
                  limitDate: true,
                  nullable: false,
                  txListSelector: (vm) => vm.settledTransactions,
                  txAmountSelector: (vm) => vm.parentAccountSettled!,
                  onStartDateChanged: (date) {
                    _settledStartDate = date;
                  },
                  onEndDateChanged: (date) {
                    _settledEndDate = date;
                  },
                  onApply: () {
                    context.read<AccountDetailViewmodel>().applySettledFilter(
                          startDate: _settledStartDate,
                          endDate: _settledEndDate,
                        );
                  },
                ),
                const SizedBox(height: 10),
                AccountTransactionSection(
                  title: "Unsettled",
                  initialStartDate: _dueStartDate,
                  initialEndDate: _dueEndDate,
                  limitDate: false,
                  nullable: true,
                  txListSelector: (vm) => vm.unsettledTransactions,
                  txAmountSelector: (vm) => vm.parentAccountUnsettled!,
                  onStartDateChanged: (date) {
                    _dueStartDate = date;
                  },
                  onEndDateChanged: (date) {
                    _dueEndDate = date;
                  },
                  note: "This also affects projected balances.",
                  onApply: () {
                    context.read<AccountDetailViewmodel>().applyUnsettledFilter(
                          startDate: _dueStartDate,
                          endDate: _dueEndDate,
                        );
                  },
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
    );
  }
}




