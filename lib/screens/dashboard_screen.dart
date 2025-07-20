import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/social_media_footer.dart';
import '../widgets/coin_price_card.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _miningTimer;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _miningTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initializeUserData();
    
    // Start mining timer if mining is active
    _startMiningTimer();
  }

  void _startMiningTimer() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isMining) {
      _miningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {});
          
          // Check if mining is complete
          if (userProvider.getMiningProgress() >= 1.0) {
            timer.cancel();
            userProvider.completeMining();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Mining completed! You earned ${AppConstants.miningReward} PRDT. (Test Network)'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      });
    }
  }

  Future<void> _startMining() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.startMining();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppConstants.miningStartedMessage),
        backgroundColor: Colors.blue,
      ),
    );
    
    _startMiningTimer();
  }

  Future<void> _watchAd() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.watchAd();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppConstants.adRewardMessage),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard (Test Network)'),
        backgroundColor: AppConstants.backgroundColor,
        foregroundColor: AppConstants.textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Testnet Warning Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppConstants.testnetWarningMessage,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User info and balance card
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppConstants.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Username
                              Text(
                                'Welcome, ${authProvider.currentUser ?? "User"}!',
                                style: const TextStyle(
                                  color: AppConstants.textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // PRDT Balance
                              Consumer<UserProvider>(
                                builder: (context, userProvider, child) {
                                  return Column(
                                    children: [
                                      Text(
                                        AppConstants.balanceText,
                                        style: const TextStyle(
                                          color: AppConstants.secondaryTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${userProvider.balance.toStringAsFixed(2)} PRDT',
                                        style: const TextStyle(
                                          color: AppConstants.primaryColor,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '(Test Network - No Real Value)',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Network Info
                              Consumer<UserProvider>(
                                builder: (context, userProvider, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Network',
                                            style: TextStyle(
                                              color: AppConstants.secondaryTextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            AppConstants.blockchainNetwork,
                                            style: const TextStyle(
                                              color: Colors.purple,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'Status',
                                            style: TextStyle(
                                              color: AppConstants.secondaryTextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const Text(
                                            'Connected',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Wallet Address Card
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppConstants.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.purple,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'PRDT Test Wallet',
                                    style: TextStyle(
                                      color: AppConstants.textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userProvider.walletAddress,
                                style: const TextStyle(
                                  color: AppConstants.secondaryTextColor,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Row(
                      children: [
                        // Start Mining button
                        Expanded(
                          child: Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              final isMining = userProvider.isMining;
                              final progress = userProvider.getMiningProgress();
                              final remainingTime = userProvider.getRemainingMiningTime();
                              
                              return ElevatedButton(
                                onPressed: isMining ? null : _startMining,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      isMining ? 'Mining...' : AppConstants.startMiningText,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (isMining) ...[
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey[600],
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userProvider.formatTime(remainingTime),
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Watch Ad button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _watchAd,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppConstants.watchAdText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Coin prices section
                    const Text(
                      'Market Prices (Testnet)',
                      style: TextStyle(
                        color: AppConstants.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Coin price cards
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        if (userProvider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        return Column(
                          children: userProvider.coinPrices.map((coin) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CoinPriceCard(
                                symbol: coin['symbol'],
                                price: coin['price'],
                                change: coin['change'],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Support email
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.support_agent,
                            color: AppConstants.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Support',
                                  style: TextStyle(
                                    color: AppConstants.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  AppConstants.supportEmail,
                                  style: const TextStyle(
                                    color: AppConstants.secondaryTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Social media footer
            const SocialMediaFooter(),
          ],
        ),
      ),
    );
  }
} 