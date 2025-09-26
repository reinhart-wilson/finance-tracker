# finance_tracker

This app is a personal finance tracking app built with Flutter as a personal learning exercise to explore Flutter development and state management using the `provider` package. It is built with my personal needs in mind, but does not necessarily mean it can't be used by other users. It of course has a lot of spaghetti code lines and bad practices in it. I appreciate any feedback, if anyone actually stumbles upon this repo.

The app demonstrates key Flutter concepts such as:
- Managing state with ChangeNotifier and Provider.
- Persisting data with local SQLite database.

## Features
- Account management with child accounts mainly for budgeting purposes.
- Filtering transactions by date ranges and conditions.
- Projecting future balance, taking unsettled transactions into calculations.
- Exporting and importing data with json file.

## Tech stack
- Flutter & Dart
- `provider`
- `sqflite`
