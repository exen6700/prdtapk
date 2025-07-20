import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestNetworkService {
  static final TestNetworkService _instance = TestNetworkService._internal();
  factory TestNetworkService() => _instance;
  TestNetworkService._internal();

  // Test network configuration
  static const String networkName = 'PRDT Test Network';
  static const String tokenSymbol = 'PRDT';
  static const int tokenDecimals = 9;
  static const double initialBalance = 1000.0; // Initial PRDT balance
  static const double miningReward = 0.5;
  static const double adReward = 0.5;

  // Create wallet
  Future<Map<String, dynamic>> createWallet() async {
    final random = Random.secure();
    final privateKeyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    final publicKey = _generatePublicKey(privateKeyBytes);
    final walletAddress = _generateWalletAddress(publicKey);
    
    final wallet = {
      'address': walletAddress,
      'private_key': base64Encode(privateKeyBytes),
      'public_key': publicKey,
      'balance': initialBalance,
      'created_at': DateTime.now().toIso8601String(),
      'network': networkName,
    };

    // Save wallet to local storage
    await _saveWallet(wallet);
    
    return wallet;
  }

  // Generate public key
  String _generatePublicKey(List<int> privateKey) {
    final hash = sha256.convert(privateKey);
    return base64Encode(hash.bytes);
  }

  // Generate wallet address
  String _generateWalletAddress(String publicKey) {
    final hash = sha256.convert(utf8.encode(publicKey));
    final address = base64Encode(hash.bytes.take(32).toList());
    return 'PRDT${address.substring(0, 44)}'; // With PRDT prefix
  }

  // Save wallet to local storage
  Future<void> _saveWallet(Map<String, dynamic> wallet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('test_wallet', jsonEncode(wallet));
  }

  // Load wallet from local storage
  Future<Map<String, dynamic>?> loadWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final walletData = prefs.getString('test_wallet');
    if (walletData != null) {
      return jsonDecode(walletData) as Map<String, dynamic>;
    }
    return null;
  }

  // Check balance
  Future<double> getBalance(String walletAddress) async {
    final wallet = await loadWallet();
    if (wallet != null && wallet['address'] == walletAddress) {
      return (wallet['balance'] as num).toDouble();
    }
    return 0.0;
  }

  // Token transfer
  Future<bool> transferTokens(String fromAddress, String toAddress, double amount) async {
    try {
      final fromWallet = await loadWallet();
      if (fromWallet == null || fromWallet['address'] != fromAddress) {
        return false;
      }

      final currentBalance = (fromWallet['balance'] as num).toDouble();
      if (currentBalance < amount) {
        return false;
      }

      // Update balance
      fromWallet['balance'] = currentBalance - amount;
      await _saveWallet(fromWallet);

      // Transaction record
      await _saveTransaction({
        'from': fromAddress,
        'to': toAddress,
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'transfer',
        'status': 'success',
      });

      return true;
    } catch (e) {
      print('Transfer error: $e');
      return false;
    }
  }

  // Mining reward
  Future<bool> addMiningReward(String walletAddress) async {
    return await _addReward(walletAddress, miningReward, 'mining');
  }

  // Ad reward
  Future<bool> addAdReward(String walletAddress) async {
    return await _addReward(walletAddress, adReward, 'ad');
  }

  // Add reward
  Future<bool> _addReward(String walletAddress, double amount, String type) async {
    try {
      final wallet = await loadWallet();
      if (wallet == null || wallet['address'] != walletAddress) {
        return false;
      }

      final currentBalance = (wallet['balance'] as num).toDouble();
      wallet['balance'] = currentBalance + amount;
      await _saveWallet(wallet);

      // Transaction record
      await _saveTransaction({
        'from': 'system',
        'to': walletAddress,
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
        'type': type,
        'status': 'success',
      });

      return true;
    } catch (e) {
      print('Reward error: $e');
      return false;
    }
  }

  // Save transaction
  Future<void> _saveTransaction(Map<String, dynamic> transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = prefs.getStringList('transactions') ?? [];
    transactions.add(jsonEncode(transaction));
    
    // Keep last 100 transactions
    if (transactions.length > 100) {
      transactions.removeAt(0);
    }
    
    await prefs.setStringList('transactions', transactions);
  }

  // Transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory(String walletAddress) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = prefs.getStringList('transactions') ?? [];
    
    final history = <Map<String, dynamic>>[];
    for (final txData in transactions) {
      final tx = jsonDecode(txData) as Map<String, dynamic>;
      if (tx['from'] == walletAddress || tx['to'] == walletAddress) {
        history.add(tx);
      }
    }
    
    // Show newest transactions first
    history.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
    
    return history;
  }

  // Network information
  Map<String, dynamic> getNetworkInfo() {
    return {
      'name': networkName,
      'token_symbol': tokenSymbol,
      'token_decimals': tokenDecimals,
      'initial_balance': initialBalance,
      'mining_reward': miningReward,
      'ad_reward': adReward,
      'total_supply': 2000000000, // 2 billion PRDT
      'network_type': 'test',
    };
  }

  // Wallet information
  Future<Map<String, dynamic>> getWalletInfo(String walletAddress) async {
    final wallet = await loadWallet();
    if (wallet != null && wallet['address'] == walletAddress) {
      return {
        'address': wallet['address'],
        'balance': wallet['balance'],
        'network': wallet['network'],
        'created_at': wallet['created_at'],
      };
    }
    return {};
  }

  // Reset wallet (for testing)
  Future<void> resetWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('test_wallet');
    await prefs.remove('transactions');
  }
} 