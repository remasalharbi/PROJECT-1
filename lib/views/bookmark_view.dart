import 'package:codemaster/widgets/custom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:codemaster/models/course_model.dart';
import 'package:codemaster/widgets/course_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyBookmarkView extends StatefulWidget {
  final List<CourseModel> allCourses;

  const MyBookmarkView({
    super.key,
    required this.allCourses,
  });

  @override
  State<MyBookmarkView> createState() => _MyBookmarkViewState();
}

class _MyBookmarkViewState extends State<MyBookmarkView> {
  final supabase = Supabase.instance.client;
  List<String> bookmarkedTitles = [];
  bool isLoading = true;

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
      isLoading = false;
    });
  }

  Future<void> removeBookmark(String title) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('bookmarks')
        .delete()
        .eq('user_id', userId)
        .eq('title', title);

    setState(() {
      bookmarkedTitles.remove(title); 
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title removed from bookmarks'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

 void _showRemoveConfirmationSheet(BuildContext context, CourseModel course) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFFF5F9FF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Remove From Bookmark?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2575),
                ),
              ),
              const SizedBox(height: 16),
              CourseWidget(
                courseName: course.category,
                title: course.title,
                rating: course.rating,
                duration: course.duration,
                isBookmarked: true,
                onBookmarkToggle: () {},
                backgroundColor: const Color(0xFF2A2575),
                onTap: () {},
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8F1FF),
                        side: const BorderSide(
                          color: Color(0xFFD0D0D0),
                          width: 2.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFF2A2575),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FittedBox( // ✅ لف الزر هنا عشان يتقلص إذا المساحة ضيقة
                      child: CustomActionButton(
                        text: 'Yes, Remove',
                        onPressed: () async {
                          Navigator.pop(context);
                          await removeBookmark(course.title);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final bookmarkedCourses = widget.allCourses
        .where((course) => bookmarkedTitles.contains(course.title))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9FF),
        elevation: 0,
        title: const Text(
          "My Bookmarks",
          style: TextStyle(color: Color(0xFF202244)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookmarkedCourses.isEmpty
              ? const Center(
                  child: Text(
                    "No bookmarks yet.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: bookmarkedCourses.length,
                  itemBuilder: (context, index) {
                    final course = bookmarkedCourses[index];
                    return CourseWidget(
                      courseName: course.category,
                      title: course.title,
                      rating: course.rating,
                      duration: course.duration,
                      isBookmarked: true,
                      onBookmarkToggle: () {
                        _showRemoveConfirmationSheet(context, course);
                      },
                      backgroundColor: const Color(0xFF2A2575),
                      onTap: () {},
                    );
                  },
                ),
              );
            }
          }
