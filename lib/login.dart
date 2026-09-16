import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';
import 'eligibility.dart';

class LoginPage extends StatefulWidget {
const LoginPage({super.key});

@override
State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
bool _obscurePassword = true;

final TextEditingController _mobileController =
TextEditingController();

final TextEditingController _passwordController =
TextEditingController();

String _selectedCountryCode = '+91';
String _selectedCountryName = 'India';

final List<Map<String, String>> _countries = [
{'name': 'India', 'code': '+91'},
{'name': 'United States', 'code': '+1'},
{'name': 'Canada', 'code': '+1'},
{'name': 'United Kingdom', 'code': '+44'},
{'name': 'Australia', 'code': '+61'},
{'name': 'New Zealand', 'code': '+64'},
{'name': 'United Arab Emirates', 'code': '+971'},
{'name': 'Saudi Arabia', 'code': '+966'},
{'name': 'Qatar', 'code': '+974'},
{'name': 'Singapore', 'code': '+65'},
{'name': 'Malaysia', 'code': '+60'},
{'name': 'Germany', 'code': '+49'},
{'name': 'France', 'code': '+33'},
{'name': 'Italy', 'code': '+39'},
{'name': 'Spain', 'code': '+34'},
{'name': 'Japan', 'code': '+81'},
{'name': 'South Korea', 'code': '+82'},
{'name': 'China', 'code': '+86'},
{'name': 'South Africa', 'code': '+27'},
{'name': 'Brazil', 'code': '+55'},
{'name': 'Russia', 'code': '+7'},
{'name': 'Nepal', 'code': '+977'},
{'name': 'Bangladesh', 'code': '+880'},
{'name': 'Sri Lanka', 'code': '+94'},
{'name': 'Pakistan', 'code': '+92'},
];

@override
void dispose() {
_mobileController.dispose();
_passwordController.dispose();
super.dispose();
}

// ============================================================
// COUNTRY PICKER
// ============================================================

void _showCountryPicker() {
showModalBottomSheet(
context: context,
backgroundColor: Colors.white,
isScrollControlled: true,
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(
top: Radius.circular(24),
),
),
builder: (context) {
return SafeArea(
child: SizedBox(
height: MediaQuery.of(context).size.height * 0.72,
child: Column(
children: [
const SizedBox(height: 12),

Container(
width: 42,
height: 4,
decoration: BoxDecoration(
color: AppColors.border,
borderRadius: BorderRadius.circular(10),
),
),

const SizedBox(height: 18),

const Text(
'Select Country',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.w700,
color: AppColors.navy,
),
),

const SizedBox(height: 12),

Expanded(
child: ListView.separated(
padding: const EdgeInsets.fromLTRB(
20,
8,
20,
20,
),
itemCount: _countries.length,
separatorBuilder: (_, __) {
return const Divider(
height: 1,
color: AppColors.border,
);
},
itemBuilder: (context, index) {
final country = _countries[index];

final isSelected =
country['name'] == _selectedCountryName &&
country['code'] == _selectedCountryCode;

return ListTile(
contentPadding:
const EdgeInsets.symmetric(
horizontal: 4,
vertical: 2,
),
title: Text(
country['name']!,
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.w600,
color: AppColors.navy,
),
),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
country['code']!,
style: const TextStyle(
fontSize: 14,
color: AppColors.textGrey,
fontWeight: FontWeight.w600,
),
),
const SizedBox(width: 10),
if (isSelected)
const Icon(
Icons.check_circle,
color: Color(0xFF159B63),
size: 20,
),
],
),
onTap: () {
setState(() {
_selectedCountryName = country['name']!;
_selectedCountryCode = country['code']!;
});

Navigator.pop(context);
},
);
},
),
),
],
),
),
);
},
);
}

// ============================================================
// LOGIN
// ============================================================

void _login() {
final mobile = _mobileController.text.trim();
final password = _passwordController.text.trim();

if (mobile.isEmpty) {
_showMessage('Please enter your mobile number.');
return;
}

if (password.isEmpty) {
_showMessage('Please enter your password.');
return;
}

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) => const EligibilityPage(),
),
);
}

