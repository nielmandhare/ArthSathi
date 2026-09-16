import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class ChannelPartnersPage extends StatefulWidget {
  const ChannelPartnersPage({super.key});

  @override
  State<ChannelPartnersPage> createState() => _ChannelPartnersPageState();
}

class _ChannelPartnersPageState extends State<ChannelPartnersPage> {
  String selected = 'All';

  final List<_Partner> partners = const [
    _Partner(
      name: 'SBI Main Branch Pune',
      type: 'Bank / Lending Partner',
      distance: 'Pune',
      reason: 'Suitable for business banking and loan assistance',
      address: 'Collector Office Compound, Dr Ambedkar Road, Pune, Maharashtra 411001',
      icon: Icons.account_balance_rounded,
    ),
    _Partner(
      name: 'District Industry Centre, Pune',
      type: 'Government Support Centre',
      distance: 'Pune',
      reason: 'Business registration and government scheme guidance',
      address: 'Agriculture College Ground, Narveer Tanaji Wadi, Shivajinagar, Pune, Maharashtra 411005',
      icon: Icons.apartment_rounded,
    ),
    _Partner(
      name: 'MSEFC Pune',
      type: 'MSME / Government Support',
      distance: 'Pune',
      reason: 'MSME facilitation and government support',
      address: 'Narveer Tanaji Wadi, Shivajinagar, Pune, Maharashtra 411005',
      icon: Icons.business_center_rounded,
    ),
    _Partner(
      name: 'Bank of India Zonal Office Pune',
      type: 'Bank / Lending Partner',
      distance: 'Pune',
      reason: 'Business banking and credit-related assistance',
      address: '1162/6, Shivajinagar, Near Observatory, Ganeshkhind Road, Pune, Maharashtra 411005',
      icon: Icons.support_agent_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selected == 'All'
        ? partners
        : partners.where((p) => p.type.contains(selected)).toList();

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
          'Channel Partners',
          style: TextStyle(
            color: AppColors.navyDark,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _introCard(),
              const SizedBox(height: 20),
              const Text(
                'Find Support Near You',
                style: TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Connect with a relevant organisation for your next step.',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 14),
              _filterRow(),
              const SizedBox(height: 14),
              _locationCard(),
              const SizedBox(height: 18),
              ...filtered.map((partner) => _partnerCard(partner)),
              const SizedBox(height: 8),
              _trustNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(Icons.handshake_rounded, color: Colors.white, size: 38),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get help beyond the app',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Find banks, government centres and support organisations that can help you move forward.',
                  style: TextStyle(
                    color: Color(0xFFDCE8F1),
                    fontSize: 12.5,
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

  Widget _filterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Bank', 'Government', 'MSME'].map((item) {
          final active = selected == item;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(item),
              selected: active,
              onSelected: (_) => setState(() => selected = item),
              selectedColor: AppColors.navy,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: active ? AppColors.navy : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: active ? Colors.white : AppColors.navyDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _locationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.teal,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your selected location',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Location from your profile',
                  style: TextStyle(
                    color: AppColors.navyDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _partnerCard(_Partner partner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(partner.icon, color: AppColors.navy, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: const TextStyle(
                        color: AppColors.navyDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      partner.type,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                color: AppColors.teal,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.near_me_rounded, size: 17, color: AppColors.teal),
                const SizedBox(width: 7),
                Text(
                  partner.distance,
                  style: const TextStyle(
                    color: AppColors.navyDark,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Suggested because of your requirement',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'Why suggested: ${partner.reason}',
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDetails(partner),
                  icon: const Icon(Icons.info_outline_rounded, size: 17),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openDirections(partner),
                  icon: const Icon(Icons.directions_rounded, size: 17),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trustNote() {
    return Container(
      padding: const EdgeInsets.all(15),
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
              'Partner information should be verified before visiting or sharing documents. '
                  'ArthSaathi does not guarantee approval or services from any partner.',
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

  void _showDetails(_Partner partner) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              partner.name,
              style: const TextStyle(
                color: AppColors.navyDark,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              partner.type,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12.5),
            ),
            const SizedBox(height: 15),
            Text(
              'Why ArthSaathi suggested this',
              style: const TextStyle(
                color: AppColors.navyDark,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              partner.reason,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDirections(_Partner partner) async {
    final encodedDestination = Uri.encodeComponent(partner.address);
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$encodedDestination&travelmode=driving',
    );

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showMessage('Could not open Google Maps.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not open directions right now.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Partner {
  final String name;
  final String type;
  final String distance;
  final String reason;
  final String address;
  final IconData icon;

  const _Partner({
    required this.name,
    required this.type,
    required this.distance,
    required this.reason,
    required this.address,
    required this.icon,
  });
}
