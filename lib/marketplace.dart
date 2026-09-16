import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  static const String _ondcUrl = 'https://www.ondc.org/';
  static const String _sellerUrl =
      'https://www.ondc.org/pages/seller-network-participants.html';
  static const String _resourcesUrl =
      'https://resources.ondc.org/guidanceandgoodpractices';

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the official ONDC website.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the official ONDC website.')),
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
          'Marketplace (ONDC)',
          style: TextStyle(
            color: AppColors.navyDark,
            fontSize: 20,
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
                'How ONDC can help',
                style: TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _benefit(
                Icons.language_rounded,
                'Reach more customers',
                'Your catalogue can become discoverable across participating buyer applications.',
              ),
              _benefit(
                Icons.inventory_2_outlined,
                'Digitise your catalogue',
                'Get your products organised for digital commerce through a seller-side participant.',
              ),
              _benefit(
                Icons.support_agent_rounded,
                'Get onboarding support',
                'Seller Network Participants can help with onboarding, catalogue digitisation and e-commerce practices.',
              ),
              const SizedBox(height: 18),
              _steps(),
              const SizedBox(height: 18),
              _officialLinks(context),
              const SizedBox(height: 18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Take your business online',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ONDC is an open network for digital commerce — not a single marketplace app.',
            style: TextStyle(
              color: Color(0xFFDCE8F1),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openUrl(context, _sellerUrl),
              icon: const Icon(Icons.storefront_outlined, size: 18),
              label: const Text('Explore Seller Onboarding'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String title, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.teal, size: 22),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _steps() {
    const steps = [
      ('01', 'Choose a seller-side participant', 'Select a Seller Network Participant that can connect your business to ONDC.'),
      ('02', 'Prepare your catalogue', 'Product information, pricing and inventory need to be organised for digital commerce.'),
      ('03', 'Onboard and go live', 'The participant supports the seller-side onboarding and network connection process.'),
    ];

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seller journey',
            style: TextStyle(
              color: AppColors.navyDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.$1,
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.$2,
                          style: const TextStyle(
                            color: AppColors.navyDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          step.$3,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _officialLinks(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F1),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFD2E9E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Official ONDC resources',
            style: TextStyle(
              color: AppColors.navyDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Use official ONDC information for onboarding and guidance.',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 12),
          _linkButton(
            context,
            Icons.public_rounded,
            'ONDC official website',
            _ondcUrl,
          ),
          _linkButton(
            context,
            Icons.storefront_rounded,
            'Seller Network Participants',
            _sellerUrl,
          ),
          _linkButton(
            context,
            Icons.menu_book_rounded,
            'Seller guidance & checklists',
            _resourcesUrl,
          ),
        ],
      ),
    );
  }

  Widget _linkButton(
    BuildContext context,
    IconData icon,
    String title,
    String url,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: OutlinedButton.icon(
        onPressed: () => _openUrl(context, url),
        icon: Icon(icon, size: 18),
        label: Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.border),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
              'ArthSaathi provides guidance and links to official ONDC resources. '
              'Actual onboarding, participation and commerce services are handled by ONDC and its network participants.',
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