// ============================================================
// FORGOT PASSWORD
// ============================================================

void _forgotPassword() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const ForgotPasswordPage(),
),
);
}

// ============================================================
// DIGILOCKER
// ============================================================

Future<void> _openOfficialSite({
required String url,
required String serviceName,
}) async {
final Uri uri = Uri.parse(url);

try {
final bool opened = await launchUrl(
uri,
mode: LaunchMode.externalApplication,
);

if (!opened && mounted) {
_showMessage('Could not open $serviceName. Please try again.');
}
} catch (e) {
if (mounted) {
_showMessage('Could not open $serviceName. Please check your internet connection.');
}
}
}

Future<void> _digilocker() async {
await _openOfficialSite(
url: 'https://www.digilocker.gov.in/',
serviceName: 'DigiLocker',
);
}

Future<void> _udyam() async {
await _openOfficialSite(
url: 'https://udyamregistration.gov.in/',
serviceName: 'Udyam Registration',
);
}

// ============================================================
// CREATE ACCOUNT
// ============================================================

void _createAccount() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const CreateAccountPage(),
),
);
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
// LOGIN UI
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(
24,
18,
24,
28,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ============================================================
// ARTHSAATHI WORDMARK
// ============================================================

Center(
child: Text(
'अर्थSaathi',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 29,
fontWeight: FontWeight.w800,
color: AppColors.navy,
letterSpacing: -0.6,
),
),
),

const SizedBox(height: 48),

// ============================================================
// HEADING
// ============================================================

const Text(
'Welcome Back',
style: TextStyle(
fontSize: 27,
fontWeight: FontWeight.w800,
color: AppColors.navy,
),
),

const SizedBox(height: 6),

Text(
'Login to continue your journey',
style: TextStyle(
fontSize: 14,
color: AppColors.textGrey,
),
),

const SizedBox(height: 30),

// ============================================================
// MOBILE LABEL
// ============================================================

const _FieldLabel(
'Mobile Number',
),

const SizedBox(height: 8),

// ============================================================
// MOBILE FIELD
// ============================================================

Container(
height: 54,
decoration: BoxDecoration(
border: Border.all(
color: AppColors.border,
),
borderRadius:
BorderRadius.circular(12),
),
child: Row(
children: [
InkWell(
onTap: _showCountryPicker,
borderRadius:
BorderRadius.circular(12),
child: Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 14,
),
child: Row(
children: [
Text(
_selectedCountryCode,
style: const TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w600,
color:
AppColors.navy,
),
),
const SizedBox(width: 3),
const Icon(
Icons
    .keyboard_arrow_down,
size: 18,
color:
AppColors.textGrey,
),
],
),
),
),

Container(
width: 1,
height: 25,
color: AppColors.border,
),

Expanded(
child: TextField(
controller:
_mobileController,
keyboardType:
TextInputType.phone,
decoration:
const InputDecoration(
hintText:
'Mobile Number',
hintStyle: TextStyle(
color:
AppColors.textGrey,
),
border:
InputBorder.none,
contentPadding:
EdgeInsets.symmetric(
horizontal: 14,
vertical: 15,
),
),
),
),
],
),
),

const SizedBox(height: 20),

// ============================================================
// PASSWORD LABEL
// ============================================================

const _FieldLabel(
'Password',
),

const SizedBox(height: 8),

// ============================================================
// PASSWORD FIELD
// ============================================================

Container(
height: 54,
decoration: BoxDecoration(
border: Border.all(
color: AppColors.border,
),
borderRadius:
BorderRadius.circular(12),
),
child: TextField(
controller:
_passwordController,
obscureText:
_obscurePassword,
textAlignVertical:
TextAlignVertical.center,
decoration: InputDecoration(
hintText:
'Enter Password',
hintStyle:
const TextStyle(
color:
AppColors.textGrey,
),
border:
InputBorder.none,
contentPadding:
const EdgeInsets.symmetric(
horizontal: 14,
vertical: 15,
),
suffixIcon:
IconButton(
icon: Icon(
_obscurePassword
? Icons
    .visibility_off_outlined
    : Icons
    .visibility_outlined,
color:
AppColors.textGrey,
size: 20,
),
onPressed: () {
setState(() {
_obscurePassword =
!_obscurePassword;
});
},
),
),
),
),

