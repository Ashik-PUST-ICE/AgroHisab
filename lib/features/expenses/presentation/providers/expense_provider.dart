import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';
import '../../data/services/expense_api_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseApiService _apiService = ExpenseApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> get expenses => _expenses;

  List<ExpenseCategoryModel> _categories = [];
  List<ExpenseCategoryModel> get categories => _categories;

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiService.getExpenses(),
        _apiService.getCategories(),
      ]);
      _expenses = results[0] as List<ExpenseModel>;
      _categories = results[1] as List<ExpenseCategoryModel>;
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createExpense(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _apiService.createExpense(body);
      if (ok) {
        await fetchExpenses();
      }
      return ok;
    } catch (e) {
      debugPrint('Error creating expense: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}