import 'package:flutter/material.dart';
import '../../data/models/market_model.dart';
import '../../data/models/price_observation_model.dart';
import '../../data/services/market_api_service.dart';

class MarketProvider extends ChangeNotifier {
  final MarketApiService _apiService = MarketApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<MarketModel> _markets = [];
  List<MarketModel> get markets => _markets;

  bool _isObsLoading = false;
  bool get isObsLoading => _isObsLoading;

  List<PriceObservationModel> _priceObservations = [];
  List<PriceObservationModel> get priceObservations => _priceObservations;

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

  // API 9: Fetch price observations
  Future<void> fetchPriceObservations(
    int marketId, {
    int? productId,
    String? fromDate,
    String? toDate,
  }) async {
    _isObsLoading = true;
    notifyListeners();
    try {
      _priceObservations = await _apiService.getPriceObservations(
        marketId,
        productId: productId,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      debugPrint('Error loading price observations: $e');
      _priceObservations = [];
    } finally {
      _isObsLoading = false;
      notifyListeners();
    }
  }

  // API 10: Store price observation
  Future<bool> addPriceObservation(int marketId, Map<String, dynamic> body) async {
    _isObsLoading = true;
    notifyListeners();
    try {
      final ok = await _apiService.storePriceObservation(marketId, body);
      if (ok) {
        await fetchPriceObservations(marketId);
      }
      return ok;
    } catch (e) {
      debugPrint('Error adding price observation: $e');
      return false;
    } finally {
      _isObsLoading = false;
      notifyListeners();
    }
  }

  // Delete price observation
  Future<bool> deletePriceObservation(int observationId, int marketId) async {
    try {
      final ok = await _apiService.deletePriceObservation(observationId);
      if (ok) {
        await fetchPriceObservations(marketId);
      }
      return ok;
    } catch (e) {
      debugPrint('Error deleting price observation: $e');
      return false;
    }
  }
}