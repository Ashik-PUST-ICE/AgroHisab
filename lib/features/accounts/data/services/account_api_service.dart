import '../../../../core/network/api_client.dart';
import '../models/account_model.dart';

class AccountApiService {
  final ApiClient _client = ApiClient();

  Future<List<AccountModel>> getAccounts() async {
    final res = await _client.get('/accounts');
    final data = res.data;
    final list = data is Map ? (data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => AccountModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<LedgerTransactionModel>> getAccountLedger(int accountId) async {
    final res = await _client.get('/accounts/$accountId/ledger');
    final data = res.data;
    final list = data is Map ? (data['transactions'] ?? data['data'] ?? data) : data;
    if (list is List) {
      return list.map((e) => LedgerTransactionModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> transferFunds(Map<String, dynamic> body) async {
    final res = await _client.post('/accounts/transfer', body: body);
    return res.success;
  }
}