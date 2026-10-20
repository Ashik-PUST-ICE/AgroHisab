import '../../../../core/network/api_client.dart';
import '../models/expense_model.dart';

class ExpenseApiService {
  final ApiClient _client = ApiClient();

  Future<List<ExpenseModel>> getExpenses() async {
    final res = await _client.get('/expenses');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => ExpenseModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ExpenseCategoryModel>> getCategories() async {
    final res = await _client.get('/expense-categories');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => ExpenseCategoryModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createExpense(Map<String, dynamic> body) async {
    final res = await _client.post('/expenses', body: body);
    return res.success;
  }
}