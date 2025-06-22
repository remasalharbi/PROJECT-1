import 'package:flutter/material.dart';
import 'payment_view.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  int selectedPlan = 6;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFFF5F9FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.arrow_back, color: Color(0xFF2A2575)),
              ),
            ),
            const SizedBox(height: 0),
            const Text(
              'Start Learn!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2575),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Get All The New Exciting Features',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2A2575),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPlanBox(1, '15'),
                const SizedBox(width: 16),
                buildPlanBox(6, '35'),
                const SizedBox(width: 16),
                buildPlanBox(12, '62'),
              ],
            ),
            const SizedBox(height: 12),
            buildIconOnlyButton('assets/images/apple_pay_icon.png'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentView(selectedPlan),
                  ),
                );
              },
              child: buildPayButton('Credit Card', 'assets/images/credit card.png'),
            ),
            const SizedBox(height: 12),
            buildIconOnlyButton('assets/images/google-pay.png'),
            
          ],
        ),
      ),
    );
  }

  Widget buildPlanBox(int months, String price) {
    final isSelected = selectedPlan == months;
    final primaryColor = const Color(0xFF2A2575);

    String getPlanLabel() {
      switch (months) {
        case 1:
          return 'BASIC';
        case 6:
          return 'MOST POPULAR';
        case 12:
          return 'SPECIAL';
        default:
          return '';
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = months;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 110,
        height: isSelected ? 170 : 150,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withOpacity(isSelected ? 1 : 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isSelected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  getPlanLabel(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              '$months\nMonthly',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.black : primaryColor.withOpacity(0.4),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '﷼$price',
              style: TextStyle(
                color: isSelected ? Colors.black : primaryColor.withOpacity(0.4),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIconOnlyButton(String iconPath) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2575), 
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          child: Image.asset(
            iconPath,
            width: 64,
            height: 64,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget buildPayButton(String label, String iconPath) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2575),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 48,
            height: 48,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
