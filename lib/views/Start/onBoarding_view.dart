import 'package:codemaster/widgets/custom_action_button.dart'; 
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'create_acc_view.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  final introKey = GlobalKey<IntroductionScreenState>();
  final Color backgroundColor = const Color(0xFFDBE8EC);
  final Color primaryColor = const Color(0xFF2A2575);

  int currentPageIndex = 0;

  void _onIntroEnd(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const CreateAccView()));
  }

  Widget _buildImage(String assetName, [double width = 400]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 16.0, color: Colors.black87);
    const titleStyle = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    final pageDecoration = PageDecoration(
      titleTextStyle: titleStyle,
      bodyTextStyle: bodyStyle,
      bodyAlignment: Alignment.center,
      imageAlignment: Alignment.topCenter,
      contentMargin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      imagePadding: const EdgeInsets.only(top: 50),
      pageColor: backgroundColor,
    );

    return Scaffold(
      body: Stack(
        children: [
          IntroductionScreen(
            key: introKey,
            globalBackgroundColor: backgroundColor,
            showSkipButton: false,
            showNextButton: false,
            showDoneButton: false,
            onChange: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            pages: [
              PageViewModel(
                title: "Online Learning",
                body: "We Provide Online Classes and Pre-recorded Lectures.",
                image: _buildImage('onboarding1.png'),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: "Learn from Anytime",
                body: "Book or Save the Lectures for Future.",
                image: _buildImage('onboarding2.png'),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: "Get Online Certificate",
                body: "Analyse your scores and track your results.",
                image: _buildImage('onboarding3.png'),
                decoration: pageDecoration,
              ),
            ],
            dotsDecorator: DotsDecorator(
              size: const Size(8.0, 8.0),
              color: const Color(0xFFBDBDBD),
              activeColor: primaryColor,
              activeSize: const Size(20.0, 8.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),

          if (currentPageIndex != 2)
            Align(
              alignment: Alignment.topRight,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  child: TextButton(
                    onPressed: () => _onIntroEnd(context),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (currentPageIndex != 2)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30.0, right: 16.0),
                child: ElevatedButton(
                  onPressed: () => introKey.currentState?.next(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ),

          if (currentPageIndex == 2)
            Align(
              alignment: Alignment.bottomCenter,
               child:Padding(
                padding: const EdgeInsets.only(bottom: 90.0),
                child:  CustomActionButton(
                  text: 'Get Started',
                  onPressed: () => _onIntroEnd(context)
                ), 
              ),
            ),
          ],
        ),
      );
     }
    }
