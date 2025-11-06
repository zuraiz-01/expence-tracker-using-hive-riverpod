import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/balance_provider.dart';
import '../services/pdf_service.dart';

final balanceProvider = StateProvider<double>((ref) => 0.0);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final notifier = ref.read(expenseProvider.notifier);
    final balance = ref.watch(balanceProvider);

    // Calculate total expense for the current week
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final totalThisWeek = expenses
        .where((e) => e.date.isAfter(startOfWeek))
        .fold<double>(0, (sum, e) => sum + e.amount);

    final remainingBalance = balance - totalThisWeek;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          // 🧾 Export PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              try {
                final file = await PdfService.generateExpenseReport(
                  expenses,
                  totalThisWeek,
                  ref.watch(balanceProvider),
                );
                await OpenFilex.open(file.path);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error opening PDF: $e')),
                );
              }
            },
          ),
          // 💰 Update balance button
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () => _updateBalanceDialog(context, ref, balance),
          ),
        ],
      ),
      body: Column(
        children: [
          // 💰 Balance Card
          Card(
            color: Colors.teal[700],
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        'Rs. ${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Remaining Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        'Rs. ${remainingBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 📅 Weekly total card
          Card(
            color: Colors.teal,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total This Week',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    'Rs. ${totalThisWeek.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 💸 Expense List
          Expanded(
            child: expenses.isEmpty
                ? const Center(
                    child: Text(
                      'No expenses yet. Tap + to add one!',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                        child: ListTile(
                          title: Text(
                            expense.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            expense.date.toLocal().toString().split('.')[0],
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: Text(
                            'Rs. ${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onLongPress: () => notifier.deleteExpense(index),
                          onTap: () =>
                              _editExpenseDialog(context, ref, expense, index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _addExpenseDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 💰 Update Balance Dialog
  Future<void> _updateBalanceDialog(
    BuildContext context,
    WidgetRef ref,
    double balance,
  ) async {
    final controller = TextEditingController(text: balance.toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Balance'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Enter total balance'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newBalance = double.tryParse(controller.text) ?? 0;
              ref.read(balanceProvider.notifier).state = newBalance;
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ➕ Add Expense Dialog
  Future<void> _addExpenseDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (Rs.)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0;
              if (title.isNotEmpty && amount > 0) {
                ref
                    .read(expenseProvider.notifier)
                    .addExpense(
                      Expense(
                        title: title,
                        amount: amount,
                        date: DateTime.now(),
                      ),
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ✏️ Edit Expense Dialog
  Future<void> _editExpenseDialog(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
    int index,
  ) async {
    final titleController = TextEditingController(text: expense.title);
    final amountController = TextEditingController(
      text: expense.amount.toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (Rs.)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0;
              if (title.isNotEmpty && amount > 0) {
                ref
                    .read(expenseProvider.notifier)
                    .updateExpense(
                      index,
                      Expense(
                        title: title,
                        amount: amount,
                        date: DateTime.now(),
                      ),
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
