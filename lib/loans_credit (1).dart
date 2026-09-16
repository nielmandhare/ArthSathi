import 'package:flutter/material.dart';
import 'main.dart';
import 'emi_calculator.dart';
import 'schemes.dart';

class LoansCreditPage extends StatelessWidget {
  const LoansCreditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Loans & Credit'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            _hero(),
            const SizedBox(height: 20),
            const Text(
              'Plan Your Funding',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Understand affordability before you apply.',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 14),
            _actionCard(
              context,
              icon: Icons.calculate_rounded,
              title: 'EMI & Affordability Calculator',
              subtitle: 'Estimate EMI, interest and monthly repayment burden.',
              button: 'Open Calculator',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmiCalculatorPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            _actionCard(
              context,
              icon: Icons.account_balance_rounded,
              title: 'Explore Government Schemes',
              subtitle: 'Find credit, subsidy and business-support schemes.',
              button: 'View Schemes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SchemesPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            _sectionTitle('What you can plan'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _infoCard(Icons.currency_rupee_rounded, 'Loan Need', 'Estimate the amount your business requires.')),
                const SizedBox(width: 10),
                Expanded(child: _infoCard(Icons.event_note_rounded, 'Repayment', 'Compare tenure and monthly affordability.')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _infoCard(Icons.receipt_long_rounded, 'Existing EMI', 'Consider current repayment obligations.')),
                const SizedBox(width: 10),
                Expanded(child: _infoCard(Icons.verified_outlined, 'Eligibility', 'Check scheme-specific criteria separately.')),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.navy),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Calculator results are indicative. Final interest rate, loan amount, eligibility, processing and approval depend on the lender and applicable scheme rules.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white, size: 32),
          SizedBox(height: 14),
          Text(
            'Make borrowing\nmore informed.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.12,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Plan your funding, understand repayment and discover relevant support.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.navy,
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String button,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.teal, size: 25),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              )),
          const SizedBox(height: 5),
          Text(subtitle,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
                height: 1.4,
              )),
          const SizedBox(height: 13),
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Text(button),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String text) {
    return Container(
      height: 142,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.navy, size: 22),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              )),
          const SizedBox(height: 5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.35,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
