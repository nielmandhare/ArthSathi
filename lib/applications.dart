import 'package:flutter/material.dart';
import 'main.dart';

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Applications',
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
              _summary(),
              const SizedBox(height: 22),
              const Text(
                'Your Applications',
                style: TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _applicationCard(
                context,
                scheme: 'Pradhan Mantri MUDRA Yojana',
                status: 'Ready to Apply',
                statusColor: AppColors.teal,
                icon: Icons.account_balance_rounded,
              ),
              _applicationCard(
                context,
                scheme: 'Prime Minister’s Employment Generation Programme',
                status: 'Documents Pending',
                statusColor: const Color(0xFFB7791F),
                icon: Icons.business_center_rounded,
              ),
              const SizedBox(height: 12),
              _infoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Expanded(child: _Metric(number: '2', label: 'Applications')),
          _Divider(),
          Expanded(child: _Metric(number: '1', label: 'Ready')),
          _Divider(),
          Expanded(child: _Metric(number: '1', label: 'Pending')),
        ],
      ),
    );
  }

  Widget _applicationCard(
    BuildContext context, {
    required String scheme,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
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
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(.08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColors.navy, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  scheme,
                  style: const TextStyle(
                    color: AppColors.navyDark,
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application details will be available here.')),
                  );
                },
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.navy, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'ArthSaathi helps you prepare and organize your application. '
              'Final submission and approval happen through the concerned official portal.',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String number;
  final String label;
  const _Metric({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(number, style: const TextStyle(color: AppColors.navy, fontSize: 23, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey, fontSize: 11.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.border);
  }
}
