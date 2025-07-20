import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/constants.dart';

class SocialMediaFooter extends StatelessWidget {
  const SocialMediaFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Social media icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialIcon(FontAwesomeIcons.twitter, AppConstants.twitterUrl),
              _buildSocialIcon(FontAwesomeIcons.instagram, AppConstants.instagramUrl),
              _buildSocialIcon(FontAwesomeIcons.telegram, AppConstants.telegramUrl),
              _buildSocialIcon(FontAwesomeIcons.linkedin, AppConstants.linkedinUrl),
              _buildSocialIcon(FontAwesomeIcons.youtube, AppConstants.youtubeUrl),
              _buildSocialIcon(FontAwesomeIcons.globe, AppConstants.websiteUrl),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Copyright text
          const Text(
            AppConstants.copyrightText,
            style: TextStyle(
              color: AppConstants.secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () {
        // In real app, this would open the URL
        print('Opening: $url');
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppConstants.primaryColor,
          size: 20,
        ),
      ),
    );
  }
} 