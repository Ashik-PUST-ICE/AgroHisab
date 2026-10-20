import 'package:flutter/material.dart';
import '../../data/models/market_model.dart';
import '../../data/services/market_api_service.dart';

class MarketProvider extends ChangeNotifier {
  final MarketApiService _apiService = MarketApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<MarketModel> _markets = [];
  List<MarketModel> get markets => _markets;

  Future<void> fetchMarkets() async {
    _isLoading = true;
    notifyListeners();
    try {
      _markets = await _apiService.getMarkets();
    } catch (e) {
      debugPrint('Error loading markets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMarket(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ok = await _apiService.createMarket(body);
      if (ok) {
        await fetchMarkets();
      }
      return ok;
    } catch (e) {
      debugPrint('Error adding market: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}