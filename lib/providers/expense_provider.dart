import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]);

  void addExpense(Expense expense) {
    state = [...state, expense];
  }

  void deleteExpense(int index) {
    state = List.from(state)..removeAt(index);
  }

  void updateExpense(int index, Expense updatedExpense) {
    final newList = List<Expense>.from(state);
    newList[index] = updatedExpense;
    state = newList;
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((
  ref,
) {
  return ExpenseNotifier();
});
