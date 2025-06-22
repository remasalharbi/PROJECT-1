import 'dart:convert';
import 'package:codemaster/views/courses/quiz_view.dart';
import 'package:codemaster/widgets/custom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/lesson_model.dart';

class LessonDetailView extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailView({super.key, required this.lesson});

  @override
  State<LessonDetailView> createState() => _LessonDetailViewState();
}

class _LessonDetailViewState extends State<LessonDetailView> {
  bool isCompleted = false;
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    checkIfLessonCompleted();

    final videoId = YoutubePlayer.convertUrlToId(widget.lesson.videoUrl ?? '');
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  Future<void> checkIfLessonCompleted() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client
        .from('lesson_completion')
        .select()
        .eq('user_id', userId)
        .eq('lesson_title', widget.lesson.title)
        .maybeSingle();

    if (response != null) {
      setState(() {
        isCompleted = true;
      });
    }
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navyColor = Color(0xFF2A2575);
    const backgroundColor = Color(0xFFF5F9FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: const BackButton(color: navyColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.lesson.videoUrl != null && widget.lesson.videoUrl!.isNotEmpty)
              YoutubePlayer(
                controller: _youtubeController,
                showVideoProgressIndicator: true,
                progressIndicatorColor: navyColor,
              ),
            const SizedBox(height: 24),
            Text(widget.lesson.language, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              widget.lesson.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: navyColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.lesson.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF545454))),
            const SizedBox(height: 6),
            Text(widget.lesson.content, style: const TextStyle(fontSize: 14, color: Color(0xFF545454))),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (isCompleted) return;

                  final userId = Supabase.instance.client.auth.currentUser?.id;
                  final language = widget.lesson.language;
                  final lessonTitle = widget.lesson.title;

                  if (userId == null) return;

                  setState(() {
                    isCompleted = true;
                  });

                  try {
                    await Supabase.instance.client.from('lesson_completion').insert({
                      'user_id': userId,
                      'lesson_title': lessonTitle,
                      'language': language,
                    });

                    final response = await Supabase.instance.client
                        .from('progress')
                        .select()
                        .eq('user_id', userId)
                        .eq('language', language)
                        .maybeSingle();

                    if (response == null) {
                      await Supabase.instance.client.from('progress').insert({
                        'user_id': userId,
                        'language': language,
                        'completed_lessons': 1,
                      });
                    } else {
                      final currentCompleted = response['completed_lessons'] as int;
                      await Supabase.instance.client
                          .from('progress')
                          .update({
                            'completed_lessons': currentCompleted + 1,
                          })
                          .eq('user_id', userId)
                          .eq('language', language);
                    }
                  } catch (e) {}
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? const Color.fromARGB(255, 77, 69, 186) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: isCompleted ? const Icon(Icons.check, color: Colors.white) : const SizedBox(),
                label: const Text(
                  "Lesson Completed",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Text(
              "Great job completing the lesson!\nNow let’s see what you’ve learned.",
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 107, 103, 169),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "3 questions · Estimated 2 minutes",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 6),
            const Text(
              "Your score will help track your progress.",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 40),

            Center(
              child: CustomActionButton(
                text: 'Start Quiz!',
                onPressed: () async {
                  try {
                    final jsonString = await rootBundle.loadString('assets/data/lessons.json');
                    final lessonsJson = json.decode(jsonString) as List;

                    final List<Lesson> lessons = lessonsJson.map((json) => Lesson.fromJson(json)).toList();
                    final lesson = lessons.firstWhere((item) => item.title == widget.lesson.title, orElse: () => widget.lesson);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizView(topic: lesson.title),
                      ),
                    );
                  } catch (e) {}
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
