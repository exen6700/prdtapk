import 'package:solana/solana.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SolanaService {
  static final SolanaService _instance = SolanaService._internal();
  factory SolanaService() => _instance;
  SolanaService._internal();

  late final SolanaClient _client;
  Ed25519HDPublicKey? _publicKey;
  Ed25519HDKeyPair? _keyPair;

  // Initialize Solana client
  Future<void> initialize() async {
    _client = SolanaClient(
      rpcUrl: Uri.parse(AppConstants.rpcEndpoint),
      websocketUrl: Uri.parse('wss://api.testnet.solana.com'),
    );
    
    await _loadWallet();
  }

  // Load wallet from local storage or create new one
  Future<void> _loadWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPrivateKey = prefs.getString('solana_private_key');
    
    if (savedPrivateKey != null) {
      // Load existing wallet
      final privateKeyBytes = List<int>.from(savedPrivateKey.split(',').map((e) => int.parse(e)));
      _keyPair = Ed25519HDKeyPair.fromPrivateKeyBytes(privateKeyBytes);
      _publicKey = _keyPair!.publicKey;
    } else {
      // Create new wallet or use default
      await _createWalletFromSeedPhrase();
    }
  }

  // Create wallet from seed phrase
  Future<void> _createWalletFromSeedPhrase() async {
    try {
      final seed = bip39.mnemonicToSeed(AppConstants.seedPhrase);
      final keyPair = await Ed25519HDKeyPair.fromMnemonic(
        AppConstants.seedPhrase,
        path: "m/44'/501'/0'/0'",
      );
      
      _keyPair = keyPair;
      _publicKey = keyPair.publicKey;
      
      // Save private key to local storage
      final prefs = await SharedPreferences.getInstance();
      final privateKeyBytes = keyPair.privateKey.bytes;
      await prefs.setString('solana_private_key', privateKeyBytes.join(','));
      
    } catch (e) {
      print('Error creating wallet from seed phrase: $e');
      // Fallback to default wallet address
      _publicKey = Ed25519HDPublicKey.fromBase58(AppConstants.defaultWalletAddress);
    }
  }

  // Get current wallet address
  String get walletAddress {
    return _publicKey?.toBase58() ?? AppConstants.defaultWalletAddress;
  }

  // Get SOL balance
  Future<double> getSolBalance() async {
    try {
      final balance = await _client.rpcClient.getBalance(_publicKey!.toBase58());
      final solBalance = balance.value / lamportsPerSol; // Convert lamports to SOL
      
      print('SOL Balance: $solBalance SOL');
      print('Lamports: ${balance.value}');
      print('Wallet Address: ${_publicKey!.toBase58()}');
      
      return solBalance;
    } catch (e) {
      print('Error getting SOL balance: $e');
      return 0.0;
    }
  }

  // Get PRDT token balance
  Future<double> getPrdtBalance() async {
    try {
      // Get token account info
      final tokenAccounts = await _client.rpcClient.getTokenAccountsByOwner(
        _publicKey!.toBase58(),
        TokenAccountsFilter.mint(AppConstants.tokenMintAddress),
      );

      if (tokenAccounts.value.isEmpty) {
        print('No PRDT token accounts found for wallet: ${_publicKey!.toBase58()}');
        return 0.0;
      }

      final accountInfo = await _client.rpcClient.getAccountInfo(
        tokenAccounts.value.first.pubkey.toBase58(),
      );

      if (accountInfo.value == null) {
        print('Token account info is null');
        return 0.0;
      }

      final tokenAccount = AccountLayout.fromAccountInfo(accountInfo.value!);
      final balance = tokenAccount.amount / pow(10, AppConstants.tokenDecimals);
      
      print('PRDT Balance: $balance tokens');
      print('Token Account: ${tokenAccounts.value.first.pubkey.toBase58()}');
      
      return balance;
    } catch (e) {
      print('Error getting PRDT balance: $e');
      return AppConstants.defaultBalance; // Return default balance for testing
    }
  }

  // Transfer PRDT tokens
  Future<bool> transferPrdt(String toAddress, double amount) async {
    try {
      if (_keyPair == null) {
        print('Wallet not initialized');
        return false;
      }

      final amountInSmallestUnit = (amount * pow(10, AppConstants.tokenDecimals)).toInt();
      
      // Create transfer instruction
      final instruction = TokenInstruction.transfer(
        amount: amountInSmallestUnit,
        source: Ed25519HDPublicKey.fromBase58(AppConstants.tokenAccountAddress),
        destination: Ed25519HDPublicKey.fromBase58(toAddress),
        owner: _publicKey!,
        programId: Ed25519HDPublicKey.fromBase58(TokenProgram.programId),
      );

      // Create and send transaction
      final transaction = Transaction();
      transaction.add(instruction);
      
      final signature = await _client.sendAndConfirmTransaction(
        transaction: transaction,
        signers: [_keyPair!],
      );

      print('PRDT transfer successful: $signature');
      return true;
    } catch (e) {
      print('Error transferring PRDT: $e');
      return false;
    }
  }

  // Mint PRDT tokens (for testing)
  Future<bool> mintPrdt(double amount) async {
    try {
      if (_keyPair == null) {
        print('Wallet not initialized');
        return false;
      }

      final amountInSmallestUnit = (amount * pow(10, AppConstants.tokenDecimals)).toInt();
      
      // Create mint instruction
      final instruction = TokenInstruction.mintTo(
        amount: amountInSmallestUnit,
        mint: Ed25519HDPublicKey.fromBase58(AppConstants.tokenMintAddress),
        destination: Ed25519HDPublicKey.fromBase58(AppConstants.tokenAccountAddress),
        authority: _publicKey!,
        programId: Ed25519HDPublicKey.fromBase58(TokenProgram.programId),
      );

      // Create and send transaction
      final transaction = Transaction();
      transaction.add(instruction);
      
      final signature = await _client.sendAndConfirmTransaction(
        transaction: transaction,
        signers: [_keyPair!],
      );

      print('PRDT mint successful: $signature');
      return true;
    } catch (e) {
      print('Error minting PRDT: $e');
      return false;
    }
  }

  // Get transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    try {
      final signatures = await _client.rpcClient.getSignaturesForAddress(
        _publicKey!.toBase58(),
        limit: 10,
      );

      final transactions = <Map<String, dynamic>>[];
      
      for (final sig in signatures.value) {
        final tx = await _client.rpcClient.getTransaction(sig.signature);
        if (tx.value != null) {
          transactions.add({
            'signature': sig.signature,
            'timestamp': sig.blockTime,
            'status': tx.value!.meta?.err == null ? 'Success' : 'Failed',
          });
        }
      }

      return transactions;
    } catch (e) {
      print('Error getting transaction history: $e');
      return [];
    }
  }

  // Check if wallet is connected
  bool get isConnected => _publicKey != null;

  // Get wallet info
  Map<String, dynamic> getWalletInfo() {
    return {
      'address': walletAddress,
      'network': AppConstants.blockchainNetwork,
      'tokenMint': AppConstants.tokenMintAddress,
      'tokenAccount': AppConstants.tokenAccountAddress,
    };
  }
} 