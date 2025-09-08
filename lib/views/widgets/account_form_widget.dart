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
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
                onSaved: (value) => accountName = value,
                decoration: const InputDecoration(
                  labelText: 'Nama Akun',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Silakan masukkan nama akun.';
                  }
                  return null;
                }),
            DropdownButtonFormField<Account>(
              value: selectedAccount,
              items: [
                const DropdownMenuItem<Account>(
                  value: null,
                  child: Text('None'),
                ),
                ...accounts.map((account) {
                  return DropdownMenuItem<Account>(
                    value: account,
                    child: Text(account.name),
                  );
                })
              ],
              onChanged: (Account? newValue) {
                setState(() {
                  selectedAccount = newValue;
                });
              },
              onSaved: (value) {
                selectedAccount = value;
              },
              decoration: const InputDecoration(
                labelText: 'Parent Account',
              ),
            ),
            Selector<AccountListViewmodel, bool>(
              selector: (_, vm) => vm.isLoading,
              builder: (context, isLoading, child) {
                return ElevatedButton(
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
                                  balance: 0));
                              if (!mounted) return;
                              Navigator.pop(context);
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Gagal menyimpan akun')),
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
            ),
          ],
        ),
      ),
    ));
  }
}

bool firstLevelAccountFilter(Account account) => account.parentId == null;
