import 'dart:convert';

class AuctionArtModel {
  final String artUniqueId;
  final String title;
  final String artistName;
  final String artType;
  final AuctionArtCategory category;
  final String edition;
  final String price;
  final String since;
  final String pickupAddress;
  final String pincode;
  final String country;
  final String state;
  final String city;
  final String frame;
  final String paragraph;
  final String status;
  final String? bid_start_from;
  final String? bid_start_to;
  final List<ExhibitionArtImage> exhibitionArtImages;

  AuctionArtModel({
    required this.artUniqueId,
    required this.title,
    required this.artistName,
    required this.artType,
    required this.category,
    required this.edition,
    required this.price,
    required this.since,
    required this.pickupAddress,
    required this.pincode,
    required this.country,
    required this.state,
    required this.city,
    required this.frame,
    required this.paragraph,
    required this.status,
    this.bid_start_from,
    this.bid_start_to,
    required this.exhibitionArtImages,
  });

  factory AuctionArtModel.fromJson(Map<String, dynamic> json) {
    return AuctionArtModel(
      artUniqueId: json['art_unique_id'] ?? '',
      title: json['title'] ?? '',
      artistName: json['artist_name'] ?? '',
      artType: json['art_type'] ?? '',
      category: AuctionArtCategory.fromJson(json['category']),
      edition: json['edition'] ?? '',
      price: json['price'] ?? '',
      since: json['since'] ?? '',
      pickupAddress: json['pickup_address'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      frame: json['frame'] ?? '',
      paragraph: json['paragraph'] ?? '',
      status: json['status'] ?? '',
      bid_start_to: json['bid_start_to'] ?? '',
      bid_start_from: json['bid_start_from'] ?? '',
      exhibitionArtImages: (json['ExhibitionArtImage'] as List)
          .map((e) => ExhibitionArtImage.fromJson(e))
          .toList(),
    );
  }
}

class AuctionArtCategory {
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryImage;
  final String subText;

  AuctionArtCategory({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryImage,
    required this.subText,
  });

  factory AuctionArtCategory.fromJson(Map<String, dynamic> json) {
    return AuctionArtCategory(
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      categoryIcon: json['category_icon'] ?? '',
      categoryImage: json['category_image'] ?? '',
      subText: json['sub_text'] ?? '',
    );
  }
}

class ExhibitionArtImage {
  final int exhibitionArtImageId;
  final String artType;
  final String image;

  ExhibitionArtImage({
    required this.exhibitionArtImageId,
    required this.artType,
    required this.image,
  });

  factory ExhibitionArtImage.fromJson(Map<String, dynamic> json) {
    return ExhibitionArtImage(
      exhibitionArtImageId: json['exhibition_art_image_id'] ?? 0,
      artType: json['art_type'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
