import 'package:flutter/material.dart';
import 'main.dart';
import 'scheme_details.dart';
import 'dashboard.dart';

class Scheme {
  final String name;
  final String ministry;
  final String description;
  final String benefit;
  final String type;
  final IconData icon;
  final Color iconColor;
  final Set<String> categories;
  final bool scRelevant;
  final String sourceNote;
  final String officialUrl;

  const Scheme({
    required this.name,
    required this.ministry,
    required this.description,
    required this.benefit,
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.categories,
    required this.scRelevant,
    required this.sourceNote,
    required this.officialUrl,
  });
}

const List<Scheme> _schemes = [
  Scheme(
    name: 'Pradhan Mantri MUDRA Yojana',
    ministry: 'Department of Financial Services',
    description: 'Collateral-free institutional credit for eligible micro and small income-generating businesses.',
    benefit: 'Loans up to ₹20 lakh',
    type: 'Business Loan',
    icon: Icons.account_balance_wallet_rounded,
    iconColor: Color(0xFFF4A300),
    categories: {'SC', 'ST', 'OBC', 'General', 'Women'},
    scRelevant: true,
    sourceNote: 'PMMY supports eligible borrowers across Shishu, Kishor, Tarun and Tarun Plus categories.',
    officialUrl: 'https://www.mudra.org.in/',
  ),
  Scheme(
    name: 'Prime Minister’s Employment Generation Programme',
    ministry: 'Ministry of MSME / KVIC',
    description: 'Credit-linked subsidy support for setting up eligible new micro enterprises in the non-farm sector.',
    benefit: 'Up to 35% subsidy',
    type: 'Subsidy',
    icon: Icons.settings_rounded,
    iconColor: Color(0xFF2F80ED),
    categories: {'SC', 'ST', 'OBC', 'General', 'Women'},
    scRelevant: true,
    sourceNote: 'SC beneficiaries are part of the PMEGP Special Category and can receive the higher subsidy rate, subject to scheme conditions.',
    officialUrl: 'https://pmegp.msme.gov.in/Home/',
  ),
  Scheme(
    name: 'Stand-Up India',
    ministry: 'Government of India',
    description: 'Bank finance for eligible SC/ST and women entrepreneurs setting up greenfield enterprises.',
    benefit: '₹10 lakh – ₹1 crore',
    type: 'Business Loan',
    icon: Icons.person_rounded,
    iconColor: Color(0xFF2EAF6F),
    categories: {'SC', 'ST', 'Women'},
    scRelevant: true,
    sourceNote: 'The scheme is designed for SC/ST borrowers and women entrepreneurs for greenfield enterprises.',
    officialUrl: 'https://www.standupmitra.in/',
  ),
  Scheme(
    name: 'PM-DAKSH',
    ministry: 'Ministry of Social Justice & Empowerment',
    description: 'Free skill development and entrepreneurial development support for eligible disadvantaged groups.',
    benefit: 'Free training + support',
    type: 'Skill & Support',
    icon: Icons.school_rounded,
    iconColor: Color(0xFF9B59E8),
    categories: {'SC', 'OBC', 'EWS', 'DNT'},
    scRelevant: true,
    sourceNote: 'PM-DAKSH includes SC beneficiaries and entrepreneurial development programmes.',
    officialUrl: 'https://pmdaksh.dosje.gov.in/',
  ),
  Scheme(
    name: 'National SC-ST Hub',
    ministry: 'Ministry of MSME',
    description: 'Support for SC/ST entrepreneurs through capacity building, market linkages, finance facilitation and procurement support.',
    benefit: 'Market + finance facilitation',
    type: 'Support',
    icon: Icons.business_center_rounded,
    iconColor: Color(0xFF00A7A0),
    categories: {'SC', 'ST'},
    scRelevant: true,
    sourceNote: 'The National SC-ST Hub supports SC/ST entrepreneurs with skilling, capacity building, market linkages and finance facilitation.',
    officialUrl: 'https://www.scsthub.in/',
  ),
  Scheme(
    name: 'PM SVANidhi',
    ministry: 'Ministry of Housing & Urban Affairs',
    description: 'Working-capital support for eligible street vendors, with benefits linked to timely repayment and digital transactions.',
    benefit: 'Working-capital credit',
    type: 'Business Loan',
    icon: Icons.storefront_rounded,
    iconColor: Color(0xFF00A88F),
    categories: {'SC', 'ST', 'OBC', 'General', 'Women'},
    scRelevant: true,
    sourceNote: 'Eligibility depends on street-vendor and scheme-specific conditions.',
    officialUrl: 'https://pmsvanidhi.mohua.gov.in/',
  ),
];