const SizedBox(height: 8),

// ============================================================
// FORGOT PASSWORD
// ============================================================

Align(
alignment:
Alignment.centerRight,
child: TextButton(
onPressed:
_forgotPassword,
style:
TextButton.styleFrom(
padding: EdgeInsets.zero,
minimumSize:
const Size(0, 0),
tapTargetSize:
MaterialTapTargetSize
    .shrinkWrap,
),
child: const Text(
'Forgot Password?',
style: TextStyle(
fontSize: 13,
fontWeight:
FontWeight.w600,
color:
AppColors.navy,
),
),
),
),

const SizedBox(height: 20),

// ============================================================
// LOGIN BUTTON
// ============================================================

SizedBox(
width: double.infinity,
height: 54,
child: ElevatedButton(
onPressed: _login,
style:
ElevatedButton.styleFrom(
backgroundColor:
AppColors.navy,
foregroundColor:
Colors.white,
elevation: 0,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
14,
),
),
),
child: const Text(
'Login',
style: TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w700,
),
),
),
),

const SizedBox(height: 20),

// ============================================================
// OR
// ============================================================

Row(
children: [
const Expanded(
child: Divider(
color:
AppColors.border,
),
),
Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 12,
),
child: Text(
'or',
style: TextStyle(
color:
AppColors.textGrey,
fontSize: 13,
),
),
),
const Expanded(
child: Divider(
color:
AppColors.border,
),
),
],
),

const SizedBox(height: 20),

// ============================================================
// DIGILOCKER
// ============================================================

_OutlinedImageActionButton(
imagePath:
'assets/images/digilocker.png',
label:
'Continue with DigiLocker',
onTap: _digilocker,
),

const SizedBox(height: 12),

// ============================================================
// UDYAM
// ============================================================

_OutlinedImageActionButton(
imagePath:
'assets/images/udyam.png',
label:
'Continue with Udyam',
onTap: _udyam,
),

const SizedBox(height: 30),

// ============================================================
// CREATE ACCOUNT
// ============================================================

