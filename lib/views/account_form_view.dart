import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/viewmodels/account_list_viewmodel.dart';
import 'package:flutter/material.dart';

class AccountFormView extends StatefulWidget {
  const AccountFormView({super.key, required this.viewModel});
  final AccountListViewmodel viewModel;

  @override
  State<AccountFormView> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _AccountFormViewState extends State<AccountFormView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.filter = firstLevelAccountFilter;
  }

  @override
  Widget build(BuildContext context) {
    
  }
}

bool firstLevelAccountFilter (Account account) => account.parentId == null;