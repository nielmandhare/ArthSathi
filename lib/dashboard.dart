
import 'package:flutter/material.dart';
import 'main.dart';
import 'mentors.dart';
import 'schemes.dart';
import 'profile.dart';
import 'channel_partners.dart';
import 'marketplace.dart';
import 'loans_credit (1).dart';
import 'applications.dart';

class DashboardPage extends StatelessWidget {
  final String userName;
  final String? category;

  const DashboardPage({
    super.key,
    this.userName = 'SuHani',
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Good Morning,',
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: AppColors.navyDark,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Big dreams. Right support.',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _roundButton(Icons.notifications_none_rounded),
                        const SizedBox(width: 10),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfilePage(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProfilePage(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8E3D9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.navy,
                                    size: 27,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _hero(context),
                    const SizedBox(height: 18),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: .91,
                      children: [
                        _featureTile(
                          context,
                          Icons.account_balance_rounded,
                          'Schemes &\nBenefits',
                          const Color(0xFF2F80ED),
                              () => _openSchemes(context),
                        ),
                        _featureTile(
                          context,
                          Icons.account_balance_wallet_rounded,
                          'Loans &\nCredit',
                          const Color(0xFFF2A100),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoansCreditPage(),
                              ),
                            );
                          },
                        ),
                        _featureTile(
                          context,
                          Icons.person_search_rounded,
                          'Mentors &\nExperts',
                          const Color(0xFF13A7C8),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MentorsPage(),
                              ),
                            );
                          },
                        ),
                        _featureTile(
                          context,
                          Icons.location_on_rounded,
                          'Channel\nPartners',
                          const Color(0xFF25A96A),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChannelPartnersPage(),
                              ),
                            );
                          },
                        ),
                        _featureTile(
                          context,
                          Icons.shopping_cart_rounded,
                          'Marketplace\n(ONDC)',
                          const Color(0xFF9B59E8),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MarketplacePage(),
                              ),
                            );
                          },
                        ),
                        _featureTile(
                          context,
                          Icons.person_rounded,
                          'My Profile',
                          const Color(0xFF2F80ED),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfilePage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _bottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _roundButton(IconData icon) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, color: AppColors.navy, size: 25),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      height: 205,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE7F7F1), Color(0xFFF4FBF8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7ECE4)),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -25,
            bottom: -20,
            child: Icon(
              Icons.storefront_rounded,
              size: 175,
              color: AppColors.teal.withOpacity(.12),
            ),
          ),
          const Positioned(
            left: 20,
            top: 20,
            right: 125,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find the right scheme\nfor your business',
                  style: TextStyle(
                    color: AppColors.navyDark,
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  'Get personalized recommendations\nbased on your profile.',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            bottom: 18,
            child: ElevatedButton.icon(
              onPressed: () => _openSchemes(context),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Explore Schemes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureTile(
      BuildContext context,
      IconData icon,
      String title,
      Color color,
      VoidCallback onTap,
      ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 29),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 12.5,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Home', true, () {}),
          _navItem(Icons.account_balance_rounded, 'Schemes', false, () => _openSchemes(context)),
          _navItem(
            Icons.description_rounded,
            'Applications',
            false,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ApplicationsPage(),
                ),
              );
            },
          ),
          _navItem(
            Icons.person_rounded,
            'Profile',
            false,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navItem(
      IconData icon,
      String label,
      bool selected,
      VoidCallback onTap,
      ) {
    final color = selected ? AppColors.navy : const Color(0xFF9AAAB8);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSchemes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SchemesPage(category: category),
      ),
    );
  }
}