Center(
child: GestureDetector(
onTap: _createAccount,
child: RichText(
text:
const TextSpan(
style: TextStyle(
fontSize: 13.5,
color:
AppColors.textGrey,
),
children: [
TextSpan(
text:
'New to अर्थSaathi?  ',
),
TextSpan(
text:
'Create Account',
style: TextStyle(
color:
AppColors.navy,
fontWeight:
FontWeight.w700,
),
),
],
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
}

// ============================================================================
// FIELD LABEL
// ============================================================================

class _FieldLabel
extends StatelessWidget {
final String text;

const _FieldLabel(
this.text,
);

@override
Widget build(
BuildContext context,
) {
return Text(
text,
style: const TextStyle(
fontSize: 13,
fontWeight:
FontWeight.w600,
color: AppColors.navy,
),
);
}
}

// ============================================================================
// IMAGE ACTION BUTTON
// ============================================================================

class _OutlinedImageActionButton
extends StatelessWidget {
final String imagePath;
final String label;
final VoidCallback onTap;

const _OutlinedImageActionButton({
required this.imagePath,
required this.label,
required this.onTap,
});

@override
Widget build(
BuildContext context,
) {
return SizedBox(
width: double.infinity,
height: 52,
child: OutlinedButton(
onPressed: onTap,
style:
OutlinedButton.styleFrom(
foregroundColor:
AppColors.navy,
side: const BorderSide(
color: AppColors.border,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(14),
),
padding:
const EdgeInsets.symmetric(
horizontal: 14,
),
),
child: Row(
children: [
SizedBox(
width: 30,
height: 30,
child: Image.asset(
imagePath,
fit: BoxFit.contain,
errorBuilder:
(context, error, stackTrace) {
return const Icon(
Icons.image_outlined,
size: 20,
color:
AppColors.textGrey,
);
},
),
),

const SizedBox(width: 12),

Expanded(
child: Text(
label,
style:
const TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w600,
color:
AppColors.navy,
),
),
),
],
),
),
);
}
}


// ============================================================================
// FORGOT PASSWORD PAGE
// ============================================================================

class ForgotPasswordPage
extends StatefulWidget {
const ForgotPasswordPage({
super.key,
});

@override
State<ForgotPasswordPage> createState() =>
_ForgotPasswordPageState();
}

class _ForgotPasswordPageState
extends State<ForgotPasswordPage> {
final TextEditingController
_mobileController =
TextEditingController();

String _selectedCountryCode = '+91';
String _selectedCountryName = 'India';

final List<Map<String, String>> _countries = [
{'name': 'India', 'code': '+91'},
{'name': 'United States', 'code': '+1'},
{'name': 'Canada', 'code': '+1'},
{'name': 'United Kingdom', 'code': '+44'},
{'name': 'Australia', 'code': '+61'},
{'name': 'New Zealand', 'code': '+64'},
{'name': 'United Arab Emirates', 'code': '+971'},
{'name': 'Saudi Arabia', 'code': '+966'},
{'name': 'Qatar', 'code': '+974'},
{'name': 'Singapore', 'code': '+65'},
{'name': 'Malaysia', 'code': '+60'},
{'name': 'Germany', 'code': '+49'},
{'name': 'France', 'code': '+33'},
{'name': 'Japan', 'code': '+81'},
{'name': 'South Korea', 'code': '+82'},
{'name': 'China', 'code': '+86'},
{'name': 'Nepal', 'code': '+977'},
{'name': 'Bangladesh', 'code': '+880'},
{'name': 'Sri Lanka', 'code': '+94'},
];

@override
void dispose() {
_mobileController.dispose();
super.dispose();
}

// ============================================================
// COUNTRY PICKER
// ============================================================

void _showCountryPicker() {
showModalBottomSheet(
context: context,
backgroundColor: Colors.white,
isScrollControlled: true,
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(
top: Radius.circular(24),
),
),
builder: (context) {
return SafeArea(
child: SizedBox(
height:
MediaQuery.of(context)
    .size
    .height *
0.72,
child: Column(
children: [
const SizedBox(height: 12),

Container(
width: 42,
height: 4,
decoration:
BoxDecoration(
color:
AppColors.border,
borderRadius:
BorderRadius.circular(
10,
),
),
),

const SizedBox(height: 18),

const Text(
'Select Country',
style: TextStyle(
fontSize: 20,
fontWeight:
FontWeight.w700,
color:
AppColors.navy,
),
),

const SizedBox(height: 12),

Expanded(
child:
ListView.separated(
padding:
const EdgeInsets.fromLTRB(
20,
8,
20,
20,
),
itemCount:
_countries.length,
separatorBuilder:
(_, __) {
return const Divider(
height: 1,
color:
AppColors.border,
);
},
itemBuilder:
(context, index) {
final country =
_countries[index];

final isSelected =
country['code'] == _selectedCountryCode &&
country['name'] == _selectedCountryName;

return ListTile(
title: Text(
country['name']!,
style:
const TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w600,
color:
AppColors.navy,
),
),
trailing:
Row(
mainAxisSize:
MainAxisSize.min,
children: [
Text(
country[
'code']!,
style:
const TextStyle(
fontSize: 14,
color: AppColors
    .textGrey,
fontWeight:
FontWeight.w600,
),
),
const SizedBox(
width: 10,
),
if (isSelected)
const Icon(
Icons
    .check_circle,
color: Color(
0xFF159B63,
),
size: 20,
),
],
),
onTap: () {
setState(() {
_selectedCountryName = country['name']!;
_selectedCountryCode = country['code']!;
});

Navigator.pop(
context,
);
},
);
},
),
),
],
),
),
);
},
);
}

// ============================================================
// SEND OTP
// ============================================================

void _sendOtp() {
final mobile =
_mobileController.text.trim();

if (mobile.isEmpty) {
_showMessage(
'Please enter your mobile number.',
);
return;
}

if (mobile.length < 6) {
_showMessage(
'Please enter a valid mobile number.',
);
return;
}

showDialog(
context: context,
builder: (context) {
return AlertDialog(
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(20),
),
title: const Text(
'OTP Sent',
style: TextStyle(
fontWeight:
FontWeight.w700,
color:
AppColors.navy,
),
),
content: Text(
'A password reset OTP has been sent to '
'$_selectedCountryCode ${_mobileController.text.trim()}.',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(
context,
);
},
child: const Text(
'Continue',
style: TextStyle(
color:
AppColors.navy,
fontWeight:
FontWeight.w700,
),
),
),
],
);
},
);
}

