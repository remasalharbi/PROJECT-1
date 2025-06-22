import 'package:codemaster/views/Start/login_success_view.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyOtp extends StatefulWidget {
  final String email;

  const VerifyOtp({Key? key, required this.email}) : super(key: key);

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  String otpCode = "";
  bool isLoading = false;

  Future<void> verifyOtp() async {
    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        email: widget.email,
        token: otpCode,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginSuccessView()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = otpCode.length == 6;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF), 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButton(),
              const SizedBox(height: 24),
              const Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Enter the verification code we just sent to your email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                onChanged: (value) {
                  setState(() {
                    otpCode = value;
                  });
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 55,
                  fieldWidth: 45,

                  inactiveColor: Color(0xFFC4C4C4),
                  activeColor: Color(0xFF2A2575),
                  selectedColor: Color(0xFF2A2575),

                  inactiveFillColor: Color(0xFFECECEC),
                  selectedFillColor: Colors.white,
                  activeFillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive code?"),
                  TextButton(
                    onPressed: () {
                      // resend
                    },
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        color: Color(0xFF2A2575),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: isCompleted ? verifyOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted
                              ? const Color(0xFF2A2575)
                              : Colors.grey.shade300,
                          foregroundColor: isCompleted
                              ? Colors.white
                              : Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Verify',
                          style: TextStyle(fontSize: 16),
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