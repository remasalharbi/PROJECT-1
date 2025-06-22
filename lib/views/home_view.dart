import 'dart:convert';
import 'package:codemaster/models/course_model.dart';
import 'package:codemaster/views/CertificateView.dart';
import 'package:codemaster/views/Notifications_view.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:codemaster/views/courses/course_view.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:codemaster/chatBot/chat_screen.dart'; 

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String userName = "";
  String selectedTab = 'Ongoing';
  String searchQuery = '';
  List<CourseModel> allLessons = [];

  final List<Map<String, dynamic>> allCourses = [
    {
      "title": "Python",
      "icon": "assets/images/python.png",
      "progress": 0.0,
      "color": Colors.teal,
    },
    {
      "title": "Java",
      "icon": "assets/images/java.png",
      "progress": 0.0,
      "color": Colors.orange,
    },
    {
      "title": "C++",
      "icon": "assets/images/cpp.png",
      "progress": 0.0,
      "color": Colors.red,
    },
    {
      "title": "JavaScript",
      "icon": "assets/images/js.png",
      "progress": 0.0,
      "color": Colors.blueGrey,
    },
    {
      "title": "Dart",
      "icon": "assets/images/dart.png",
      "progress": 0.0,
      "color": Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchUserProgress();
     loadCourses();
  }

  Future<void> fetchUserName() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final response =
          await Supabase.instance.client
              .from('users')
              .select('name')
              .eq('id', userId)
              .single();
      setState(() {
        userName = response['name'] ?? "";
      });
    }
  }

  Future<void> fetchUserProgress() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client
        .from('progress')
        .select()
        .eq('user_id', userId);

    for (final course in allCourses) {
      final langProgress = response.firstWhereOrNull(
        (item) => item['language'] == course['title'],
      );

      if (langProgress != null) {
        final int completed = langProgress['completed_lessons'];
        final double progress = (completed / 5).clamp(0.0, 1.0);
        course['progress'] = progress;

        if (progress >= 1.0) {
          final existingCert =
              await Supabase.instance.client
                  .from('certificates')
                  .select('id')
                  .eq('user_id', userId)
                  .eq('language', course['title'])
                  .maybeSingle();

          if (existingCert == null) {
            await Supabase.instance.client.from('certificates').insert({
              'user_id': userId,
              'language': course['title'],
              'date': DateTime.now().toIso8601String(),
            });
            await Supabase.instance.client.from('notifications').insert({
              'user_id': userId,
              'title': 'Course Completed!',
              'body':
                  'You have completed the ${course['title']} course. Congratulations!',
              'is_read': false,
            });
          }
        }
      } else {
        course['progress'] = 0.0;
      }
    }
    setState(() {});
  }
  
   Future<void> loadCourses() async {
    final String response = await rootBundle.loadString(
      'assets/data/courses.json',
    );
    final List<dynamic> data = jsonDecode(response);
    setState(() {
      allLessons = data.map((json) => CourseModel.fromJson(json)).toList();
    });
  }

  Future<Map<String, dynamic>?> fetchCertificateData(String language) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response =
        await Supabase.instance.client
            .from('certificates')
            .select()
            .eq('user_id', user.id)
            .eq('language', language)
            .maybeSingle();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    const navyColor = Color(0xFF2A2575);
    final filteredCourses =
        allCourses.where((course) {
          return course['title'].toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) &&
              (selectedTab == 'Completed'
                  ? course['progress'] >= 1.0
                  : course['progress'] < 1.0);
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $userName',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: navyColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'What Would you like to learn Today?\nSearch Below.',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsView(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.notifications_none,
                      color: navyColor,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search for..',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: navyColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Course!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    const Text('User Experience Class',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyCourseView( courses: allLessons),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'See Class',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => selectedTab = 'Ongoing'),
                    child: buildTab('Ongoing', selectedTab == 'Ongoing'),
                  ),
                  const SizedBox(width: 50),
                  GestureDetector(
                    onTap: () => setState(() => selectedTab = 'Completed'),
                    child: buildTab('Completed', selectedTab == 'Completed'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...filteredCourses.map((course) {
                return buildCourseProgress(
                  course['title'],
                  course['icon'],
                  selectedTab == 'Completed' ? 1.0 : course['progress'],
                  course['color'],
                  isCompleted: selectedTab == 'Completed',
                );
              }).toList(),
              const SizedBox(height: 32),

              Container(
                margin: const EdgeInsets.only(top: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: navyColor, size: 30),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Need help or have a question?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: navyColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                                );
                              },
                              child: Container(decoration: BoxDecoration(
                                  color: Color(0xFFE0BBFF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: const Text(
                                  "Open Chat",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: navyColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTab(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2A2575) : const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildCourseProgress(
    String title,
    String iconPath,
    double progress,
    Color color, {
    bool isCompleted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(iconPath, width: 40, height: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                isCompleted
                    ? GestureDetector(
                      onTap: () async {
                        final certData = await fetchCertificateData(title);
                        if (certData != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CertificateView(
                                    name: userName,
                                    language: certData['language'],
                                    date: certData['date']?.toString() ?? '',
                                  ),
                            ),
                          );
                        } else {}
                      },
                      child: const Text(
                        'View Certificate',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color.fromARGB(255, 124, 123, 140),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                    : LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(color),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
