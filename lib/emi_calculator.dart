import 'package:flutter/material.dart';
import 'main.dart';

class EmiCalculatorPage extends StatefulWidget {
  final String? schemeName;

  const EmiCalculatorPage({super.key, this.schemeName});

  @override
  State<EmiCalculatorPage> createState() => _EmiCalculatorPageState();
}

class _EmiCalculatorPageState extends State<EmiCalculatorPage> {
  final _loanController = TextEditingController(text: '400000');
  final _rateController = TextEditingController(text: '8.5');
  final _incomeController = TextEditingController(text: '35000');
  final _existingEmiController = TextEditingController(text: '0');

  double _tenure = 5;
  double _emi = 0;
  double _totalInterest = 0;
  double _totalPayment = 0;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _loanController,
      _rateController,
      _incomeController,
      _existingEmiController,
    ]) {
      c.addListener(_calculate);
    }
    _calculate();
  }

  @override
  void dispose() {
    _loanController.dispose();
    _rateController.dispose();
    _incomeController.dispose();
    _existingEmiController.dispose();
    super.dispose();
  }

  void _calculate() {
    final principal = double.tryParse(_loanController.text.replaceAll(',', '')) ?? 0;
    final annualRate = double.tryParse(_rateController.text) ?? 0;
    final months = (_tenure * 12).round();
    final monthlyRate = annualRate / 12 / 100;

    double emi = 0;
    if (principal > 0 && months > 0) {
      if (monthlyRate == 0) {
        emi = principal / months;
      } else {
        final factor = _pow(1 + monthlyRate, months);
        emi = principal * monthlyRate * factor / (factor - 1);
      }
    }

    final totalPayment = emi * months;

    setState(() {
      _emi = emi;
      _totalPayment = totalPayment;
      _totalInterest = totalPayment > 0 ? totalPayment - principal : 0;
    });
  }

  double _pow(double base, int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  double get _monthlyIncome =>
      double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0;

  double get _existingEmi =>
      double.tryParse(_existingEmiController.text.replaceAll(',', '')) ?? 0;

  double get _totalEmi => _emi + _existingEmi;

  String get _affordability {
    if (_monthlyIncome <= 0 || _totalEmi <= 0) return 'Enter your income';
    final ratio = _totalEmi / _monthlyIncome;
    if (ratio <= .30) return 'Comfortable';
    if (ratio <= .45) return 'Moderate';
    return 'Higher burden';
  }

  String get _affordabilityText {
    switch (_affordability) {
      case 'Comfortable':
        return 'Your estimated total EMI is within a lower share of your monthly income.';
      case 'Moderate':
        return 'Your estimated total EMI takes a moderate share of your monthly income.';
      case 'Higher burden':
        return 'Your estimated total EMI takes a higher share of your monthly income. Consider reviewing the loan amount or tenure.';
      default:
        return 'Add your monthly income to see an affordability estimate.';
    }
  }

  String _money(double value) {
    final rounded = value.round().toString();
    final chars = rounded.split('').reversed.toList();
    final out = <String>[];
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) out.add(',');
      out.add(chars[i]);
    }
    return '₹${out.reversed.join()}';
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
          'Affordability Calculator',
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
              if (widget.schemeName != null) ...[
                Text(
                  widget.schemeName!,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              const Text(
                'Plan your loan before you apply',
                style: TextStyle(
                  color: AppColors.navyDark,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Estimate your monthly EMI and understand how it fits your income.',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              _sectionTitle('Loan Details'),
              const SizedBox(height: 10),
              _inputCard(
                label: 'Loan amount',
                hint: 'e.g. 400000',
                controller: _loanController,
                prefix: '₹',
              ),
              const SizedBox(height: 10),
              _inputCard(
                label: 'Interest rate (annual)',
                hint: 'e.g. 8.5',
                controller: _rateController,
                suffix: '%',
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                decoration: _boxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Loan tenure',
                      style: TextStyle(
                        color: AppColors.navyDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_tenure.round()} years',
                          style: const TextStyle(
                            color: AppColors.teal,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '1 – 10 years',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _tenure,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: AppColors.teal,
                      onChanged: (value) {
                        setState(() => _tenure = value);
                        _calculate();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              _sectionTitle('Your Financial Profile'),
              const SizedBox(height: 10),
              _inputCard(
                label: 'Monthly income',
                hint: 'e.g. 35000',
                controller: _incomeController,
                prefix: '₹',
              ),
              const SizedBox(height: 10),
              _inputCard(
                label: 'Existing monthly EMI',
                hint: 'Enter 0 if none',
                controller: _existingEmiController,
                prefix: '₹',
              ),

              const SizedBox(height: 22),
              _resultCard(),
              const SizedBox(height: 18),

              const Text(
                'This calculator provides an estimate only. Actual EMI, interest and approval depend on the lender and applicable scheme terms.',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
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

  Widget _inputCard({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? prefix,
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: _boxDecoration(),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefix != null ? '$prefix ' : null,
          suffixText: suffix,
          border: InputBorder.none,
          labelStyle: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    );
  }

  Widget _resultCard() {
    final income = _monthlyIncome;
    final ratio = income > 0 ? (_totalEmi / income).clamp(0.0, 1.0) : 0.0;

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
          const Text(
            'Estimated Monthly EMI',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _money(_emi),
            style: const TextStyle(
              color: AppColors.navyDark,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _resultItem('Total interest', _money(_totalInterest))),
              Expanded(child: _resultItem('Total payment', _money(_totalPayment))),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'EMI Affordability',
            style: TextStyle(
              color: AppColors.navyDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 9,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _affordability,
                style: const TextStyle(
                  color: AppColors.teal,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (income > 0)
                Text(
                  '${(_totalEmi / income * 100).toStringAsFixed(0)}% of income',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11.5,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _affordabilityText,
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

  Widget _resultItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 10.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navyDark,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
