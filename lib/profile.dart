import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Your Profile';
  String mobile = 'Verified mobile number';
  String location = 'State & district';
  String category = 'General';
  String business = 'Business details not added';
  String income = 'Financial profile not added';
  String language = 'English';
  bool notifications = true;
  bool digiLockerVerified = false;
  bool udyamVerified = false;

  Future<void> _openOfficialSite(String url, String service) async {
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        _message('Unable to open $service right now.');
      }
    } catch (_) {
      if (mounted) _message('Unable to open $service right now.');
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _editProfile() {
    final nameController =
    TextEditingController(text: name == 'Your Profile' ? '' : name);
    final locationController = TextEditingController(
        text: location == 'State & district' ? '' : location);
    final businessController = TextEditingController(
        text: business == 'Business details not added' ? '' : business);
    final incomeController = TextEditingController(
        text: income == 'Financial profile not added' ? '' : income);

    String selectedCategory = const [
      'General',
      'OBC',
      'SC',
      'ST',
      'EWS',
    ].contains(category)
        ? category
        : 'General';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20, 4, 20, MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: AppColors.navyDark,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Update your details used for personalised guidance.',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _field('Name', nameController, Icons.person_outline_rounded),
                    const SizedBox(height: 12),
                    _field('Location', locationController,
                        Icons.location_on_outlined),
                    const SizedBox(height: 12),
                    _field('Business', businessController,
                        Icons.business_outlined),
                    const SizedBox(height: 12),
                    _field('Monthly Income / Turnover', incomeController,
                        Icons.currency_rupee_rounded,
                        keyboard: TextInputType.number),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration:
                      _inputDecoration('Category', Icons.category_outlined),
                      items: const ['General', 'OBC', 'SC', 'ST', 'EWS']
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            name = nameController.text.trim().isEmpty
                                ? 'Your Profile'
                                : nameController.text.trim();
                            location = locationController.text.trim().isEmpty
                                ? 'State & district'
                                : locationController.text.trim();
                            business = businessController.text.trim().isEmpty
                                ? 'Business details not added'
                                : businessController.text.trim();
                            income = incomeController.text.trim().isEmpty
                                ? 'Financial profile not added'
                                : incomeController.text.trim();
                            category = selectedCategory;
                          });
                          Navigator.pop(sheetContext);
                          _message('Profile updated successfully.');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMobileInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mobile Number'),
        content: const Text(
          'Your mobile number is verified and is kept as the login identifier. '
              'Changing it requires a new verification step.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openVerification(String service) {
    final isDigi = service == 'DigiLocker';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                isDigi
                    ? 'assets/images/digilocker.png'
                    : 'assets/images/udyam.png',
                height: 58,
                width: 150,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  isDigi
                      ? Icons.verified_user_rounded
                      : Icons.business_rounded,
                  color: AppColors.navy,
                  size: 42,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service,
                style: const TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isDigi
                    ? 'Use the official DigiLocker website to securely connect your documents.'
                    : 'Use the official Udyam website for business registration and verification.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    if (isDigi) {
                      _openOfficialSite(
                        'https://www.digilocker.gov.in/',
                        'DigiLocker',
                      );
                    } else {
                      _openOfficialSite(
                        'https://udyamregistration.gov.in/',
                        'Udyam',
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text('Open Official $service'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (isDigi) {
                      digiLockerVerified = !digiLockerVerified;
                    } else {
                      udyamVerified = !udyamVerified;
                    }
                  });
                  Navigator.pop(sheetContext);
                  final verified = isDigi ? digiLockerVerified : udyamVerified;
                  _message(
                    '$service status marked as ${verified ? 'verified' : 'not verified'}.',
                  );
                },
                child: Text(
                  isDigi
                      ? (digiLockerVerified
                      ? 'Mark as Not Verified'
                      : 'Mark as Verified')
                      : (udyamVerified
                      ? 'Mark as Not Verified'
                      : 'Mark as Verified'),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Only mark verified after completing verification on the official service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _chooseLanguage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) {
        const languages = ['English', 'Hindi', 'Marathi'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose Language',
                    style: TextStyle(
                      color: AppColors.navyDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              ...languages.map(
                    (item) => RadioListTile<String>(
                  value: item,
                  groupValue: language,
                  title: Text(item),
                  activeColor: AppColors.navy,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => language = value);
                    Navigator.pop(sheetContext);
                    _message('Language changed to $value.');
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _toggleNotifications() {
    setState(() => notifications = !notifications);
    _message(
      notifications ? 'Notifications enabled.' : 'Notifications disabled.',
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.navy),
      filled: true,
      fillColor: const Color(0xFFF7FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.navy, width: 1.3),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboard}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: _inputDecoration(label, icon),
    );
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
          'My Profile',
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
            children: [
              _profileHeader(),
              const SizedBox(height: 20),
              _section('Personal Information', [
                _item(Icons.person_outline_rounded, 'Name', name,
                        () => _editProfile()),
                _item(Icons.phone_outlined, 'Mobile Number', mobile,
                    _showMobileInfo),
                _item(Icons.location_on_outlined, 'Location', location,
                        () => _editProfile()),
                _item(Icons.category_outlined, 'Category', category,
                        () => _editProfile()),
              ]),
              const SizedBox(height: 14),
              _section('Business & Financial Profile', [
                _item(Icons.business_outlined, 'Business', business,
                        () => _editProfile()),
                _item(Icons.currency_rupee_rounded, 'Financial Profile', income,
                        () => _editProfile()),
              ]),
              const SizedBox(height: 14),
              _section('Verification', [
                _verificationItem(
                  'DigiLocker',
                  digiLockerVerified
                      ? 'Verified'
                      : 'Connect your documents',
                  'assets/images/digilocker.png',
                  digiLockerVerified,
                      () => _openVerification('DigiLocker'),
                ),
                _verificationItem(
                  'Udyam',
                  udyamVerified ? 'Verified' : 'Business verification',
                  'assets/images/udyam.png',
                  udyamVerified,
                      () => _openVerification('Udyam'),
                ),
              ]),
              const SizedBox(height: 14),
              _section('Preferences', [
                _item(Icons.language_rounded, 'Language', language,
                    _chooseLanguage),
                _notificationItem(),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.navy),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _privacyNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFFE8F1F7),
            child: Icon(Icons.person_rounded,
                color: AppColors.navy, size: 34),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                      color: AppColors.navyDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 5),
                const Text(
                  'Your profile powers personalised scheme guidance.',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(title,
              style: const TextStyle(
                color: AppColors.navyDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              )),
        ),
        const SizedBox(height: 9),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _item(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.navy.withOpacity(.07),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: AppColors.navy, size: 21),
      ),
      title: Text(title,
          style: const TextStyle(
            color: AppColors.navyDark,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          )),
      subtitle: Text(subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 11.5,
          )),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: Color(0xFF9AAAB8)),
    );
  }

  Widget _verificationItem(String title, String subtitle, String image,
      bool verified, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.border),
        ),
        child: Image.asset(
          image,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.verified_user_rounded,
            color: AppColors.navy,
          ),
        ),
      ),
      title: Text(title,
          style: const TextStyle(
            color: AppColors.navyDark,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          )),
      subtitle: Text(subtitle,
          style: TextStyle(
            color: verified ? AppColors.teal : AppColors.textGrey,
            fontSize: 11.5,
            fontWeight: verified ? FontWeight.w700 : FontWeight.w400,
          )),
      trailing: Icon(
        verified ? Icons.verified_rounded : Icons.chevron_right_rounded,
        color: verified ? AppColors.teal : const Color(0xFF9AAAB8),
      ),
    );
  }

  Widget _notificationItem() {
    return ListTile(
      onTap: _toggleNotifications,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.navy.withOpacity(.07),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.notifications_none_rounded,
            color: AppColors.navy, size: 21),
      ),
      title: const Text('Notifications',
          style: TextStyle(
            color: AppColors.navyDark,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          )),
      subtitle: Text(
        notifications ? 'Enabled' : 'Disabled',
        style: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 11.5,
        ),
      ),
      trailing: Switch(
        value: notifications,
        onChanged: (_) => _toggleNotifications(),
        activeColor: AppColors.teal,
      ),
    );
  }

  Widget _privacyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD2E9E0)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded,
              color: AppColors.teal, size: 20),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Your profile information is used to personalise guidance, '
                  'scheme discovery and support pathways. Always verify details '
                  'before submitting information to an official portal.',
              style: TextStyle(
                color: AppColors.navyDark,
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
