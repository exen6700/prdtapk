import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../services/test_network_service.dart';

class UserProvider with ChangeNotifier {
  double _balance = AppConstants.defaultBalance;
  bool _isMining = false;
  DateTime? _miningStartTime;
  List<Map<String, dynamic>> _coinPrices = [];
  bool _isLoading = false;
  String _walletAddress = '';
  
  final TestNetworkService _testNetworkService = TestNetworkService();

  double get balance => _balance;
  bool get isMining => _isMining;
  DateTime? get miningStartTime => _miningStartTime;
  List<Map<String, dynamic>> get coinPrices => _coinPrices;
  bool get isLoading => _isLoading;
  double get solBalance => 0.0; // Test ağında SOL yok
  String get walletAddress => _walletAddress;

  // Initialize user data
  Future<void> initializeUserData() async {
    await loadUserData();
    await loadCoinPrices();
    await loadTestNetworkData();
  }

  // Load user data from local storage
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBalance = prefs.getDouble('user_balance');
      if (savedBalance != null) {
        _balance = savedBalance;
        notifyListeners();
      }
    } catch (e) {
      print('Load user data error: $e');
    }
  }

  // Save user data to local storage
  Future<void> saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('user_balance', _balance);
    } catch (e) {
      print('Save user data error: $e');
    }
  }

  // Load test network data
  Future<void> loadTestNetworkData() async {
    try {
      // Check if wallet exists, if not create one
      var wallet = await _testNetworkService.loadWallet();
      if (wallet == null) {
        print('Creating new test wallet...');
        wallet = await _testNetworkService.createWallet();
      }
      
      _walletAddress = wallet['address'];
      _balance = (wallet['balance'] as num).toDouble();
      
      print('Test wallet loaded: $_walletAddress');
      print('Test balance: $_balance PRDT');
      
      notifyListeners();
    } catch (e) {
      print('Load test network data error: $e');
    }
  }

  // Load coin prices from API
  Future<void> loadCoinPrices() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulated coin prices (in real app, fetch from API)
      _coinPrices = [
        {'symbol': 'BTC', 'price': 45000.0, 'change': 2.5},
        {'symbol': 'ETH', 'price': 3200.0, 'change': -1.2},
        {'symbol': 'SOL', 'price': 120.0, 'change': 5.8},
        {'symbol': 'XRP', 'price': 0.85, 'change': 0.3},
      ];
    } catch (e) {
      print('Load coin prices error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Start mining
  Future<void> startMining() async {
    if (_isMining) return;

    _isMining = true;
    _miningStartTime = DateTime.now();
    notifyListeners();

    // In real app, this would start a timer and call API
    // For now, we'll simulate mining completion after 10 seconds (for testing)
    Future.delayed(const Duration(seconds: 10), () {
      completeMining();
    });
  }

  // Complete mining and add reward
  void completeMining() async {
    if (!_isMining) return;

    _isMining = false;
    _miningStartTime = null;
    
    // Add mining reward to test network
    final success = await _testNetworkService.addMiningReward(_walletAddress);
    if (success) {
      _balance = await _testNetworkService.getBalance(_walletAddress);
      saveUserData();
      notifyListeners();
    }
  }

  // Watch ad and earn reward
  Future<void> watchAd() async {
    // In real app, this would show AdMob ad
    // For now, we'll simulate ad completion
    await Future.delayed(const Duration(seconds: 2));
    
    // Add ad reward to test network
    final success = await _testNetworkService.addAdReward(_walletAddress);
    if (success) {
      _balance = await _testNetworkService.getBalance(_walletAddress);
      saveUserData();
      notifyListeners();
    }
  }

  // Get wallet info from test network
  Future<Map<String, dynamic>> getWalletInfo() async {
    return await _testNetworkService.getWalletInfo(_walletAddress);
  }

  // Transfer PRDT tokens on test network
  Future<bool> transferPrdt(String toAddress, double amount) async {
    try {
      final success = await _testNetworkService.transferTokens(_walletAddress, toAddress, amount);
      if (success) {
        _balance = await _testNetworkService.getBalance(_walletAddress);
        saveUserData();
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error transferring PRDT: $e');
      return false;
    }
  }

  // Get transaction history from test network
  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    return await _testNetworkService.getTransactionHistory(_walletAddress);
  }

  // Get mining progress (0.0 to 1.0)
  double getMiningProgress() {
    if (!_isMining || _miningStartTime == null) return 0.0;
    
    final now = DateTime.now();
    final elapsed = now.difference(_miningStartTime!).inSeconds;
    final totalSeconds = 4 * 60 * 60; // 4 hours in seconds (for production)
    // final totalSeconds = 10; // 10 seconds for testing
    
    return (elapsed / totalSeconds).clamp(0.0, 1.0);
  }

  // Get remaining mining time in seconds
  int getRemainingMiningTime() {
    if (!_isMining || _miningStartTime == null) return 0;
    
    final now = DateTime.now();
    final elapsed = now.difference(_miningStartTime!).inSeconds;
    final totalSeconds = 4 * 60 * 60; // 4 hours in seconds (for production)
    // final totalSeconds = 10; // 10 seconds for testing
    
    return (totalSeconds - elapsed).clamp(0, totalSeconds);
  }

  // Format time as HH:MM:SS
  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Update balance (for testing or external updates)
  void updateBalance(double newBalance) {
    _balance = newBalance;
    saveUserData();
    notifyListeners();
  }

  // Add reward to balance
  void addReward(double amount) {
    _balance += amount;
    saveUserData();
    notifyListeners();
  }

  // Refresh test network data
  Future<void> refreshTestNetworkData() async {
    await loadTestNetworkData();
  }
} 