class SchemesPage extends StatefulWidget {
  final String? category;
  final String? userName;
  final bool fromEligibility;

  const SchemesPage({
    super.key,
    this.category,
    this.userName,
    this.fromEligibility = false,
  });

  @override
  State<SchemesPage> createState() => _SchemesPageState();
}

class _SchemesPageState extends State<SchemesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Scheme> get _visibleSchemes {
    final category = widget.category?.trim();

    return _schemes.where((scheme) {
      final matchesCategory = category == null ||
          category.isEmpty ||
          scheme.categories.contains(category) ||
          (category == 'SC' && scheme.scRelevant);

      final matchesFilter = _selectedFilter == 'All' ||
          scheme.type == _selectedFilter ||
          (_selectedFilter == 'Subsidy' && scheme.type == 'Support');

      final q = _searchController.text.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          scheme.name.toLowerCase().contains(q) ||
          scheme.description.toLowerCase().contains(q) ||
          scheme.ministry.toLowerCase().contains(q);

      return matchesCategory && matchesFilter && matchesSearch;
    }).toList();
  }

  void _goBack() {
    if (widget.fromEligibility) {
      // There is no Dashboard underneath when this page was opened
      // directly from Eligibility, so create it when going back.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            userName: widget.userName?.isNotEmpty == true
                ? widget.userName!
                : 'SuHani',
            category: widget.category,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category?.trim();
    final isSc = category == 'SC';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: _goBack,
        ),
        title: const Text(
          'Schemes & Benefits',
          style: TextStyle(
            color: AppColors.navyDark,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isSc)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(.09),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.teal.withOpacity(.20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppColors.teal, size: 20),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Showing support relevant to your SC category.',
                        style: TextStyle(
                          color: AppColors.navyDark.withOpacity(.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search schemes...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.navy, width: 1.2),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 46,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('All'),
                  _filterChip('Business Loan'),
                  _filterChip('Subsidy'),
                  _filterChip('Skill & Support'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _visibleSchemes.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: _visibleSchemes.length,
                itemBuilder: (context, index) {
                  return _schemeCard(_visibleSchemes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final selected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _selectedFilter = label),
        selectedColor: AppColors.navy,
        backgroundColor: const Color(0xFFF0F4F8),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.navy,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }

  Widget _schemeCard(Scheme scheme) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _openSchemeDetails(scheme),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(16, 17, 14, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
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
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: scheme.iconColor.withOpacity(.13),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(scheme.icon, color: scheme.iconColor, size: 29),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.name,
                        style: const TextStyle(
                          color: AppColors.navyDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scheme.ministry,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.navy),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                scheme.description,
                style: const TextStyle(
                  color: Color(0xFF526170),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                _infoPill(Icons.currency_rupee_rounded, scheme.benefit),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _typePill(scheme.type),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill(IconData icon, String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.teal.withOpacity(.07),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.teal),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.teal,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 52, color: AppColors.navy.withOpacity(.35)),
            const SizedBox(height: 12),
            const Text(
              'No matching schemes found',
              style: TextStyle(
                color: AppColors.navyDark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try another search or benefit category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  void _openSchemeDetails(Scheme scheme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SchemeDetailsPage(
          scheme: scheme,
          userCategory: widget.category,
          userName: widget.userName,
        ),
      ),
    );
  }


}
