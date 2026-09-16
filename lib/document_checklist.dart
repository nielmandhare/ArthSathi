import 'package:flutter/material.dart';
import 'main.dart';
import 'application_preparation.dart';

class DocumentChecklistPage extends StatefulWidget {
  final String schemeName;
  final String? userName;

  const DocumentChecklistPage({
    super.key,
    required this.schemeName,
    this.userName,
  });

  @override
  State<DocumentChecklistPage> createState() => _DocumentChecklistPageState();
}

class _DocumentChecklistPageState extends State<DocumentChecklistPage> {
  late List<_DocumentItem> _documents;

  @override
  void initState() {
    super.initState();
    _documents = _documentsForScheme(widget.schemeName);
  }

  List<_DocumentItem> _documentsForScheme(String scheme) {
    final name = scheme.toLowerCase();

    if (name.contains('mudra')) {
      return [
        _DocumentItem('Aadhaar Card', 'Identity verification', true),
        _DocumentItem('PAN Card', 'Financial and identity verification', true),
        _DocumentItem('Address Proof', 'Proof of current address', true),
        _DocumentItem('Bank Account Details', 'Banking information for the application', true),
        _DocumentItem('Business / Project Details', 'Information about the proposed business', false),
        _DocumentItem('Udyam Registration', 'Business registration, where applicable', false),
      ];
    }

    if (name.contains('employment generation') || name.contains('pmegp')) {
      return [
        _DocumentItem('Aadhaar Card', 'Identity verification', true),
        _DocumentItem('PAN Card', 'Identity and financial verification', true),
        _DocumentItem('Address Proof', 'Proof of residence', true),
        _DocumentItem('Bank Account Details', 'Banking information', true),
        _DocumentItem('Project Report', 'Details of the proposed project', true),
        _DocumentItem('Business / Activity Details', 'Information about the proposed activity', false),
      ];
    }

    if (name.contains('stand-up india')) {
      return [
        _DocumentItem('Aadhaar Card', 'Identity verification', true),
        _DocumentItem('PAN Card', 'Identity and financial verification', true),
        _DocumentItem('Address Proof', 'Proof of residence', true),
        _DocumentItem('Bank Account Details', 'Banking information', true),
        _DocumentItem('Business / Project Details', 'Details of the proposed enterprise', true),
        _DocumentItem('Udyam Registration', 'Business registration, where applicable', false),
      ];
    }

    if (name.contains('daksh')) {
      return [
        _DocumentItem('Aadhaar Card', 'Identity verification', true),
        _DocumentItem('Category Certificate', 'Category verification, where applicable', true),
        _DocumentItem('Address Proof', 'Proof of residence', true),
        _DocumentItem('Bank Account Details', 'Banking information', true),
        _DocumentItem('Educational / Skill Documents', 'Relevant qualification or skill proof', false),
      ];
    }

    if (name.contains('sc-st hub') || name.contains('sc-st')) {
      return [
        _DocumentItem('Aadhaar Card', 'Identity verification', true),
        _DocumentItem('PAN Card', 'Identity and financial verification', true),
        _DocumentItem('SC / ST Certificate', 'Category verification', true),
        _DocumentItem('Business Registration Details', 'Enterprise information', true),
        _DocumentItem('Bank Account Details', 'Banking information', true),
        _DocumentItem('Udyam Registration', 'Business registration, where applicable', false),
      ];
    }

    if (name.contains('svanidhi')) {
      return [
        _DocumentItem('Aadhaar Card', 'Identity verification', true),
        _DocumentItem('Address / Identity Proof', 'Basic applicant verification', true),
        _DocumentItem('Bank Account Details', 'Banking information', true),
        _DocumentItem('Street Vendor / Vendor Details', 'Proof or details of vending activity', true),
        _DocumentItem('Business Details', 'Information about the vending activity', false),
      ];
    }

    return [
      _DocumentItem('Aadhaar Card', 'Identity verification', true),
      _DocumentItem('PAN Card', 'Financial and identity verification', true),
      _DocumentItem('Address Proof', 'Proof of current address', true),
      _DocumentItem('Bank Account Details', 'Banking information', true),
      _DocumentItem('Business / Project Details', 'Information required for the application', false),
    ];
  }

  int get _readyCount => _documents.where((d) => d.ready).length;

  double get _progress =>
      _documents.isEmpty ? 0 : _readyCount / _documents.length;

  void _toggle(int index) {
    setState(() {
      _documents[index].ready = !_documents[index].ready;
    });
  }

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
          'Application Checklist',
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
                widget.schemeName,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Get your documents ready',
                style: TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Review the documents that may be needed before preparing your application.',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),

              _readinessCard(),

              const SizedBox(height: 22),
              const Text(
                'Documents',
                style: TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),

              ...List.generate(
                _documents.length,
                    (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _documentCard(index),
                ),
              ),

              const SizedBox(height: 10),
              _infoNote(),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _readyCount > 0
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplicationPreparationPage(
                          schemeName: widget.schemeName,
                          userName: widget.userName,
                        ),
                      ),
                    );
                  }
                      : null,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Continue to Application Preparation'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _readinessCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Application readiness',
                style: TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$_readyCount / ${_documents.length}',
                style: const TextStyle(
                  color: AppColors.teal,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 9,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _readyCount == _documents.length
                ? 'All listed documents are marked ready.'
                : 'Mark the documents you already have. You can update this checklist later.',
            style: const TextStyle(
              color: Color(0xFF526170),
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentCard(int index) {
    final document = _documents[index];

    return InkWell(
      onTap: () => _toggle(index),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: document.ready
                ? const Color(0xFFD7ECE4)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: document.ready
                    ? const Color(0xFFE7F7F1)
                    : const Color(0xFFF0F5F8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                document.ready
                    ? Icons.check_rounded
                    : Icons.description_outlined,
                color: document.ready ? AppColors.teal : AppColors.navy,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          document.name,
                          style: const TextStyle(
                            color: AppColors.navyDark,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (document.required)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6E5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Required',
                            style: TextStyle(
                              color: Color(0xFF8A6418),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    document.description,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              document.ready
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: document.ready ? AppColors.teal : const Color(0xFFB8C2CC),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.navy,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Document requirements can vary by scheme, lender, applicant and application channel. '
                  'Use this checklist as a preparation aid and verify the final requirements on the official portal.',
              style: TextStyle(
                color: Color(0xFF526170),
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentItem {
  final String name;
  final String description;
  final bool required;
  bool ready;

  _DocumentItem(this.name, this.description, this.required, {this.ready = false});
}
