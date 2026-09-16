import 'package:flutter/material.dart';
import 'main.dart';
import 'application_review.dart';

class ApplicationPreparationPage extends StatelessWidget {
  final String schemeName;
  final String? userName;

  const ApplicationPreparationPage({
    super.key,
    required this.schemeName,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
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
          'Application Preparation',
          style: TextStyle(
            color: AppColors.navyDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schemeName,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Review your application',
                style: TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your information is organized below so you can review it before moving to the official application process.',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),

              _sectionTitle('Application Summary'),
              const SizedBox(height: 10),
              _summaryCard(
                icon: Icons.account_balance_outlined,
                title: 'Selected Scheme',
                value: schemeName,
              ),
              const SizedBox(height: 10),
              _summaryCard(
                icon: Icons.person_outline_rounded,
                title: 'Applicant Profile',
                value: 'Your verified / provided profile information',
                trailing: 'Ready',
              ),
              const SizedBox(height: 10),
              _summaryCard(
                icon: Icons.business_outlined,
                title: 'Business Details',
                value: 'Business and activity information collected during eligibility',
                trailing: 'Ready',
              ),
              const SizedBox(height: 10),
              _summaryCard(
                icon: Icons.currency_rupee_rounded,
                title: 'Financial Details',
                value: 'Funding requirement and financial information',
                trailing: 'Review',
              ),

              const SizedBox(height: 22),
              _sectionTitle('Documents'),
              const SizedBox(height: 10),
              _documentStatusCard(),

              const SizedBox(height: 22),
              _sectionTitle('Before you continue'),
              const SizedBox(height: 10),
              _infoCard(),

              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplicationReviewPage(
                          schemeName: schemeName,
                          userName: userName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Review & Prepare Application'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'ArthSaathi prepares and organizes your information.\nFinal submission happens through the concerned official channel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    String? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5F8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.navy, size: 22),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: trailing == 'Ready'
                    ? const Color(0xFFE7F7F1)
                    : const Color(0xFFFFF6E5),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                trailing,
                style: TextStyle(
                  color: trailing == 'Ready'
                      ? AppColors.teal
                      : const Color(0xFF8A6418),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _documentStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _statusRow('Documents marked ready', '4', Icons.check_circle_rounded),
          const Divider(height: 22),
          _statusRow('Documents to review', '2', Icons.pending_outlined),
          const Divider(height: 22),
          _statusRow(
            'Checklist status',
            'Review',
            Icons.fact_check_outlined,
          ),
        ],
      ),
    );
  }

  Widget _statusRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.teal, size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.navyDark,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F7F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7ECE4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security_outlined,
            color: AppColors.teal,
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Check your details carefully before proceeding. '
                  'ArthSaathi does not guarantee approval or submit an application as the final authority. '
                  'The concerned scheme authority or lender makes the final decision.',
              style: TextStyle(
                color: Color(0xFF2D6F5B),
                fontSize: 11.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Application ready for review',
          style: TextStyle(
            color: AppColors.navyDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Your application information has been organized. '
              'The next step will connect this preparation flow to the official application channel.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
