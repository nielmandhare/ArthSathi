import 'package:flutter/material.dart';
import 'main.dart';
import 'schemes.dart';

class EligibilityPage extends StatefulWidget {
const EligibilityPage({super.key});

@override
State<EligibilityPage> createState() =>
_EligibilityPageState();
}

class _EligibilityPageState extends State<EligibilityPage> {
int _currentStep = 0;

// ============================================================
// BASIC INFORMATION
// ============================================================

final TextEditingController _nameController =
TextEditingController();

String? _age;
String? _gender;
String? _category;
String? _state;
String? _district;

// ============================================================
// BUSINESS DETAILS
// ============================================================

String? _hasBusiness;
final TextEditingController _businessNameController =
TextEditingController();

String? _businessCategory;
String? _businessType;
String? _businessStage;
String? _udyamStatus;

// ============================================================
// FINANCIAL DETAILS
// ============================================================

String? _income;
String? _fundingRequired;
String? _fundingPurpose;
String? _existingLoan;

final TextEditingController _emiController =
TextEditingController();

// ============================================================
// OPTIONS
// ============================================================

final List<String> _ages = List.generate(
63,
(index) => '${18 + index}',
);

final List<String> _genders = [
'Female',
'Male',
'Other',
'Prefer not to say',
];

final List<String> _categories = [
'General',
'OBC',
'SC',
'ST',
'EWS',
];

final List<String> _states = [
'Maharashtra',
'Gujarat',
'Karnataka',
'Delhi',
'Tamil Nadu',
'Telangana',
'Uttar Pradesh',
'Madhya Pradesh',
'Rajasthan',
'West Bengal',
];

final List<String> _districts = [
'Pune',
'Mumbai',
'Nagpur',
'Nashik',
'Thane',
'Kolhapur',
'Aurangabad',
];

final List<String> _yesNo = [
'Yes',
'No',
];

final List<String> _businessCategories = [
'Agriculture & Allied',
'Food & Processing',
'Retail',
'Manufacturing',
'Services',
'Technology',
'Handicrafts',
'Textiles',
'Education',
'Healthcare',
'Other',
];

final List<String> _businessTypes = [
'Sole Proprietorship',
'Partnership',
'Private Limited',
'LLP',
'Self Help Group',
'Other',
];

final List<String> _businessStages = [
'Planning to Start',
'New Business',
'Existing Business',
'Growing / Expanding',
];

final List<String> _udyamStatuses = [
'Registered',
'Not Registered',
'Not Sure',
];

final List<String> _incomeRanges = [
'Below ₹1 Lakh',
'₹1 - ₹3 Lakhs',
'₹3 - ₹5 Lakhs',
'₹5 - ₹10 Lakhs',
'Above ₹10 Lakhs',
];

final List<String> _fundingRanges = [
'Below ₹50,000',
'₹50,000 - ₹1 Lakh',
'₹1 - ₹5 Lakhs',
'₹5 - ₹10 Lakhs',
'Above ₹10 Lakhs',
];

final List<String> _fundingPurposes = [
'Start a Business',
'Working Capital',
'Purchase Equipment',
'Business Expansion',
'Loan / Credit',
'Subsidy',
'Training / Skill Development',
'Other',
];

// ============================================================
// DISPOSE
// ============================================================

@override
void dispose() {
_nameController.dispose();
_businessNameController.dispose();
_emiController.dispose();
super.dispose();
}

// ============================================================
// NEXT
// ============================================================

void _next() {
// STEP 1 — Basic Information
if (_currentStep == 0) {
if (_nameController.text.trim().isEmpty ||
_age == null ||
_gender == null ||
_category == null ||
_state == null ||
_district == null) {
_showMessage('Please complete all basic information.');
return;
}

setState(() {
_currentStep = 1;
});
return;
}

// STEP 2 — Business Details
if (_currentStep == 1) {
if (_hasBusiness == null) {
_showMessage('Please tell us whether you already have a business.');
return;
}

if (_hasBusiness == 'Yes') {
if (_businessNameController.text.trim().isEmpty ||
_businessCategory == null ||
_businessStage == null ||
_businessType == null ||
_udyamStatus == null) {
_showMessage('Please complete all business details.');
return;
}
} else {
// No existing business:
// Clear business-only values so they cannot affect later matching.
_businessNameController.clear();
_businessCategory = null;
_businessType = null;
_udyamStatus = null;

// Business Stage is still useful because the user can be planning
// to start a business, so we ask only for that one field.
if (_businessStage == null) {
_showMessage('Please select your business stage.');
return;
}
}

setState(() {
_currentStep = 2;
});
return;
}

// STEP 3 — Financial Details
if (_currentStep == 2) {
if (_income == null ||
_fundingRequired == null ||
_fundingPurpose == null ||
_existingLoan == null) {
_showMessage('Please complete your financial details.');
return;
}

if (_existingLoan == 'Yes' &&
_emiController.text.trim().isEmpty) {
_showMessage('Please enter your current monthly EMI.');
return;
}

if (_existingLoan == 'No') {
_emiController.clear();
}

setState(() {
_currentStep = 3;
});
return;
}

// STEP 4 — Result
if (_currentStep == 3) {
// Open personalized schemes using the category selected in the form.
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) => SchemesPage(
category: _category,
userName: _nameController.text.trim(),
fromEligibility: true,
),
),
);
}
}

