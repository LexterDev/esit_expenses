import 'package:flutter/material.dart';
import '../db/expense_db.dart';
import '../models/expense.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  String _category = 'General';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['General', 'Comida', 'Transporte', 'Entretenimiento', 'Salud'];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.expense?.description ?? '');
    _amountController = TextEditingController(
        text: widget.expense != null ? widget.expense!.amount.toString() : '');
    _category = widget.expense?.category ?? 'General';
    _selectedDate = widget.expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text.trim();
    final amount = double.parse(_amountController.text.trim());

    final expense = Expense(
      id: widget.expense?.id,
      description: description,
      category: _category,
      amount: amount,
      date: _selectedDate,
    );

    if (widget.expense == null) {
      await ExpenseDB.insertExpense(expense);
    } else {
      await ExpenseDB.updateExpense(expense);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Gasto' : 'Nuevo Gasto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese una descripción' : null,
                
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un monto';
                  final number = double.tryParse(value);
                  if (number == null || number <= 0) return 'Monto no válido';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: _selectDate,
                    child: const Text('Seleccionar Fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(isEditing ? 'Actualizar' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
