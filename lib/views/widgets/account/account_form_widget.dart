import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/viewmodels/account/account_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountFormView extends StatefulWidget {
  const AccountFormView({super.key});

  @override
  State<AccountFormView> createState() => _AccountFormViewState();
}

class _AccountFormViewState extends State<AccountFormView> {
  final _formKey = GlobalKey<FormState>();
  late final List<Account> accounts;
  String? accountName;
  Account? selectedAccount;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<AccountListViewmodel>();
    viewModel.filter = firstLevelAccountFilter;
    accounts = viewModel.accountList;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Account',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // TextFormField
              TextFormField(
                onSaved: (value) => accountName = value,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Silakan masukkan nama akun.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown
              DropdownButtonFormField<Account>(
                value: selectedAccount,
                items: [
                  const DropdownMenuItem<Account>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...accounts.map((account) => DropdownMenuItem<Account>(
                        value: account,
                        child: Text(account.name),
                        
                      )),
                ],
                onChanged: (newValue) => setState(() {
                  selectedAccount = newValue;
                }),
                onSaved: (value) => selectedAccount = value,
                decoration: InputDecoration(
                  labelText: 'Parent Account',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              Selector<AccountListViewmodel, bool>(
                selector: (_, vm) => vm.isLoading,
                builder: (context, isLoading, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                try {
                                  final viewModel =
                                      context.read<AccountListViewmodel>();
                                  await viewModel.insertAccount(Account(
                                    name: accountName!,
                                    parentId: selectedAccount?.id,
                                    balance: 0,
                                  ));
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal menyimpan akun'),
                                    ),
                                  );
                                }
                              }
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add),
                      label:
                          isLoading ? const SizedBox() : const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool firstLevelAccountFilter(Account account) => account.parentId == null;
