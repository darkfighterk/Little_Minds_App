class Course {
  final int id;
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final String instructor;

  Course({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.instructor,
  });

  // Factory constructor to create a Course from JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      instructor: json['instructor'] ?? '',
    );
  }
}