void _showMessage(
String message) {
ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content:
Text(message),
behavior:
SnackBarBehavior.floating,
margin:
const EdgeInsets.all(16),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(12),
),
),
);
}

// ============================================================
// UI
// ============================================================

@override
Widget build(
BuildContext context) {
return Scaffold(
backgroundColor:
Colors.white,
body: SafeArea(
child:
SingleChildScrollView(
padding:
const EdgeInsets.fromLTRB(
24,
18,
24,
28,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// BACK BUTTON
IconButton(
onPressed: () {
Navigator.pop(
context,
);
},
icon: const Icon(
Icons
    .arrow_back_ios_new_rounded,
size: 20,
color:
AppColors.navy,
),
padding:
EdgeInsets.zero,
constraints:
const BoxConstraints(),
),

const SizedBox(height: 38),

// WORDMARK
const Center(
child: Text(
'अर्थSaathi',
textAlign:
TextAlign.center,
style: TextStyle(
fontSize: 29,
fontWeight:
FontWeight.w800,
color:
AppColors.navy,
letterSpacing:
-0.6,
),
),
),

const SizedBox(height: 52),

// ICON
Center(
child: Container(
width: 72,
height: 72,
decoration:
BoxDecoration(
color:
const Color(
0xFFEAF3FB,
),
borderRadius:
BorderRadius.circular(
22,
),
),
child:
const Icon(
Icons
    .lock_reset_rounded,
size: 36,
color:
AppColors.navy,
),
),
),

const SizedBox(height: 28),

// HEADING
const Center(
child: Text(
'Forgot Password?',
textAlign:
TextAlign.center,
style: TextStyle(
fontSize: 27,
fontWeight:
FontWeight.w800,
color:
AppColors.navy,
),
),
),

const SizedBox(height: 8),

// DESCRIPTION
Center(
child: Text(
'Enter your registered mobile number and '
'we’ll help you reset your password.',
textAlign:
TextAlign.center,
style: TextStyle(
fontSize: 14,
height: 1.5,
color:
AppColors.textGrey,
),
),
),

const SizedBox(height: 38),

// LABEL
const _FieldLabel(
'Mobile Number',
),

const SizedBox(height: 8),

// MOBILE FIELD
Container(
height: 54,
decoration:
BoxDecoration(
border:
Border.all(
color:
AppColors.border,
),
borderRadius:
BorderRadius.circular(
12,
),
),
child: Row(
children: [
InkWell(
onTap:
_showCountryPicker,
borderRadius:
BorderRadius.circular(
12,
),
child: Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 14,
),
child: Row(
children: [
Text(
_selectedCountryCode,
style:
const TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w600,
color:
AppColors.navy,
),
),
const SizedBox(
width: 3,
),
const Icon(
Icons
    .keyboard_arrow_down,
size: 18,
color:
AppColors.textGrey,
),
],
),
),
),

Container(
width: 1,
height: 25,
color:
AppColors.border,
),

Expanded(
child:
TextField(
controller:
_mobileController,
keyboardType:
TextInputType.phone,
decoration:
const InputDecoration(
hintText:
'Enter Mobile Number',
hintStyle:
TextStyle(
color:
AppColors.textGrey,
),
border:
InputBorder.none,
contentPadding:
EdgeInsets.symmetric(
horizontal:
14,
vertical:
15,
),
),
),
),
],
),
),

const SizedBox(height: 26),

// SEND OTP
SizedBox(
width:
double.infinity,
height: 54,
child:
ElevatedButton(
onPressed:
_sendOtp,
style:
ElevatedButton.styleFrom(
backgroundColor:
AppColors.navy,
foregroundColor:
Colors.white,
elevation: 0,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
14,
),
),
),
child:
const Text(
'Send OTP',
style:
TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w700,
),
),
),
),

