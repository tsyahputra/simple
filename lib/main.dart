import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simple/page/user_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null)
      .then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        cardTheme: CardTheme(
          color: Colors.deepPurple[700],
          elevation: 4,
        ),
        useMaterial3: true,
      ),
      home: UserCheckPoint(),
    );
  }
}
