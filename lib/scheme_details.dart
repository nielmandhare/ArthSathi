
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'emi_calculator.dart';
import 'document_checklist.dart';
import 'eligibility_result.dart';
import 'schemes.dart';

class SchemeDetailsPage extends StatelessWidget {
  final Scheme scheme;
  final String? userCategory;
  final String? userName;

  const SchemeDetailsPage({
    super.key,
    required this.scheme,
    this.userCategory,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final category = userCategory?.trim();
    final matchesCategory =
        category != null && category.isNotEmpty && scheme.categories.contains(category);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scheme Details',
          style: TextStyle(
            color: AppColors.navyDark,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 18),

              _sectionTitle('What is this scheme?'),
              const SizedBox(height: 8),
              _textCard(scheme.description),

              const SizedBox(height: 20),
              _sectionTitle('Key Support'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      Icons.currency_rupee_rounded,
                      'Benefit',
                      scheme.benefit,
                      scheme.iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      Icons.category_rounded,
                      'Support type',
                      scheme.type,
                      AppColors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _sectionTitle('Who may be covered?'),
              const SizedBox(height: 8),
              _categoryCard(),

              const SizedBox(height: 20),
              _sectionTitle('Why this scheme is shown'),
              const SizedBox(height: 8),
              _matchCard(matchesCategory),

              const SizedBox(height: 20),
              _sectionTitle('Important'),
              const SizedBox(height: 8),
              _textCard(
                '${scheme.sourceNote}\n\n'
                    'Eligibility shown in ArthSaathi is indicative. '
                    'Final eligibility, approval and sanction are decided by the concerned '
                    'scheme authority or lender.',
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EmiCalculatorPage(
                                  schemeName: scheme.name,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calculate_outlined),
                          label: const Text('Calculate Affordability'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DocumentChecklistPage(
                                  schemeName: scheme.name,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.description_outlined),
                          label: const Text('Prepare Application'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EligibilityResultPage(
                                  scheme: scheme,
                                  userName: userName,
                                  userCategory: userCategory,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.verified_outlined),
                          label: const Text('Check Eligibility'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(scheme.officialUrl);
                            try {
                              final opened = await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                              if (!opened && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unable to open the official website.'),
                                  ),
                                );
                              }
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unable to open the official website.'),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: const Text('Official Website'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE7F7F1), Color(0xFFF4FBF8)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7ECE4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: scheme.iconColor.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              scheme.icon,
              color: scheme.iconColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheme.name,
                  style: const TextStyle(
                    color: AppColors.navyDark,
                    fontSize: 19,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  scheme.ministry,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.navyDark,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _textCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF526170),
          fontSize: 13.5,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _infoCard(
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navyDark,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: scheme.categories
            .map(
              (item) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5F8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _matchCard(bool matchesCategory) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F7F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7ECE4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.teal,
            size: 23,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              matchesCategory
                  ? 'Your selected ${userCategory!} category is covered by this scheme. '
                  'Review the scheme conditions before applying.'
                  : 'This scheme is part of ArthSaathi support discovery. '
                  'Review its conditions to see how it fits your profile.',
              style: const TextStyle(
                color: Color(0xFF2D6F5B),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
