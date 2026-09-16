import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class ApplicationReviewPage extends StatelessWidget {
  final String schemeName;
  final String? userName;

  const ApplicationReviewPage({
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
          'Review Application',
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
              _progress(),
              const SizedBox(height: 20),

              const Text(
                'Final review',
                style: TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Review the information below before continuing to the official application process.',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),

              _sectionTitle('Selected Scheme'),
              const SizedBox(height: 10),
              _card(
                icon: Icons.account_balance_outlined,
                title: schemeName,
                subtitle: 'Scheme selected through ArthSaathi',
              ),

              const SizedBox(height: 20),
              _sectionTitle('Applicant Details'),
              const SizedBox(height: 10),
              _detailsCard([
                _Detail('Applicant name', userName?.trim().isNotEmpty == true ? userName!.trim() : 'Not provided'),
                _Detail('Age & category', 'Provided during eligibility'),
                _Detail('State & district', 'Provided during eligibility'),
              ]),

              const SizedBox(height: 20),
              _sectionTitle('Business Details'),
              const SizedBox(height: 10),
              _detailsCard([
                _Detail('Business name', 'Provided during eligibility'),
                _Detail('Business type', 'Provided during eligibility'),
                _Detail('Business stage', 'Provided during eligibility'),
              ]),

              const SizedBox(height: 20),
              _sectionTitle('Financial Details'),
              const SizedBox(height: 10),
              _detailsCard([
                _Detail('Funding required', 'Provided during eligibility'),
                _Detail('Funding purpose', 'Provided during eligibility'),
                _Detail('Existing loan / EMI', 'Provided during eligibility'),
              ]),

              const SizedBox(height: 20),
              _sectionTitle('Documents'),
              const SizedBox(height: 10),
              _documentCard(),

              const SizedBox(height: 20),
              _notice(),

              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showConfirmation(context),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Confirm & Continue'),
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
                  'You will continue through the concerned official application channel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progress() {
    return Row(
      children: [
        _step('1', 'Details', true),
        _line(true),
        _step('2', 'Documents', true),
        _line(true),
        _step('3', 'Review', true),
      ],
    );
  }

  Widget _step(String number, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.teal : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? AppColors.teal : AppColors.border,
            ),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: active ? Colors.white : AppColors.textGrey,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _line(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 17),
        color: active ? AppColors.teal : AppColors.border,
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

  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F7F1),
              borderRadius: BorderRadius.circular(13),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(List<_Detail> details) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: Column(
        children: List.generate(details.length, (index) {
          final item = details[index];
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.navyDark,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (index != details.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.border),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _documentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: Column(
        children: [
          _documentRow('Documents marked ready', '4 / 6', true),
          const SizedBox(height: 12),
          _documentRow('Documents to review', '2', false),
        ],
      ),
    );
  }

  Widget _documentRow(String title, String value, bool ready) {
    return Row(
      children: [
        Icon(
          ready ? Icons.check_circle_rounded : Icons.pending_outlined,
          color: ready ? AppColors.teal : const Color(0xFFB17D24),
          size: 21,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
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
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _notice() {
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
          Icon(Icons.info_outline_rounded, color: AppColors.teal, size: 21),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Review all information carefully. ArthSaathi helps prepare and organize your application, '
                  'while final verification, approval and submission are handled by the concerned authority or lender.',
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

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    );
  }

  void _showConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Ready to continue?',
          style: TextStyle(
            color: AppColors.navyDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Your application details have been reviewed. '
              'You will now be taken to the official application portal for this scheme.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Review Again'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _openOfficialPortal(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _openOfficialPortal(BuildContext context) async {
    final url = _officialApplicationUrl(schemeName);
    final uri = Uri.parse(url);

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open the official application portal.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open the official application portal.'),
          ),
        );
      }
    }
  }

  String _officialApplicationUrl(String scheme) {
    final name = scheme.toLowerCase();

    if (name.contains('mudra')) {
      return 'https://www.mudra.org.in/';
    }

    if (name.contains('employment generation') || name.contains('pmegp')) {
      return 'https://www.kviconline.gov.in/pmegpeportal/pmegphome/index.jsp';
    }

    if (name.contains('stand-up india')) {
      return 'https://www.standupmitra.in/';
    }

    if (name.contains('daksh')) {
      return 'https://pmdaksh.dosje.gov.in/';
    }

    if (name.contains('sc-st hub') || name.contains('sc-st')) {
      return 'https://www.scsthub.in/';
    }

    if (name.contains('svanidhi')) {
      return 'https://pmsvanidhi.mohua.gov.in/';
    }

    // Safe fallback: official national scheme discovery/application guidance.
    return 'https://www.myscheme.gov.in/';
  }
}

class _Detail {
  final String label;
  final String value;

  _Detail(this.label, this.value);
}
