import 'dart:convert';
import 'package:codemaster/models/quiz_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:codemaster/views/courses/result_view.dart';

class QuizView extends StatefulWidget {
  final String topic;
  const QuizView({super.key, required this.topic});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  List<QuizQuestion> _questions = [];
  final List<int> _userSelectedAnswers = [];
  int _currentQuestion = 0;
  int _selectedIndex = -1;
  int _score = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

 Future<void> _loadQuizData() async {
  try {
    final String response = await rootBundle.loadString('assets/data/quizzes.json');
    final Map<String, dynamic> data = json.decode(response);

    if (data.containsKey(widget.topic)) {
      final List<dynamic> questionsJson = data[widget.topic];

      setState(() {
        _questions = questionsJson.map((q) => QuizQuestion.fromJson(q)).toList();
        _isLoading = false;
      });
    } else {
    }
  } catch (e) {}
}


  void _nextQuestion() {
    if (_selectedIndex == _questions[_currentQuestion].correctAnswerIndex) {
      _score++;
    }

    _userSelectedAnswers.add(_selectedIndex);

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedIndex = -1;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultView(
            score: _score,
            total: _questions.length,
            topic: widget.topic,
            questions: _questions,
            userSelectedAnswers: _userSelectedAnswers,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF2A2575);
    const Color bgColor = Color(0xFFF5F9FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: const BackButton(color: mainColor),
        centerTitle: true,
        title: Text(
          "${_currentQuestion + 1}/${_questions.length}",
          style: const TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      _questions[_currentQuestion].question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(_questions[_currentQuestion].options.length, (index) {
                    final isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? mainColor.withOpacity(0.15) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? mainColor : Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _questions[_currentQuestion].options[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? mainColor : Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? mainColor : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  GestureDetector(
                    onTap: _selectedIndex == -1 ? null : _nextQuestion,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(
                        color: _selectedIndex == -1 ? Colors.grey.shade400 : mainColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
