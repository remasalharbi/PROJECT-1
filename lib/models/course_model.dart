class CourseModel {
  final String title;
  final double rating;
  final String duration;
  final String category;

  CourseModel({
    required this.title,
    required this.rating,
    required this.duration,
    required this.category,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      title: json['title'],
      rating: (json['rating'] as num).toDouble(),
      duration: json['duration'],
      category: json['category'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'rating': rating,
    'duration': duration,
    'category': category,
  };
}
