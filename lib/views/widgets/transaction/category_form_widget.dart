import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction_category.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_category_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class CategoryFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CategoryFormWidgetState();
}

class CategoryFormWidgetState extends State<CategoryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String? _categoryName;
  Account? _selectedAccount;
  Color _selectedColor = Colors.black;

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = _selectedColor;
        return AlertDialog(
          title: const Text('Pilih Warna'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                tempColor = color; // simpan sementara
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Pilih'),
              onPressed: () {
                setState(() {
                  _selectedColor = tempColor;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TransactionCategoryViewmodel>();
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Nama Kategori'),
                      onSaved: (value) => _categoryName = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan nama akun.';
                        }
                        return null;
                      }),
                  Selector<TransactionCategoryViewmodel, List<Account>>(
                    selector: (_, vm) => vm.accounts,
                    builder: (_, accounts, __) =>
                        DropdownButtonFormField<Account>(
                      items: [
                        const DropdownMenuItem<Account>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...accounts.map((account) => DropdownMenuItem<Account>(
                            value: account, child: Text(account.name)))
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
                        labelText: 'Akun Terkait',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickColor(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedColor, // preview di tombol
                      foregroundColor: useWhiteForeground(_selectedColor)
                          ? Colors.white
                          : Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    child: const Text("Pilih Warna"),
                  ),
                  Selector<TransactionCategoryViewmodel, bool>(
                    selector: (_, vm) => vm.isLoading,
                    builder: (context, isLoading, child) {
                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  try {
                                    final viewModel = vm;
                                    await viewModel.insertCategory(
                                        TransactionCategory(
                                            name: _categoryName!,
                                            color: _selectedColor.toHexString(),
                                            defaultAccountId:
                                                _selectedAccount!.id!));
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Gagal menyimpan akun')),
                                    );
                                  }
                                }
                              },
                        child: isLoading ? child : const Text('Tambah'),
                      );
                    },
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                ],
              ))),
    );
  }
}
