import 'dart:convert';
import 'package:codemaster/main.dart';
import '../views/Start/create_acc_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:codemaster/models/course_model.dart';
import 'package:codemaster/views/home_view.dart';
import '../views/courses/course_view.dart';
import 'package:codemaster/views/bookmark_view.dart';
import '../views/profile/profile_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  int currentIndex = 0;
  List<CourseModel> allCourses = [];
  List<String> bookmarkedTitles = [];
 

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    final String response = await rootBundle.loadString(
      'assets/data/courses.json',
    );
    final List<dynamic> data = jsonDecode(response);
    setState(() {
      allCourses = data.map((json) => CourseModel.fromJson(json)).toList();
    });
  }

  // void toggleBookmark(String title) {
  //   setState(() {
  //     if (bookmarkedTitles.contains(title)) {
  //       bookmarkedTitles.remove(title);
  //     } else {
  //       bookmarkedTitles.add(title);
  //     }
  //   });
  // }
  void toggleBookmark(String title) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  final bookmarksTable = Supabase.instance.client.from('bookmarks');

  if (bookmarkedTitles.contains(title)) {
    await bookmarksTable
        .delete()
        .eq('user_id', userId)
        .eq('course_title', title);
    setState(() {
      bookmarkedTitles.remove(title);
    });
  } else {
    await bookmarksTable.insert({'user_id': userId, 'course_title': title});
    setState(() {
      bookmarkedTitles.add(title);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final bookmarkedCourses =
        allCourses
            .where((course) => bookmarkedTitles.contains(course.title))
            .toList();

    final List<Widget> screens = [
      const HomeView(),
      MyCourseView(
        courses: allCourses
      ),
     MyBookmarkView(allCourses: allCourses),
      ProfileView(
        onLogout: () async {
          await Supabase.instance.client.auth.signOut();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CreateAccView()),
              (route) => false,
            );
          }
        },
        onToggleTheme: () {
          themeNotifier.value = themeNotifier.value == ThemeMode.dark
              ? ThemeMode.light
              : ThemeMode.dark;
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: screens[currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFFF5F9FF),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFF5F9FF),
          currentIndex: currentIndex,
          selectedItemColor: const Color(0xFF034AC2),
          unselectedItemColor: Colors.blueGrey,
          elevation: 0,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Courses'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark),label: 'Bookmarks'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle),label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
