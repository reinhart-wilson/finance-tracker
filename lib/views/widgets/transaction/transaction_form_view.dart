import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/models/transaction/transaction_category.dart';
import 'package:finance_tracker/themes/app_sizes.dart';
import 'package:finance_tracker/viewmodels/view_models.dart';
import 'package:finance_tracker/views/formatter/currency_input_formatter.dart';
import 'package:finance_tracker/views/widgets/transaction_category/transaction_category_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

enum TransactionType { income, expense }

class TransactionFormView extends StatefulWidget {
  const TransactionFormView({super.key});

  @override
  State<TransactionFormView> createState() => _TransactionFormViewState();
}

class _TransactionFormViewState extends State<TransactionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = context.read<TransactionFormViewmodel>();
  }

  final TextEditingController _titleController = TextEditingController();
  late TransactionFormViewmodel _vm;
  final dateFormat = DateFormat('dd/MM/yyyy');
  TransactionCategory? _selectedCategory;
  final _addCategorySentinel = TransactionCategory(id: -1, name: '__none__');
  final _noneCategorySentinel = TransactionCategory(id: -2, name: '__add__');

  Account? _selectedAccount;
  TransactionType? _type = TransactionType.income;
  DateTime _selectedTxDate = DateTime.now();
  DateTime? _selectedDueDate;
  bool _hasDueDate = false;
  double? _amount;
  String? _title;

  Future<void> _pickTransactionDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTxDate, // default ke tanggal sekarang
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null && picked != _selectedTxDate) {
      setState(() {
        _selectedTxDate = picked;
      });
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  InputDecoration _textInputDecoration(BuildContext context, String label,
      {IconData? prefixIconData}) {
    return InputDecoration(
      isDense: true,
      labelText: label,
      prefixIcon: prefixIconData != null
          ? Icon(prefixIconData, color: Theme.of(context).colorScheme.primary)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                'Record Transaction',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),

              /// Category Dropdown
              CategoryDropdown(
                inputDecoration: _textInputDecoration(context, 'Category',
                    prefixIconData: Icons.label),
                addCategorySentinel: _addCategorySentinel,
                noneCategorySentinel: _noneCategorySentinel,
                selectedCategory: _selectedCategory,
                onSaved: (newCategory) {
                  setState(() {
                    _selectedCategory = newCategory;
                  });
                },
                onChanged: (newCategory) async {
                  if (newCategory == _addCategorySentinel) {
                    setState(() {
                      _selectedCategory = _addCategorySentinel;
                    });
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const TransactionCategoryForm(),
                    );
                    // fallback to sentinel "None"
                    setState(() {
                      _selectedCategory = _noneCategorySentinel;
                    });
                  } else {
                    setState(() {
                      _selectedCategory = newCategory;
                      if (newCategory != null) {
                        final defaultAccId = newCategory.defaultAccountId;
                        _selectedAccount = defaultAccId == null
                            ? null
                            : _vm.accountList
                                .firstWhere((a) => a.id == defaultAccId);
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              /// Account Dropdown
              DropdownButtonFormField<Account>(
                  value: _selectedAccount,
                  items: _vm.accountList
                      .map((account) => DropdownMenuItem<Account>(
                            value: account,
                            child: Text(account.name),
                          ))
                      .toList(),
                  onChanged: (Account? newValue) {
                    setState(() => _selectedAccount = newValue);
                  },
                  onSaved: (value) => _selectedAccount = value,
                  decoration: _textInputDecoration(context, 'Mutated Account',
                      prefixIconData: Icons.account_balance_wallet)),
              const SizedBox(height: 16),

              // Transaction Type ToggleButton
              // ToggleButtons(
              //   isSelected: [
              //     _type == TransactionType.income,
              //     _type == TransactionType.expense
              //   ],
              //   onPressed: (index) {
              //     setState(() {
              //       _type = index == 0
              //           ? TransactionType.income
              //           : TransactionType.expense;
              //     });
              //   },
              //   borderRadius: BorderRadius.circular(8),
              //   children: const [
              //     Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 16),
              //       child: Text("Income"),
              //     ),
              //     Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 16),
              //       child: Text("Expense"),
              //     ),
              //   ],
              // ),

              /// Transaction Type Radios
              Text(
                'Transaction Type',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: RadioListTile<TransactionType>(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.green,
                            size: theme.textTheme.bodyLarge?.fontSize,
                          ),
                          Text(
                            " Income",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      value: TransactionType.income,
                      groupValue: _type,
                      onChanged: (value) => setState(() => _type = value),
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Flexible(
                    child: RadioListTile<TransactionType>(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.money_off,
                            color: Colors.red,
                            size: theme.textTheme.bodyLarge?.fontSize,
                          ),
                          Text(
                            " Expense",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      value: TransactionType.expense,
                      groupValue: _type,
                      onChanged: (value) => setState(() => _type = value),
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  labelText: "Amount",
                  isDense: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    child: Text(
                      'Rp',
                      style: GoogleFonts.manrope().copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please fill out transaction amount.";
                  }

                  // Remove separators before parsing
                  final numeric = value.replaceAll('.', '');
                  final number = double.tryParse(numeric);

                  if (number == null || number <= 0) {
                    return "Not a valid number.";
                  }

                  return null;
                },
                onSaved: (value) {
                  final numeric = value!.replaceAll('.', '');
                  _amount = double.parse(numeric);
                },
              ),
              const SizedBox(height: 16),

              /// Transaction Date
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: dateFormat.format(_selectedTxDate),
                      ),
                      decoration: _textInputDecoration(
                        context,
                        "Transaction Date",
                        prefixIconData: Icons.calendar_month,
                      ),
                      onTap: _pickTransactionDate,
                    ),
                  ),
                  if (_hasDueDate) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _selectedDueDate == null
                              ? ""
                              : dateFormat.format(_selectedDueDate!),
                        ),
                        decoration: _textInputDecoration(
                          context,
                          "Due Date",
                          prefixIconData: Icons.calendar_month,
                        ),
                        validator: (_) {
                          if (_selectedDueDate == null) {
                            return "Please fill out date.";
                          }
                          if (_selectedTxDate.isAfter(_selectedDueDate!)) {
                            return "Due date has to be after transaction date.";
                          }
                          return null;
                        },
                        onTap: _pickDueDate,
                      ),
                    ),
                  ]
                ],
              ),

              /// Due Checkbox
              CheckboxListTile(
                value: _hasDueDate,
                onChanged: (val) {
                  setState(() {
                    _hasDueDate = val ?? false;
                    if (!_hasDueDate) _selectedDueDate = null;
                  });
                },
                title: Row(
                  children: [
                    Icon(
                      Icons.hourglass_top,
                      color: Colors.amber,
                      size: theme.textTheme.bodyLarge?.fontSize,
                    ),
                    const Text(" This transaction is due "),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(height: 16),

              /// Remarks
              TextFormField(
                controller: _titleController,
                decoration: _textInputDecoration(context, "Remarks"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please fill out remarks.";
                  }
                  return null;
                },
                onSaved: (value) => _title = value,
              ),
              const SizedBox(height: 24),

              /// Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      try {
                        await _vm.insertTransaction(Transaction(
                          title: _title!,
                          amount: _type == TransactionType.income
                              ? _amount!
                              : -_amount!,
                          accountId: _selectedAccount!.id!,
                          date: _selectedTxDate,
                          dueDate: _selectedDueDate,
                          settledDate: _hasDueDate ? null : _selectedDueDate,
                          categoryId: _selectedCategory == _addCategorySentinel
                              ? null
                              : _selectedCategory!.id,
                        ));
                        if (!mounted) return;
                        Navigator.pop(context);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed recording transaction: $e'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryDropdown extends StatelessWidget {
  final TransactionCategory? selectedCategory;
  final void Function(TransactionCategory?) onChanged;
  final void Function(TransactionCategory?) onSaved;
  final TransactionCategory noneCategorySentinel;
  final TransactionCategory addCategorySentinel;
  final InputDecoration? inputDecoration;

  const CategoryDropdown(
      {super.key,
      required this.selectedCategory,
      required this.onChanged,
      required this.onSaved,
      required this.noneCategorySentinel,
      required this.addCategorySentinel,
      this.inputDecoration});

  @override
  Widget build(BuildContext context) {
    return Selector<TransactionFormViewmodel, List<TransactionCategory>>(
      selector: (_, vm) => vm.categories,
      builder: (_, categories, ___) =>
          DropdownButtonFormField<TransactionCategory?>(
              value: selectedCategory,
              items: [
                DropdownMenuItem<TransactionCategory?>(
                  value: noneCategorySentinel, // "None" sentinel
                  child: const Text('None'),
                ),
                ...categories.map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name),
                  ),
                ),
                DropdownMenuItem<TransactionCategory?>(
                  value: addCategorySentinel, // stable sentinel object
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Add category"),
                    ],
                  ),
                ),
              ],
              onChanged: onChanged,
              onSaved: onChanged,
              decoration: inputDecoration),
    );
  }
}
