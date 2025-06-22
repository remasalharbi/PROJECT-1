import 'package:codemaster/models/quiz_model.dart';
import 'package:flutter/material.dart';

class ReviewView extends StatelessWidget {
  final List<QuizQuestion> questions;
  final List<int> userAnswers;
  final List<int> correctAnswers;

  const ReviewView({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Review',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: questions.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final question = questions[index];
          final userAnswerIndex = userAnswers[index];
          final correctAnswerIndex = correctAnswers[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF1E1E8F),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                question.question,
                style: const TextStyle(
                  color: Color(0xFF1E1E8F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              if (userAnswerIndex != correctAnswerIndex)
                Row(
                  children: [
                    const Icon(Icons.close, color: Colors.red, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      question.options[userAnswerIndex],
                      style: const TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  ],
                ),

              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    question.options[correctAnswerIndex],
                    style: const TextStyle(color: Colors.green, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF1E1E8F), thickness: 0.5),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}