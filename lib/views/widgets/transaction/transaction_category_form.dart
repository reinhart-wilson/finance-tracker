import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction_category.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_category_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class TransactionCategoryForm extends StatefulWidget {
  const TransactionCategoryForm({super.key});

  @override
  State<TransactionCategoryForm> createState() => _TransactionCategoryFormState();
}

class _TransactionCategoryFormState extends State<TransactionCategoryForm> {
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
                tempColor = color;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: mediaQuery.viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Add New Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Category Name Field
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Category Name',
                prefixIcon: Icon(Icons.label, color: colorScheme.primary),
                border: const OutlineInputBorder(),
              ),
              onSaved: (value) => _categoryName = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category name.';
                }
                if (value.toLowerCase() == 'none') {
                  return 'Reserved category name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Account Dropdown
            Selector<TransactionCategoryViewmodel, List<Account>>(
              selector: (_, vm) => vm.accounts,
              builder: (_, accounts, __) => DropdownButtonFormField<Account>(
                value: _selectedAccount,
                decoration: InputDecoration(
                  labelText: 'Associated Account',
                  prefixIcon: Icon(Icons.account_balance_wallet,
                      color: colorScheme.primary),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<Account>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...accounts.map(
                    (account) => DropdownMenuItem<Account>(
                      value: account,
                      child: Text(account.name),
                    ),
                  )
                ],
                onChanged: (Account? newValue) {
                  setState(() {
                    _selectedAccount = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Color Picker Preview Button
            Text(
              'Associated Color',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _pickColor(context),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Pick Color',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: useWhiteForeground(_selectedColor)
                        ? Colors.white
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            Selector<TransactionCategoryViewmodel, bool>(
              selector: (_, vm) => vm.isLoading,
              builder: (context, isLoading, child) {
                return ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final vm =
                                context.read<TransactionCategoryViewmodel>();

                            try {
                              await vm.insertCategory(TransactionCategory(
                                name: _categoryName!,
                                color: _selectedColor.toHexString(),
                                defaultAccountId: _selectedAccount?.id,
                              ));

                              if (!context.mounted) return;
                              Navigator.pop(context);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Gagal menyimpan kategori: $e')),
                              );
                            }
                          }
                        },
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