// ============================================================
// BACK
// ============================================================

void _back() {
if (_currentStep > 0) {
setState(() {
_currentStep--;
});
} else {
Navigator.pop(context);
}
}

// ============================================================
// MESSAGE
// ============================================================

void _showMessage(String message) {
ScaffoldMessenger.of(context).hideCurrentSnackBar();

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
margin: const EdgeInsets.all(16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
body: SafeArea(
child: Column(
children: [
// ============================================================
// TOP BAR
// ============================================================

Padding(
padding: const EdgeInsets.fromLTRB(
20,
14,
20,
0,
),
child: Row(
children: [
IconButton(
onPressed: _back,
padding: EdgeInsets.zero,
constraints:
const BoxConstraints(),
icon: const Icon(
Icons.arrow_back_ios_new_rounded,
size: 22,
color: AppColors.navy,
),
),

const SizedBox(width: 10),

const Text(
'Eligibility Check',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.w800,
color: AppColors.navy,
),
),

const Spacer(),

IconButton(
onPressed: () {
_showMessage(
'Your eligibility profile has been saved.',
);
},
icon: const Icon(
Icons.favorite_border_rounded,
size: 30,
color: AppColors.navy,
),
tooltip: 'Save',
),
],
),
),

// ============================================================
// PROGRESS
// ============================================================

Padding(
padding: const EdgeInsets.fromLTRB(
28,
18,
28,
8,
),
child: _ProgressIndicator(
currentStep: _currentStep,
),
),

// ============================================================
// CONTENT
// ============================================================

Expanded(
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(
24,
18,
24,
100,
),
child: _buildCurrentStep(),
),
),

// ============================================================
// BOTTOM BUTTON
// ============================================================

Container(
padding: const EdgeInsets.fromLTRB(
20,
12,
20,
16,
),
decoration: BoxDecoration(
color: Colors.white,
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.06),
blurRadius: 12,
offset: const Offset(0, -3),
),
],
),
child: SizedBox(
width: double.infinity,
height: 54,
child: ElevatedButton(
onPressed: _next,
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.navy,
foregroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
child: Text(
_currentStep == 3
? 'View My Schemes'
    : 'Next  →',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w700,
),
),
),
),
),
],
),
),
);
}

// ============================================================
// STEP CONTENT
// ============================================================

Widget _buildCurrentStep() {
switch (_currentStep) {
case 0:
return _buildBasicInfo();

case 1:
return _buildBusinessDetails();

case 2:
return _buildFinancials();

case 3:
return _buildResult();

default:
return _buildBasicInfo();
}
}

// ============================================================
// STEP 1 — BASIC INFORMATION
// ============================================================

