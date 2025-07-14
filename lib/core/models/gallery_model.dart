// class Gallery {
//   final bool status;
//   final List<GalleryPageContent> galleryPageContent;
//
//   Gallery({required this.status, required this.galleryPageContent});
//
//   factory Gallery.fromJson(Map<String, dynamic> json) {
//     return Gallery(
//       status: json['status'],
//       galleryPageContent: (json['gallery_page_content'] as List)
//           .map((i) => GalleryPageContent.fromJson(i))
//           .toList(),
//     );
//   }
// }
//
// class GalleryPageContent {
//   final String title;
//   final List<GalleryImage> galleryImagesData;
//   final List<GalleryParagraph> galleryParasData;
//
//   GalleryPageContent({
//     required this.title,
//     required this.galleryImagesData,
//     required this.galleryParasData,
//   });
//
//   factory GalleryPageContent.fromJson(Map<String, dynamic> json) {
//     return GalleryPageContent(
//       title: json['title'],
//       galleryImagesData: (json['galleryImagesData'] as List)
//           .map((i) => GalleryImage.fromJson(i))
//           .toList(),
//       galleryParasData: (json['galleryParasData'] as List)
//           .map((i) => GalleryParagraph.fromJson(i))
//           .toList(),
//     );
//   }
// }
//
// class GalleryImage {
//   final int id;
//   final String image;
//
//   GalleryImage({required this.id, required this.image});
//
//   factory GalleryImage.fromJson(Map<String, dynamic> json) {
//     return GalleryImage(
//       id: json['gallery_images_id'],
//       image: json['image'],
//     );
//   }
// }
//
// class GalleryParagraph {
//   final int id;
//   final String paragraph;
//
//   GalleryParagraph({required this.id, required this.paragraph});
//
//   factory GalleryParagraph.fromJson(Map<String, dynamic> json) {
//     return GalleryParagraph(
//       id: json['gallery_paras_id'],
//       paragraph: json['paragraph'],
//     );
//   }
// }
class Gallery {
  final bool? status;
  final List<GalleryPageContent>? galleryPageContent;

  Gallery({this.status, this.galleryPageContent});

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      status: json['status'] as bool?,
      galleryPageContent: (json['gallery_page_content'] as List?)
          ?.map((i) => GalleryPageContent.fromJson(i))
          .toList(),
    );
  }
}

class GalleryPageContent {
  final String? title;
  final int? galleryId;
  final List<GalleryImage>? galleryImagesData;
  final List<GalleryParagraph>? galleryParasData;

  GalleryPageContent({
    this.title,
    this.galleryId,
    this.galleryImagesData,
    this.galleryParasData,
  });

  factory GalleryPageContent.fromJson(Map<String, dynamic> json) {
    return GalleryPageContent(
      title: json['title'] as String?,
      galleryId: json['gallery_id'] as int?,
      galleryImagesData: (json['galleryImagesData'] as List?)
          ?.map((i) => GalleryImage.fromJson(i))
          .toList(),
      galleryParasData: (json['galleryParasData'] as List?)
          ?.map((i) => GalleryParagraph.fromJson(i))
          .where((para) => para.paragraph != null)
          .toList(),
    );
  }
}

class GalleryImage {
  final int? id;
  final String? image;

  GalleryImage({this.id, this.image});

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['gallery_images_id'] as int?,
      image: json['image'] as String?,
    );
  }
}

class GalleryParagraph {
  final int? id;
  final String? paragraph;

  GalleryParagraph({this.id, this.paragraph});

  factory GalleryParagraph.fromJson(Map<String, dynamic> json) {
    return GalleryParagraph(
      id: json['gallery_paras_id'] as int?,
      paragraph: json['paragraph'] as String?,
    );
  }
}
