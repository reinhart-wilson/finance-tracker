import 'package:finance_tracker/views/account_list_view.dart';
import 'package:finance_tracker/views/transaction_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
   int _selectedIndex = 0;

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // biar kita kontrol sendiri
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_selectedIndex].currentState!.maybePop();

        if (isFirstRouteInCurrentTab) {
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
            return; // jangan keluar app
          }
          // biarkan keluar app kalau sudah di tab 0
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            Navigator(
              key: _navigatorKeys[0],
              onGenerateRoute: (settings) =>
                  MaterialPageRoute(builder: (_) => const Text('Home')),
            ),
            Navigator(
              key: _navigatorKeys[1],
              onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (_) => const TransactionListView()),
            ),
            Navigator(
              key: _navigatorKeys[2],
              onGenerateRoute: (settings) =>
                  MaterialPageRoute(builder: (_) => const AccountListView()),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTap,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "Transaksi"),
            BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Akun"),
          ],
        ),
      ),
    );
  }
}