Widget _buildBasicInfo() {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Basic Information',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.w800,
color: AppColors.navy,
),
),

const SizedBox(height: 22),

_label('Name'),

const SizedBox(height: 8),

_textField(
controller: _nameController,
hint: 'Enter your full name',
),

const SizedBox(height: 20),

_label('Age'),

const SizedBox(height: 8),

_dropdown(
value: _age,
hint: 'Select Age',
items: _ages,
onChanged: (value) {
setState(() {
_age = value;
});
},
),

const SizedBox(height: 20),

_label('Gender'),

const SizedBox(height: 8),

_dropdown(
value: _gender,
hint: 'Select Gender',
items: _genders,
onChanged: (value) {
setState(() {
_gender = value;
});
},
),

const SizedBox(height: 20),

_label('Category'),

const SizedBox(height: 8),

_dropdown(
value: _category,
hint: 'Select Category',
items: _categories,
onChanged: (value) {
setState(() {
_category = value;
});
},
),

const SizedBox(height: 20),

_label('State'),

const SizedBox(height: 8),

_dropdown(
value: _state,
hint: 'Select State',
items: _states,
onChanged: (value) {
setState(() {
_state = value;
_district = null;
});
},
),

const SizedBox(height: 20),

_label('District'),

const SizedBox(height: 8),

_dropdown(
value: _district,
hint: 'Select District',
items: _districts,
onChanged: (value) {
setState(() {
_district = value;
});
},
),
],
);
}

// ============================================================
// STEP 2 — BUSINESS DETAILS
// ============================================================

Widget _buildBusinessDetails() {
final bool hasBusiness = _hasBusiness == 'Yes';
final bool noBusiness = _hasBusiness == 'No';

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Business Details',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.w800,
color: AppColors.navy,
),
),

const SizedBox(height: 8),

Text(
noBusiness
? 'Tell us about your business plans so we can find relevant support.'
    : 'Tell us about your business so we can find relevant schemes.',
style: const TextStyle(
fontSize: 13.5,
height: 1.4,
color: AppColors.textGrey,
),
),

const SizedBox(height: 24),

_label('Do you already have a business?'),

const SizedBox(height: 8),

_dropdown(
value: _hasBusiness,
hint: 'Select',
items: _yesNo,
onChanged: (value) {
setState(() {
_hasBusiness = value;

// When switching to "No", remove fields that are only
// meaningful for an existing business.
if (value == 'No') {
_businessNameController.clear();
_businessCategory = null;
_businessType = null;
_udyamStatus = null;
}
});
},
),

// Existing-business fields
if (hasBusiness) ...[
const SizedBox(height: 20),

_label('Business Name'),

const SizedBox(height: 8),

_textField(
controller: _businessNameController,
hint: 'Enter business name',
),

const SizedBox(height: 20),

_label('Business Category'),

const SizedBox(height: 8),

_dropdown(
value: _businessCategory,
hint: 'Select Business Category',
items: _businessCategories,
onChanged: (value) {
setState(() {
_businessCategory = value;
});
},
),

const SizedBox(height: 20),
],

// Business stage is relevant for both existing and future
// entrepreneurs, so it remains visible.
_label('Business Stage'),

const SizedBox(height: 8),

_dropdown(
value: _businessStage,
hint: 'Select Business Stage',
items: _businessStages,
onChanged: (value) {
setState(() {
_businessStage = value;
});
},
),

// These fields are only relevant when an existing business exists.
if (hasBusiness) ...[
const SizedBox(height: 20),

_label('Business Type'),

const SizedBox(height: 8),

_dropdown(
value: _businessType,
hint: 'Select Business Type',
items: _businessTypes,
onChanged: (value) {
setState(() {
_businessType = value;
});
},
),

const SizedBox(height: 20),

_label('Udyam Registration'),

const SizedBox(height: 8),

_dropdown(
value: _udyamStatus,
hint: 'Select Status',
items: _udyamStatuses,
onChanged: (value) {
setState(() {
_udyamStatus = value;
});
},
),
],
],
);
}

