import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color backgroundColor = Colors.black;
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Colors.grey;
  
  // Social media links
  static const String twitterUrl = 'https://twitter.com/prdttoken';
  static const String instagramUrl = 'https://instagram.com/prdttoken';
  static const String telegramUrl = 'https://t.me/prdttoken';
  static const String linkedinUrl = 'https://linkedin.com/company/prdttoken';
  static const String youtubeUrl = 'https://youtube.com/prdttoken';
  static const String websiteUrl = 'https://prdttoken.com';
  
  // Support email
  static const String supportEmail = 'support@prdttoken.com';
  
  // Test Network Configuration
  static const bool isTestnet = true;
  static const String environment = 'PRDT TEST NETWORK';
  
  // API URLs (Live Vercel deployment - GitHub Integration)
  static const String baseApiUrl = 'https://prdtapk-d4h8o7ky0-exen6700s-projects.vercel.app/api';
  static const String registerUrl = '$baseApiUrl/register';
  static const String loginUrl = '$baseApiUrl/login';
  static const String sendVerificationUrl = '$baseApiUrl/send-verification';
  static const String verifyCodeUrl = '$baseApiUrl/verify-code';
  
  // PRDT Test Network Configuration
  static const String blockchainNetwork = 'PRDT TEST NETWORK';
  static const String rpcEndpoint = 'local';
  static const String chainId = 'prdt-test';
  static const String cluster = 'test';
  
  // PRDT Test Network Wallet Configuration
  static const String defaultWalletAddress = 'AUTO_GENERATED';
  static const String seedPhrase = 'AUTO_GENERATED';
  
  // PRDT Token Configuration (Test Network)
  static const String tokenMintAddress = 'PRDT_TEST_TOKEN';
  static const String tokenAccountAddress = 'AUTO_GENERATED';
  static const String tokenSymbol = 'PRDT';
  static const int tokenDecimals = 9;
  static const int totalSupply = 2000000000; // 2 billion tokens
  
  // Default values (Test Network)
  static const double defaultBalance = 1000.0; // 1000 PRDT (test network)
  static const double miningReward = 0.5; // 0.5 PRDT (test network)
  static const double adReward = 0.5; // 0.5 PRDT (test network)
  
  // Coin symbols (Testnet prices)
  static const List<String> coinSymbols = ['BTC', 'ETH', 'SOL', 'XRP'];
  
  // Text constants
  static const String appTitle = 'PRDT Token (Test Network)';
  static const String copyrightText = '© All Rights Reserved';
  static const String welcomeMessage = 'Welcome to PRDT Token Test Network';
  static const String registerButtonText = 'New User';
  static const String loginButtonText = 'Login';
  static const String balanceText = 'PRDT Test Network Balance';
  static const String startMiningText = 'Start Mining (Test Network)';
  static const String watchAdText = 'Watch Ad & Earn (Test Network)';
  static const String settingsText = 'Settings';
  
  // Form labels
  static const String usernameLabel = 'Username';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String verificationCodeLabel = 'Verification Code';
  
  // Button texts
  static const String okButtonText = 'OK';
  static const String backButtonText = 'Back';
  static const String submitButtonText = 'Submit';
  static const String cancelButtonText = 'Cancel';
  static const String saveButtonText = 'Save';
  static const String deleteButtonText = 'Delete';
  static const String addButtonText = 'Add';
  
  // Messages
  static const String registrationSuccessMessage = 'Registration successful! Please check your email for verification code. (Test Network)';
  static const String loginSuccessMessage = 'Login successful! Please check your email for verification code. (Test Network)';
  static const String verificationSuccessMessage = 'Verification successful! Welcome to PRDT Token Test Network.';
  static const String welcomeRewardMessage = 'Welcome! You received 1000 PRDT as a gift. (Test Network)';
  static const String miningStartedMessage = 'Mining started! You will receive 0.5 PRDT after 4 hours. (Test Network)';
  static const String adRewardMessage = 'Ad completed! You earned 0.5 PRDT. (Test Network)';
  static const String passwordChangedMessage = 'Password updated successfully.';
  
  // Error messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String serverErrorMessage = 'Server error. Please try again.';
  static const String invalidVerificationCodeMessage = 'Invalid verification code.';
  static const String passwordsDoNotMatchMessage = 'Passwords do not match.';
  static const String invalidEmailMessage = 'Please enter a valid email address.';
  static const String usernameRequiredMessage = 'Username is required.';
  static const String emailRequiredMessage = 'Email is required.';
  static const String passwordRequiredMessage = 'Password is required.';
  
  // Settings texts
  static const String profileSettingsText = 'Profile Information';
  static const String walletAddressText = 'PRDT Test Network Wallet Address';
  static const String requireVerificationText = 'Require verification code on every login';
  static const String trustedDevicesText = 'Trusted Devices';
  static const String changePasswordText = 'Change Password';
  static const String oldPasswordText = 'Old Password';
  static const String newPasswordText = 'New Password';
  static const String confirmNewPasswordText = 'Confirm New Password';
  static const String notificationSettingsText = 'Notification Settings';
  static const String twoFactorAuthText = 'Two-Factor Authentication';
  static const String languageSelectionText = 'Language Selection';
  static const String supportText = 'Support';
  static const String logoutText = 'Logout';
  
  // Test Network specific messages
  static const String testnetWarningMessage = 'This is a PRDT test network environment. Tokens have no real value.';
  static const String testnetInfoMessage = 'Test network tokens are for testing purposes only.';
  static const String testNetworkInfo = 'Built on PRDT Test Network with local blockchain simulation.';
} 