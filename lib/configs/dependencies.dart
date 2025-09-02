import 'package:finance_tracker/repositories/account_repository.dart';
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
        create: (_) => AccountRepository(localDataService)),

    // ViewModels
    ChangeNotifierProvider<AccountListViewmodel>(
        create: (context) =>
            AccountListViewmodel(context.read<AccountRepository>()))
  ];
}
