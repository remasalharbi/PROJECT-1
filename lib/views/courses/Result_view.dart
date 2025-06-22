import 'package:codemaster/models/quiz_model.dart';
import 'package:codemaster/views/courses/quiz_view.dart';
import 'package:codemaster/views/courses/review_view.dart';
import 'package:flutter/material.dart';

class ResultView extends StatelessWidget {
  final int score;
  final int total;
  final String topic;
  final List<QuizQuestion> _questions;
  final List<int> _userSelectedAnswers;
 
  const ResultView({
    super.key,
    required this.score,
    required this.total,
    required this.topic,
    required List<QuizQuestion> questions,
    required List<int> userSelectedAnswers,
  })  : _questions = questions,
        _userSelectedAnswers = userSelectedAnswers;

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF2A2575);
    final Color bgColor = const Color(0xFFF5F9FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/result_image.png', height: 200),
            const SizedBox(height: 20),
            Text("Well Done!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: mainColor)),
            const SizedBox(height: 8),
            Text("QUESTIONS YOU GOT RIGHT", style: TextStyle(color: mainColor, fontSize: 12)),
            const SizedBox(height: 8),
            Text("$score of $total", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: mainColor)),
            const SizedBox(height: 20),
            _buildButton(context, "Replay", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => QuizView(topic: topic)),
              );
            }),
            const SizedBox(height: 10),
            _buildButton(context, "Review", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewView(
                    questions: _questions,
                    userAnswers: _userSelectedAnswers,
                    correctAnswers: _questions.map((q) => q.correctAnswerIndex).toList(),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            _buildButton(context, "Done", () => Navigator.pop(context), filled: true),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, VoidCallback onPressed, {bool filled = false}) {
    final Color mainColor = const Color(0xFF2A2575);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? mainColor : Colors.transparent,
          border: Border.all(color: mainColor),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : mainColor,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}