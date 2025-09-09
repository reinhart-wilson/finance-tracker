import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/models/transaction/transaction_category.dart';
import 'package:finance_tracker/viewmodels/view_models.dart';
import 'package:finance_tracker/views/widgets/transaction/category_form_widget.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _vm = context.read<TransactionFormViewmodel>();
  }

  late TransactionFormViewmodel _vm;
  final dateFormat = DateFormat('dd/MM/yyyy');
  TransactionCategory? _selectedCategory;
  Account? _selectedAccount;
  TransactionType? _type = TransactionType.income;
  DateTime _selectedTxDate = DateTime.now();
  DateTime? _selectedDueDate;
  bool _hasDueDate = false;
  double? _amount;
  String? _title;

  Future<void> _pickTransactionDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTxDate, // default ke tanggal sekarang
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CategoryDropdown(
                      selectedCategory: _selectedCategory,
                      onChanged: (newCategory) async {
                        if (newCategory == null) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    CategoryFormWidget()),
                          );
                          if (result is TransactionCategory) {
                            setState(() {
                              _vm.categories.add(result);
                              _selectedCategory = result;
                            });
                          }
                        } else {
                          setState(() {
                            _selectedCategory = newCategory;
                            final defaultAccId = newCategory.defaultAccountId;
                            if (defaultAccId != null) {
                              _selectedAccount = _vm.accountList
                                  .firstWhere((a) => a.id == defaultAccId);
                            }
                          });
                        }
                      },
                    ),
                    Selector<TransactionFormViewmodel, List<Account>>(
                      selector: (_, vm) => vm.accountList,
                      builder: (_, __, ___) => DropdownButtonFormField<Account>(
                        value: _selectedAccount,
                        items: [
                          ..._vm.accountList.map((account) {
                            return DropdownMenuItem<Account>(
                              value: account,
                              child: Text(account.name),
                            );
                          })
                        ],
                        onChanged: (Account? newValue) {
                          setState(() {
                            _selectedAccount = newValue;
                          });
                        },
                        onSaved: (value) {
                          _selectedAccount = value;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Akun',
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<TransactionType>(
                            title: const Text("Penghasilan"),
                            autofocus: true,
                            value: TransactionType.income,
                            groupValue: _type,
                            onChanged: (value) {
                              setState(() {
                                _type = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<TransactionType>(
                            title: const Text("Pengeluaran"),
                            value: TransactionType.expense,
                            groupValue: _type,
                            onChanged: (value) {
                              setState(() {
                                _type = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        prefixText: "Rp ",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Amount tidak boleh kosong";
                        }
                        final number = double.tryParse(value);
                        if (number == null || number <= 0) {
                          return "Masukkan angka yang valid";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // simpan ke model atau variabel
                        _amount = double.parse(value!);
                      },
                    ),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text:
                            "${_selectedTxDate.day}/${_selectedTxDate.month}/${_selectedTxDate.year}",
                      ),
                      decoration: const InputDecoration(
                        labelText: "Tanggal Transaksi",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: _pickTransactionDate,
                    ),
                    CheckboxListTile(
                      value: _hasDueDate,
                      onChanged: (val) {
                        setState(() {
                          _hasDueDate = val ?? false;
                          if (!_hasDueDate) {
                            _selectedDueDate = null; // reset kalau tidak due
                          }
                        });
                      },
                      title: const Text("Ini adalah transaksi jatuh tempo"),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),

                    // Input due date (hanya muncul kalau checkbox dicentang)
                    if (_hasDueDate)
                      TextFormField(
                        readOnly: true,
                        validator: (_) {
                          if (_hasDueDate) {
                            if (_selectedDueDate == null) {
                              return "Tanggal tidak boleh kosong";
                            }
                            if (_selectedTxDate.isAfter(_selectedDueDate!)) {
                              return "Harus setelah tanggal transaksi";
                            }
                          }
                          return null;
                        },
                        controller: TextEditingController(
                          text: _selectedDueDate == null
                              ? ""
                              : dateFormat.format(_selectedDueDate!),
                        ),
                        decoration: const InputDecoration(
                          labelText: "Tanggal Jatuh Tempo",
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: _pickDueDate,
                      ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Berita",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Berita tidak boleh kosong";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // simpan ke model atau variabel
                        _title = (value);
                      },
                    ),
                    ElevatedButton(
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
                                settledDate:
                                    _hasDueDate ? null : _selectedDueDate,
                                categoryId: _selectedCategory?.id));
                            if (!mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Gagal menyimpan transaksi: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Tambah'),
                    )
                  ],
                ))));
  }
}

class CategoryDropdown extends StatelessWidget {
  final TransactionCategory? selectedCategory;
  final void Function(TransactionCategory?) onChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<TransactionFormViewmodel, List<TransactionCategory>>(
      selector: (_, vm) => vm.categories,
      builder: (_, categories, ___) =>
          DropdownButtonFormField<TransactionCategory?>(
        value: selectedCategory,
        items: [
          ...categories.map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(c.name),
            ),
          ),
          const DropdownMenuItem<TransactionCategory?>(
            value: null,
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.blue),
                SizedBox(width: 8),
                Text("Tambah"),
              ],
            ),
          ),
        ],
        onChanged: onChanged,
        decoration: const InputDecoration(labelText: "Kategori Transaksi"),
      ),
    );
  }
}
