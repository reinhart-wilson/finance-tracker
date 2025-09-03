import 'package:finance_tracker/repositories/account_repository.dart';
import 'package:finance_tracker/repositories/transaction_category_repository.dart';
import 'package:finance_tracker/repositories/transaction_repository.dart';
import 'package:finance_tracker/viewmodels/account_list_viewmodel.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:finance_tracker/services/local_data_service.dart';
import 'package:finance_tracker/repositories/account_repository.dart';

List<SingleChildWidget> buildProviders() {
  final LocalDataService localDataService = LocalDataService();

  return [
    // Repositories
    Provider<AccountRepository>(
        create: (_) => AccountRepository(localDataService: localDataService)),
    Provider<TransactionRepository>(
        create: (_) =>
            TransactionRepository(localDataService: localDataService)),
    Provider<TransactionCategoryRepository>(
        create: (_) =>
            TransactionCategoryRepository(localDataService: localDataService)),

    // ViewModels
    ChangeNotifierProvider<AccountListViewmodel>(
        create: (context) =>
            AccountListViewmodel(repository: context.read<AccountRepository>()))
  ];
}