// ============================================================
// STEP 3 — FINANCIALS
// ============================================================

Widget _buildFinancials() {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Financial Information',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.w800,
color: AppColors.navy,
),
),

const SizedBox(height: 8),

const Text(
'This helps us understand the financial support you may need.',
style: TextStyle(
fontSize: 13.5,
height: 1.4,
color: AppColors.textGrey,
),
),

const SizedBox(height: 24),

_label(
_hasBusiness == 'Yes'
? 'Annual Income / Turnover'
    : 'Annual Personal Income',
),

const SizedBox(height: 8),

_dropdown(
value: _income,
hint: 'Select Range',
items: _incomeRanges,
onChanged: (value) {
setState(() {
_income = value;
});
},
),

const SizedBox(height: 20),

_label('Funding Required'),

const SizedBox(height: 8),

_dropdown(
value: _fundingRequired,
hint: 'Select Amount',
items: _fundingRanges,
onChanged: (value) {
setState(() {
_fundingRequired = value;
});
},
),

const SizedBox(height: 20),

_label('What do you need funding for?'),

const SizedBox(height: 8),

_dropdown(
value: _fundingPurpose,
hint: 'Select Purpose',
items: _fundingPurposes,
onChanged: (value) {
setState(() {
_fundingPurpose = value;
});
},
),

const SizedBox(height: 20),

_label('Do you have an existing loan?'),

const SizedBox(height: 8),

_dropdown(
value: _existingLoan,
hint: 'Select',
items: _yesNo,
onChanged: (value) {
setState(() {
_existingLoan = value;
});
},
),

if (_existingLoan == 'Yes') ...[
const SizedBox(height: 20),

_label('Current Monthly EMI'),

const SizedBox(height: 8),

_textField(
controller: _emiController,
hint: '₹ Enter EMI amount',
keyboardType: TextInputType.number,
),
],
],
);
}

// ============================================================
// STEP 4 — RESULT
// ============================================================

Widget _buildResult() {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Center(
child: Container(
width: 72,
height: 72,
decoration: BoxDecoration(
color: const Color(0xFFE9F6F0),
borderRadius: BorderRadius.circular(22),
),
child: const Icon(
Icons.check_circle_outline_rounded,
size: 40,
color: Color(0xFF159B63),
),
),
),

const SizedBox(height: 22),

const Center(
child: Text(
'Your Profile is Ready!',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.w800,
color: AppColors.navy,
),
),
),

const SizedBox(height: 8),

const Center(
child: Text(
'We have understood your requirements. '
'Now we can find government schemes and support relevant to you.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 14,
height: 1.5,
color: AppColors.textGrey,
),
),
),

const SizedBox(height: 28),

_resultCard(
icon: Icons.account_balance_outlined,
title: 'Scheme Recommendations',
subtitle:
'Find schemes based on your profile and business needs.',
),

const SizedBox(height: 12),

_resultCard(
icon: Icons.verified_user_outlined,
title: 'Eligibility Matching',
subtitle:
'Check which scheme criteria match your information.',
),

const SizedBox(height: 12),

_resultCard(
icon: Icons.description_outlined,
title: 'Document Guidance',
subtitle:
'Know which documents you may need for your applications.',
),

const SizedBox(height: 12),

_resultCard(
icon: Icons.currency_rupee_rounded,
title: 'Financial Support',
subtitle:
'Explore funding options and calculate affordability.',
),
],
);
}

// ============================================================
// RESULT CARD
// ============================================================

Widget _resultCard({
required IconData icon,
required String title,
required String subtitle,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
border: Border.all(
color: AppColors.border,
),
borderRadius: BorderRadius.circular(14),
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 44,
height: 44,
decoration: BoxDecoration(
color: const Color(0xFFF0F5F9),
borderRadius: BorderRadius.circular(12),
),
child: Icon(
icon,
color: AppColors.navy,
size: 22,
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.w700,
color: AppColors.navy,
),
),

const SizedBox(height: 4),

Text(
subtitle,
style: const TextStyle(
fontSize: 12.5,
height: 1.4,
color: AppColors.textGrey,
),
),
],
),
),
],
),
);
}

