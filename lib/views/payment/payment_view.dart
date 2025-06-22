import 'package:codemaster/views/Start/fill_profile_view.dart';
import 'package:flutter/material.dart';

import 'package:moyasar/moyasar.dart';

class PaymentView extends StatefulWidget {
  final int months;

  const PaymentView(this.months, {super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final Map<int, int> prices = {
    1: 15,
    6: 35,
    12: 62,
  };

  PaymentConfig buildPaymentConfig() {
    return PaymentConfig(
      publishableApiKey: 'pk_test_nboCfq4SUVJg9HiaEm8jKfSd94XCVsmX6BWG6YwF',
      amount: 100 * (prices[widget.months] ?? 15),
      description: 'اشتراك لمدة ${widget.months} شهر',
      metadata: {'plan': '${widget.months} months'},
    );
  }

  void onPaymentResult(result) {
    if (result is PaymentResponse) {
      if (result.status == PaymentStatus.paid) {
        print('تم الدفع بنجاح');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => FillProfileView(userData: {})),
        );
      } else {
        print('فشل الدفع');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل الدفع، حاول مرة أخرى.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2A2575)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100.0),
          child: CreditCard(
            config: buildPaymentConfig(),
            onPaymentResult: onPaymentResult,
          ),
        ),
      ),
    );
  }
}