const SizedBox(height: 22),

// BACK TO LOGIN
Center(
child:
TextButton(
onPressed: () {
Navigator.pop(
context,
);
},
child:
const Text(
'Back to Login',
style:
TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w700,
color:
AppColors.navy,
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
}
// ============================================================================
// CREATE ACCOUNT PAGE
// ============================================================================

class CreateAccountPage extends StatefulWidget {
const CreateAccountPage({super.key});

@override
State<CreateAccountPage> createState() =>
_CreateAccountPageState();
}

class _CreateAccountPageState
extends State<CreateAccountPage> {
bool _obscurePassword = true;
bool _obscureConfirmPassword = true;
bool _agreeTerms = false;

final TextEditingController _nameController =
TextEditingController();

final TextEditingController _mobileController =
TextEditingController();

final TextEditingController _emailController =
TextEditingController();

final TextEditingController _passwordController =
TextEditingController();

final TextEditingController _confirmPasswordController =
TextEditingController();

@override
void dispose() {
_nameController.dispose();
_mobileController.dispose();
_emailController.dispose();
_passwordController.dispose();
_confirmPasswordController.dispose();
super.dispose();
}

void _createAccount() {
final name = _nameController.text.trim();
final mobile = _mobileController.text.trim();
final email = _emailController.text.trim();
final password = _passwordController.text;
final confirmPassword =
_confirmPasswordController.text;

if (name.isEmpty) {
_showMessage('Please enter your name.');
return;
}

if (mobile.isEmpty) {
_showMessage(
'Please enter your mobile number.',
);
return;
}

if (email.isEmpty) {
_showMessage(
'Please enter your email address.',
);
return;
}

if (password.isEmpty) {
_showMessage(
'Please create a password.',
);
return;
}

if (password != confirmPassword) {
_showMessage(
'Passwords do not match.',
);
return;
}

if (!_agreeTerms) {
_showMessage(
'Please accept the terms and conditions.',
);
return;
}

// ------------------------------------------------------------
// Demo account creation
// Connect backend/API here later.
// ------------------------------------------------------------

showDialog(
context: context,
builder: (context) {
return AlertDialog(
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(20),
),
title: const Text(
'Account Created',
style: TextStyle(
fontWeight: FontWeight.w800,
color: AppColors.navy,
),
),
content: const Text(
'Your ArthSaathi account has been created successfully.',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context);

Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (_) =>
const EligibilityPage(),
),
(route) => false,
);
},
child: const Text(
'Continue',
style: TextStyle(
color: AppColors.navy,
fontWeight: FontWeight.w700,
),
),
),
],
);
},
);
}

void _showMessage(String message) {
ScaffoldMessenger.of(context).hideCurrentSnackBar();

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior:
SnackBarBehavior.floating,
margin:
const EdgeInsets.all(16),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(12),
),
),
);
}

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

