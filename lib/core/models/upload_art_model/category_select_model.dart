class UploadCategory {
  final int categoryId;
  final String categoryName;
  final String categoryImage;
  final String categoryIcon;
  final String subText;

  UploadCategory({
    required this.categoryId,
    required this.categoryName,
    required this.categoryImage,
    required this.categoryIcon,
    required this.subText,
  });

  // Factory constructor to create Category from JSON
  factory UploadCategory.fromJson(Map<String, dynamic> json) {
    return UploadCategory(
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      categoryImage: json['category_image'] ?? '',
      categoryIcon: json['category_icon'] ?? '',
      subText: json['sub_text'] ?? '',
    );
  }
}

class SubCategory {
  final int subCategoryId;
  final String subCategoryName;

  SubCategory({required this.subCategoryId, required this.subCategoryName});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subCategoryId: json['sub_category_1_id'] ?? json['sub_category_id'],
      subCategoryName: json['sub_category_1_name'] ?? json['sub_category_name'],
    );
  }
}