class Lesson {
  final String language;
  final String title;
  final String? videoUrl;
  final String summary;
  final String content;

  Lesson({
    required this.language,
    required this.title,
    required this.videoUrl,
    required this.summary,
    required this.content,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      language: json['language'],
      title: json['title'],
      videoUrl: json['videoUrl'],
      summary: json['summary'],
      content: json['content'],
    );
  }
  Map<String, dynamic> toJson() => {
    'language': language,
    'title': title,
    'videoUrl': videoUrl,
    'summary': summary,
    'content': content,
  };
}
