import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class MentorsPage extends StatelessWidget {
  const MentorsPage({super.key});

  static const String _adpListUrl = 'https://adplist.org/explore';
  static const String _indiaMentorsUrl =
      'https://adplist.org/mentors/location/india';

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the mentor platform.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the mentor platform.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
        ),
        title: const Text(
          'Mentors & Experts',
          style: TextStyle(
            color: AppColors.navyDark,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _hero(context),
              const SizedBox(height: 22),
              const Text(
                'What do you need help with?',
                style: TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a guidance area, then connect with a suitable mentor.',
                style: TextStyle(color: AppColors.textGrey, fontSize: 12.5),
              ),
              const SizedBox(height: 13),
              _topic(Icons.rocket_launch_outlined, 'Business & Entrepreneurship',
                  'Business planning, growth and founder guidance.'),
              _topic(Icons.currency_rupee_rounded, 'Finance & Funding',
                  'Funding, financial planning and loan-related guidance.'),
              _topic(Icons.campaign_outlined, 'Marketing & Sales',
                  'Branding, customer acquisition and selling online.'),
              _topic(Icons.gavel_rounded, 'Legal & Compliance',
                  'Business registrations, compliance and practical questions.'),
              _topic(Icons.code_rounded, 'Technology',
                  'Digital tools, technology adoption and product guidance.'),
              const SizedBox(height: 18),
              _adpListCard(context),
              const SizedBox(height: 16),
              _note(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, Color(0xFF1B537C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.groups_2_rounded, color: Colors.white, size: 38),
          SizedBox(height: 14),
          Text(
            'Get guidance from people with experience',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ArthSaathi helps you identify the kind of expertise you need and connects you to external mentoring pathways.',
            style: TextStyle(
              color: Color(0xFFDCE8F1),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topic(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.teal, size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navyDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9AAAB8),
          ),
        ],
      ),
    );
  }

  Widget _adpListCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD2E9E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.public_rounded,
                  color: AppColors.navy,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Explore mentors on ADPList',
                  style: TextStyle(
                    color: AppColors.navyDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'ADPList provides online 1:1 mentoring. You can browse mentors by expertise and location and review their profiles before booking.',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openUrl(context, _adpListUrl),
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Browse Mentors'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openUrl(context, _indiaMentorsUrl),
              icon: const Icon(Icons.location_on_outlined, size: 18),
              label: const Text('Browse India-based Mentors'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.navy),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _note() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1E2B7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF9A6A00), size: 20),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Mentor availability, profiles and sessions are managed by the external mentoring platform. Verify the mentor profile and session details before sharing sensitive information.',
              style: TextStyle(
                color: Color(0xFF735719),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
