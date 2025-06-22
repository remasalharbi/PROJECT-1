import 'dart:convert';
import 'package:codemaster/models/lesson_model.dart';
import 'package:codemaster/views/courses/lesson_view.dart';
import 'package:flutter/material.dart';
import 'package:codemaster/models/course_model.dart';
import 'package:codemaster/widgets/course_widget.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyCourseView extends StatefulWidget {
  final List<CourseModel> courses;

  const MyCourseView({
    super.key,
    required this.courses,
  });

  @override
  State<MyCourseView> createState() => _MyCourseViewState();
}

class _MyCourseViewState extends State<MyCourseView> {
  final supabase = Supabase.instance.client;

  String selectedCategory = 'All';
  String searchQuery = '';
  bool isSearching = false;

  List<String> bookmarkedTitles = [];

  @override
  void initState() {
    super.initState();
    fetchBookmarks();
  }

  Future<void> fetchBookmarks() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('bookmarks')
        .select('title')
        .eq('user_id', userId);

    setState(() {
      bookmarkedTitles =
          response.map<String>((item) => item['title'] as String).toList();
    });
  }

  Future<void> toggleBookmark(String title) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final isBookmarked = bookmarkedTitles.contains(title);

    if (isBookmarked) {
      await supabase
          .from('bookmarks')
          .delete()
          .eq('user_id', userId)
          .eq('title', title);
    } else {
      await supabase.from('bookmarks').insert({
        'user_id': userId,
        'title': title,
      });
    }

    await fetchBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = widget.courses.where((course) {
      final matchCategory =
          selectedCategory == 'All' || course.category == selectedCategory;
      final matchSearch = searchQuery.isEmpty ||
          course.title.toLowerCase().contains(searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9FF),
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: isSearching
                  ? TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search courses',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.black),
                    )
                  : const Text(
                      'My Courses',
                      style: TextStyle(color: Color(0xFF202244)),
                    ),
            ),
            IconButton(
              icon: Icon(isSearching ? Icons.clear : Icons.search),
              onPressed: () {
                setState(() {
                  if (isSearching) searchQuery = '';
                  isSearching = !isSearching;
                });
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  buildFilterChip("All"),
                  buildFilterChip("Java"),
                  buildFilterChip("Python"),
                  buildFilterChip("C++"),
                  buildFilterChip("Dart"),
                  buildFilterChip("JavaScript"),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  final course = filteredCourses[index];
                  final isBookmarked =
                      bookmarkedTitles.contains(course.title);

                  return CourseWidget(
                    courseName: course.category,
                    title: course.title,
                    rating: course.rating,
                    duration: course.duration,
                    isBookmarked: isBookmarked,
                    onBookmarkToggle: () => toggleBookmark(course.title),
                    backgroundColor: const Color(0xFF2A2575),
                    onTap: () async {
                      final jsonString = await rootBundle
                          .loadString('assets/data/lessons.json');
                      final lessonsJson = json.decode(jsonString) as List;

                      Lesson? lesson;
                      try {
                        final lessonMap = lessonsJson.firstWhere(
                          (item) => item['title'] == course.title,
                        );
                        lesson = Lesson.fromJson(lessonMap);
                      } catch (e) {
                        lesson = null;
                      }

                      if (lesson != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonDetailView(lesson: lesson!),
                          ),
                        );
                      } else {}
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilterChip(String category) {
    final isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: ChoiceChip(
        label: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF2A2575),
        backgroundColor: const Color(0xFFE8F1FF),
        shape: const StadiumBorder(),
        onSelected: (_) {
          setState(() {
            selectedCategory = category;
          });
        },
      ),
    );
  }
}
