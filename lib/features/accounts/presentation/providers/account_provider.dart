import 'package:flutter/material.dart';
import '../../data/models/account_model.dart';
import '../../data/services/account_api_service.dart';

class AccountProvider extends ChangeNotifier {
  final AccountApiService _apiService = AccountApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AccountModel> _accounts = [];
  List<AccountModel> get accounts => _accounts;

  List<LedgerTransactionModel> _ledger = [];
  List<LedgerTransactionModel> get ledger => _ledger;

  AccountModel? _selectedAccount;
  AccountModel? get selectedAccount => _selectedAccount;

  Future<void> fetchAccounts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _accounts = await _apiService.getAccounts();
      if (_accounts.isNotEmpty && _selectedAccount == null) {
        _selectedAccount = _accounts.first;
      }
    } catch (e) {
      debugPrint('Error fetching accounts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectAccountAndLoadLedger(AccountModel acc) async {
    _selectedAccount = acc;
    _isLoading = true;
    notifyListeners();
    try {
      _ledger = await _apiService.getAccountLedger(acc.id);
    } catch (e) {
      debugPrint('Error fetching ledger: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> transferFunds({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _apiService.transferFunds({
        'from_account_id': fromAccountId,
        'to_account_id': toAccountId,
        'amount': amount,
        'notes': notes,
      });
      if (ok) {
        await fetchAccounts();
        if (_selectedAccount != null) {
          await selectAccountAndLoadLedger(_selectedAccount!);
        }
      }
      return ok;
    } catch (e) {
      debugPrint('Error transferring funds: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}