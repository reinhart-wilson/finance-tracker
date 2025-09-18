import 'package:finance_tracker/views/home_view.dart';
import 'package:finance_tracker/views/transactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/configs/dependencies.dart';
import 'package:finance_tracker/views/accounts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(providers: buildProviders(), child: const MyHomePage()));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme().copyWith(
              displaySmall: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                  textStyle: textTheme.displaySmall))),
      home: const HomeView(),
    );
  }
}