// ============================================================
// LABEL
// ============================================================

Widget _label(String text) {
return Text(
text,
style: const TextStyle(
fontSize: 13,
fontWeight: FontWeight.w600,
color: AppColors.navy,
),
);
}

// ============================================================
// TEXT FIELD
// ============================================================

Widget _textField({
required TextEditingController controller,
required String hint,
TextInputType keyboardType =
TextInputType.text,
}) {
return Container(
height: 54,
decoration: BoxDecoration(
border: Border.all(
color: AppColors.border,
),
borderRadius: BorderRadius.circular(12),
),
child: TextField(
controller: controller,
keyboardType: keyboardType,
textAlignVertical:
TextAlignVertical.center,
decoration: InputDecoration(
hintText: hint,
hintStyle: const TextStyle(
color: AppColors.textGrey,
fontSize: 14,
),
border: InputBorder.none,
contentPadding:
const EdgeInsets.symmetric(
horizontal: 14,
vertical: 15,
),
),
),
);
}

// ============================================================
// DROPDOWN
// ============================================================

Widget _dropdown({
required String? value,
required String hint,
required List<String> items,
required ValueChanged<String?> onChanged,
}) {
return Container(
height: 54,
padding: const EdgeInsets.symmetric(
horizontal: 14,
),
decoration: BoxDecoration(
border: Border.all(
color: AppColors.border,
),
borderRadius: BorderRadius.circular(12),
),
child: DropdownButtonHideUnderline(
child: DropdownButton<String>(
value: value,
isExpanded: true,
hint: Text(
hint,
style: const TextStyle(
color: AppColors.textGrey,
fontSize: 14,
),
),
icon: const Icon(
Icons.keyboard_arrow_down_rounded,
color: AppColors.textGrey,
),
dropdownColor: Colors.white,
borderRadius: BorderRadius.circular(12),
items: items.map((item) {
return DropdownMenuItem<String>(
value: item,
child: Text(
item,
style: const TextStyle(
fontSize: 14,
color: AppColors.navy,
fontWeight: FontWeight.w500,
),
),
);
}).toList(),
onChanged: onChanged,
),
),
);
}
}

// ============================================================================
// PROGRESS INDICATOR
// ============================================================================

// ============================================================================
// PROGRESS INDICATOR
// ============================================================================

class _ProgressIndicator extends StatelessWidget {
final int currentStep;

const _ProgressIndicator({
required this.currentStep,
});

@override
Widget build(BuildContext context) {
const labels = [
'Basic Info',
'Business\nDetails',
'Financials',
'Result',
];

return SizedBox(
height: 94,
child: Stack(
children: [
// ------------------------------------------------------------
// CONNECTING LINE
// ------------------------------------------------------------
Positioned(
top: 24,
left: 24,
right: 24,
child: Row(
children: List.generate(
3,
(index) {
return Expanded(
child: Container(
height: 2,
color: index < currentStep
? AppColors.navy
    : const Color(0xFFE2EAF0),
),
);
},
),
),
),

// ------------------------------------------------------------
// CIRCLES + LABELS
// ------------------------------------------------------------
Row(
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
children: List.generate(
4,
(index) {
final active =
index <= currentStep;

return SizedBox(
width: 64,
child: Column(
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: active
? AppColors.navy
    : const Color(0xFFEAF1F6),
),
child: Center(
child: Text(
'${index + 1}',
style: TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w700,
color: active
? Colors.white
    : AppColors.textGrey,
),
),
),
),

const SizedBox(height: 8),

Text(
labels[index],
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 11.5,
height: 1.2,
fontWeight:
index == currentStep
? FontWeight.w700
    : FontWeight.w500,
color:
index == currentStep
? AppColors.navy
    : AppColors.textGrey,
),
),
],
),
);
},
),
),
],
),
);
}
}
