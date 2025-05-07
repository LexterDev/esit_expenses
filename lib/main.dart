import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_edit_expense_screen.dart';
import 'models/expense.dart';

void main() {
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESIT Expenses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,        
        useMaterial3: false,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add': (context) => const AddEditExpenseScreen(),
      },
      onGenerateRoute: (settings) {
        // Para editar gasto con argumentos
        if (settings.name == '/edit') {
          final expense = settings.arguments as Expense;
          return MaterialPageRoute(
            builder: (context) => AddEditExpenseScreen(expense: expense),
          );
        }
        return null;
      },
    );
  }
}
