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

  Widget _buildOffstageNavigator(int index, Widget child) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: _selectedIndex == index
          ? Navigator(
              key: _navigatorKeys[index],
              onGenerateRoute: (settings) {
                return MaterialPageRoute(builder: (_) => child);
              },
            )
          : const SizedBox.shrink(), // atau Container()
    );
  }


  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onTap(int index) {
    if (_selectedIndex == index) {
      // Tab ditekan ulang → reset stack
      _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });

      // Opsi tambahan: reset stack pada tab tertentu ketika dikunjungi
      // final shouldResetOnTabSwitch = [2]; // reset hanya untuk tab "Akun"
      // if (shouldResetOnTabSwitch.contains(index)) {
      //   _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
      // }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Allows for navigation behavior customization
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_selectedIndex].currentState!.maybePop();

        if (isFirstRouteInCurrentTab) {
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
            return; // Prevents exiting app
          }
          // biarkan keluar app kalau sudah di tab 0
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildOffstageNavigator(0, const Text('Home')),
            _buildOffstageNavigator(1, const TransactionListView()),
            _buildOffstageNavigator(2, const AccountListView()),
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
