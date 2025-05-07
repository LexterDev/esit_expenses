import 'package:flutter/material.dart';
import '../db/expense_db.dart';
import '../models/expense.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await ExpenseDB.getAllExpenses();
    setState(() {
      _expenses = data;
    });
  }

  double get _totalExpenses => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  void _addExpense() async {
    final result = await Navigator.pushNamed(context, '/add');
    if (result == true) _loadExpenses();
  }

  void _editExpense(Expense expense) async {
    final result = await Navigator.pushNamed(
      context,
      '/edit',
      arguments: expense,
    );
    if (result == true) _loadExpenses();
  }

  void _deleteExpense(Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Gasto'),
            content: const Text('¿Estás seguro de eliminar este gasto?'),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                child: const Text('Eliminar'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await ExpenseDB.deleteExpense(expense.id!);
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Gastos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: Colors.indigo,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: const Text(
                  'Gasto Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  '\$${_totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Filter by category
            const SizedBox(height: 16),
            _expenses.isNotEmpty
                ? const Text(
                  'Lista de Gastos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
                : const Text(
                  '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _expenses.isEmpty
                      ? const Center(
                        child: Text('No hay transacciones registradas'),
                      )
                      : ListView.builder(
                        itemCount: _expenses.length,
                        itemBuilder: (context, index) {
                          final expense = _expenses[index];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(expense.description),
                              subtitle: Text(
                                '${expense.category} | ${expense.date.toLocal().toString().split(' ')[0]}',
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 25,
                                      ),
                                      onPressed: () => _editExpense(expense),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                      onPressed: () => _deleteExpense(expense),
                                    ),
                                  ],
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.shade100,
                                radius: 25,
                                child: Text(
                                  '\$${expense.amount.toStringAsFixed(2)}',
                                  // expense.amount.toStringAsFixed(0),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }
}
