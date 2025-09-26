import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction_category.dart';
import 'package:finance_tracker/models/transaction/transaction_filter.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/utils/date_calculator.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionFilterWidget extends StatefulWidget {
  const TransactionFilterWidget({super.key});

  @override
  State<StatefulWidget> createState() => TransactionFilterWidgetState();
}

class TransactionFilterWidgetState extends State<TransactionFilterWidget> {
  List<TransactionCategory> _selectedCategories = [];
  List<Account> _selectedAccounts = [];
  var _includeCredit = true;
  var _includeDebit = true;
  var _includePastDue = true;
  var _includeSettled = true;
  var _includeUnsettled = true;
  late DateTime now;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _loadFilter();
  }

  void _loadFilter() {
    final filter = context.read<TransactionListViewmodel>().filter;
    _selectedAccounts = filter.accounts ?? [];
    _selectedCategories = filter.categories ?? [];
    now = DateTime.now();
    _startDate = getFirstDateOfMonth();
    _endDate = getLastDateOfMonth();
    _startDate = filter.startDate ?? _startDate;
    _endDate = filter.endDate ?? _endDate;
    _includePastDue = filter.loadPreviouslyUnsettled ? true : false;

    final transactionType = filter.transactionType;
    if (transactionType == 'credit') {
      _includeDebit = false;
      _includeCredit = true;
    } else if (transactionType == 'debit') {
      _includeDebit = true;
      _includeCredit = false;
    } else {
      _includeDebit = true;
      _includeCredit = true;
    }

    final completion = filter.completion;
    if (completion == 'settled') {
      _includeSettled = true;
      _includeUnsettled = false;
    } else if (completion == 'unsettled') {
      _includeSettled = false;
      _includeUnsettled = true;
    } else {
      _includeSettled = true;
      _includeUnsettled = true;
    }
  }

  Future<void> _pickDate({
    required DateTime? currentValue,
    required ValueChanged<DateTime?> onDatePicked,
  }) async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentValue ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != currentValue) {
      setState(() {
        onDatePicked(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text:
                    "${_startDate.day}/${_startDate.month}/${_startDate.year}",
              ),
              decoration: const InputDecoration(
                labelText: "Start Date",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () {
                _pickDate(
                    currentValue: _startDate,
                    onDatePicked: (date) {
                      _startDate = date != null
                          ? DateTime(
                              date.year, date.month, date.day)
                          : _startDate;
                    });
              },
            ),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: "${_endDate.day}/${_endDate.month}/${_endDate.year}",
              ),
              decoration: const InputDecoration(
                labelText: "End Date",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () {
                _pickDate(
                    currentValue: _endDate,
                    onDatePicked: (date) {
                      _endDate = date != null
                          ? DateTime(
                              date.year, date.month, date.day, 23, 59, 59, 999)
                          : _endDate;
                    });
              },
            ),
            const SizedBox(
              height: AppSizes.paddingSmall,
            ),
            const Text('Type'),
            Wrap(spacing: 5.0, children: [
              FilterChip(
                  label: const Text('Debit'),
                  selected: _includeDebit,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _includeDebit = true;
                      } else {
                        _includeDebit = false;
                      }
                    });
                  }),
              FilterChip(
                  label: const Text('Credit'),
                  selected: _includeCredit,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _includeCredit = true;
                      } else {
                        _includeCredit = false;
                      }
                    });
                  })
            ]),
            const SizedBox(
              height: AppSizes.paddingSmall,
            ),
            const Text('Completion'),
            Wrap(spacing: 5.0, children: [
              FilterChip(
                  label: const Text('Settled'),
                  selected: _includeSettled,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _includeSettled = true;
                      } else {
                        _includeSettled = false;
                      }
                    });
                  }),
              FilterChip(
                  label: const Text('Unsettled'),
                  selected: _includeUnsettled,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _includeUnsettled = true;
                      } else {
                        _includeUnsettled = false;
                      }
                    });
                  })
            ]),
            CheckboxListTile(
              value: _includePastDue,
              onChanged: (val) {
                setState(() {
                  _includePastDue = val ?? false;
                });
              },
              title: const Text("Include overdue"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(
              height: AppSizes.paddingSmall,
            ),
            const Text('Category'),
            Selector<TransactionListViewmodel, List<TransactionCategory>>(
                selector: (_, vm) => vm.categories,
                builder: (_, categories, __) {
                  return Wrap(
                      spacing: 5.0,
                      children: categories
                          .map((category) => FilterChip(
                              label: Text(category.name),
                              selected: _selectedCategories.contains(category),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCategories.add(category);
                                  } else {
                                    _selectedCategories.remove(category);
                                  }
                                });
                              }))
                          .toList());
                }),
            const SizedBox(
              height: AppSizes.paddingSmall,
            ),
            const Text('Account'),
            Selector<TransactionListViewmodel, List<Account>>(
                selector: (_, vm) => vm.accounts,
                builder: (_, accounts, __) {
                  return Wrap(
                      spacing: 5.0,
                      children: accounts
                          .map((account) => FilterChip(
                              label: Text(account.name),
                              selected: _selectedAccounts.contains(account),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedAccounts.add(account);
                                  } else {
                                    _selectedAccounts.remove(account);
                                  }
                                });
                              }))
                          .toList());
                }),
            const SizedBox(
              height: AppSizes.paddingSmall,
            ),
            ElevatedButton(
              onPressed: () async {
                String? transactionType;
                if (_includeCredit && !_includeDebit) {
                  transactionType = 'credit';
                } else if (!_includeCredit && _includeDebit) {
                  transactionType = 'debit';
                }
                String? completion;
                if (_includeSettled && !_includeUnsettled) {
                  completion = 'settled';
                } else if (!_includeSettled && _includeUnsettled) {
                  completion = 'unsettled';
                }
                final vm = context.read<TransactionListViewmodel>();
                vm.filterTransaction(TransactionFilter(
                    startDate: _startDate,
                    accounts:
                        _selectedAccounts.isEmpty ? null : _selectedAccounts,
                    endDate: _endDate,
                    transactionType: transactionType,
                    categories: _selectedCategories.isEmpty
                        ? null
                        : _selectedCategories,
                    loadPreviouslyUnsettled: _includePastDue,
                    completion: completion));
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            )
          ]),
        ),
      ),
    ));
  }
}