Widget _textField({
required TextEditingController controller,
required String hint,
TextInputType keyboardType =
TextInputType.text,
bool obscureText = false,
Widget? suffixIcon,
}) {
return Container(
height: 54,
decoration: BoxDecoration(
border: Border.all(
color: AppColors.border,
),
borderRadius:
BorderRadius.circular(12),
),
child: TextField(
controller: controller,
obscureText: obscureText,
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
suffixIcon: suffixIcon,
),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
body: SafeArea(
child: SingleChildScrollView(
padding:
const EdgeInsets.fromLTRB(
24,
18,
24,
32,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// BACK
IconButton(
onPressed: () {
Navigator.pop(context);
},
padding: EdgeInsets.zero,
constraints:
const BoxConstraints(),
icon: const Icon(
Icons.arrow_back_ios_new_rounded,
size: 20,
color: AppColors.navy,
),
),

const SizedBox(height: 28),

// WORDMARK
const Center(
child: Text(
'अर्थSaathi',
style: TextStyle(
fontSize: 29,
fontWeight:
FontWeight.w800,
color: AppColors.navy,
letterSpacing: -0.6,
),
),
),

const SizedBox(height: 40),

const Text(
'Create Account',
style: TextStyle(
fontSize: 27,
fontWeight:
FontWeight.w800,
color: AppColors.navy,
),
),

const SizedBox(height: 6),

const Text(
'Create your ArthSaathi account to begin your journey.',
style: TextStyle(
fontSize: 14,
color: AppColors.textGrey,
),
),

const SizedBox(height: 30),

// NAME
_label('Full Name'),

const SizedBox(height: 8),

_textField(
controller: _nameController,
hint: 'Enter your full name',
),

const SizedBox(height: 18),

// MOBILE
_label('Mobile Number'),

const SizedBox(height: 8),

_textField(
controller:
_mobileController,
hint:
'Enter mobile number',
keyboardType:
TextInputType.phone,
),

const SizedBox(height: 18),

// EMAIL
_label('Email Address'),

const SizedBox(height: 8),

_textField(
controller:
_emailController,
hint:
'Enter email address',
keyboardType:
TextInputType.emailAddress,
),

const SizedBox(height: 18),

// PASSWORD
_label('Password'),

const SizedBox(height: 8),

_textField(
controller:
_passwordController,
hint:
'Create a password',
obscureText:
_obscurePassword,
suffixIcon:
IconButton(
onPressed: () {
setState(() {
_obscurePassword =
!_obscurePassword;
});
},
icon: Icon(
_obscurePassword
? Icons
    .visibility_off_outlined
    : Icons
    .visibility_outlined,
color:
AppColors.textGrey,
size: 20,
),
),
),

const SizedBox(height: 18),

// CONFIRM PASSWORD
_label('Confirm Password'),

const SizedBox(height: 8),

_textField(
controller:
_confirmPasswordController,
hint:
'Re-enter your password',
obscureText:
_obscureConfirmPassword,
suffixIcon:
IconButton(
onPressed: () {
setState(() {
_obscureConfirmPassword =
!_obscureConfirmPassword;
});
},
icon: Icon(
_obscureConfirmPassword
? Icons
    .visibility_off_outlined
    : Icons
    .visibility_outlined,
color:
AppColors.textGrey,
size: 20,
),
),
),

const SizedBox(height: 18),

// TERMS
Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
SizedBox(
width: 24,
height: 24,
child: Checkbox(
value: _agreeTerms,
activeColor:
AppColors.navy,
onChanged: (value) {
setState(() {
_agreeTerms =
value ?? false;
});
},
),
),

const SizedBox(width: 8),

const Expanded(
child: Text(
'I agree to the Terms of Service and Privacy Policy.',
style: TextStyle(
fontSize: 12.5,
height: 1.4,
color:
AppColors.textGrey,
),
),
),
],
),

const SizedBox(height: 24),

// CREATE ACCOUNT BUTTON
SizedBox(
width: double.infinity,
height: 54,
child: ElevatedButton(
onPressed:
_createAccount,
style:
ElevatedButton.styleFrom(
backgroundColor:
AppColors.navy,
foregroundColor:
Colors.white,
elevation: 0,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
14,
),
),
),
child: const Text(
'Create Account',
style: TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w700,
),
),
),
),

const SizedBox(height: 22),

// LOGIN
Center(
child: GestureDetector(
onTap: () {
Navigator.pop(context);
},
child: const Text.rich(
TextSpan(
children: [
TextSpan(
text:
'Already have an account? ',
style: TextStyle(
color:
AppColors.textGrey,
fontSize: 13.5,
),
),
TextSpan(
text: 'Login',
style: TextStyle(
color:
AppColors.navy,
fontSize: 13.5,
fontWeight:
FontWeight.w700,
),
),
],
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
}
