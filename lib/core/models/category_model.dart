class Category {
  final int categoryId;
  final String categoryName;
  final String categoryImage;
  final String categoryIcon;
  final String subText;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.categoryImage,
    required this.categoryIcon,
    required this.subText,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryImage: json['category_image'],
      categoryIcon: json['category_icon'],
      subText: json['sub_text'],
    );
  }
}
