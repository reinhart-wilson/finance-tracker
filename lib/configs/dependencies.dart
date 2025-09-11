import 'package:finance_tracker/repositories/repositories.dart';
import 'package:finance_tracker/services/local_data_service.dart';
import 'package:finance_tracker/viewmodels/transaction/transaction_category_viewmodel.dart';
import 'package:finance_tracker/viewmodels/view_models.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> buildProviders() {
  final localDataService = LocalDataService();

  return [
    // Repos
    ChangeNotifierProvider<AccountRepository>(
      create: (_) => AccountRepository(localDataService: localDataService),
    ),
    ChangeNotifierProvider<TransactionCategoryRepository>(
      create: (_) =>
          TransactionCategoryRepository(localDataService: localDataService),
    ),
    ChangeNotifierProvider<TransactionRepository>(
      create: (_) => TransactionRepository(localDataService: localDataService),
    ),

    //VMs
    ChangeNotifierProvider<AccountDetailViewmodel>(
      create: (context) => AccountDetailViewmodel(
          accountRepository: context.read<AccountRepository>(),
          transactionRepository: context.read<TransactionRepository>()),
    ),
    ChangeNotifierProvider<AccountListViewmodel>(
        create: (context) => AccountListViewmodel(
            accountRepository: context.read<AccountRepository>(),
            txnRepository: context.read<TransactionRepository>())),
    ChangeNotifierProvider<TransactionFormViewmodel>(
        create: (context) => TransactionFormViewmodel(
            transactionRepository: context.read<TransactionRepository>(),
            accountRepository: context.read<AccountRepository>(),
            categoryRepository: context.read<TransactionCategoryRepository>())),
    ChangeNotifierProvider<TransactionListViewmodel>(
        create: (context) => TransactionListViewmodel(
            txRepository: context.read<TransactionRepository>(),
            accountRepository: context.read<AccountRepository>(),
            categoryRepository: context.read<TransactionCategoryRepository>())),
    ChangeNotifierProvider<TransactionCategoryViewmodel>(
        create: (context) => TransactionCategoryViewmodel(
            accountRepository: context.read<AccountRepository>(),
            categoryRepository: context.read<TransactionCategoryRepository>())),
  ];
}
