class SingleArtModel {
  final bool status;
  final Art art;
  final List<Art> fromArtist;
  final List<Art> categoryArtData;

  SingleArtModel({
    required this.status,
    required this.art,
    required this.fromArtist,
    required this.categoryArtData,
  });

  factory SingleArtModel.fromJson(Map<String, dynamic> json) {
    return SingleArtModel(
      status:  json['status'] == 'true' || json['status'] == true,
      art: Art.fromJson(json['art']),
      fromArtist: List<Art>.from(json['from_artist'].map((x) => Art.fromJson(x))),
      categoryArtData: List<Art>.from(json['categoryArtData'].map((x) => Art.fromJson(x))),
    );
  }
}

class Art {
  final String artUniqueId;
  final String? fcmToken;
  final bool isWishlist;
  final String title;
  final String artistName;
  final String artistId;
  final String artType;
  final SingleCategory category;
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
  final List<ArtAdditionalDetail> artAdditionalDetails;
  final List<ArtImage> artImages;

  Art({
    required this.artUniqueId,
    this.fcmToken,
    required this.isWishlist,
    required this.title,
    required this.artistName,
    required this.artistId,
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
    required this.artAdditionalDetails,
    required this.artImages,
  });

  factory Art.fromJson(Map<String, dynamic> json) {
    return Art(
      artUniqueId: json['art_unique_id'],
      fcmToken: json['artist_fcm_token'],
      isWishlist: json['isWishlist'],
      title: json['title'],
      artistName: json['artist_name'],
      artistId: json['artist_unique_id'],
      artType: json['art_type'],
      category: SingleCategory.fromJson(json['category']),
      edition: json['edition'],
      price: json['price'],
      since: json['since'],
      pickupAddress: json['pickup_address'],
      pincode: json['pincode'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      frame: json['frame'],
      paragraph: json['paragraph'],
      status: json['status'],
      artAdditionalDetails: List<ArtAdditionalDetail>.from(
        json['art_additional_details'].map((x) => ArtAdditionalDetail.fromJson(x)),
      ),
      artImages: List<ArtImage>.from(json['artImages'].map((x) => ArtImage.fromJson(x))),
    );
  }
}

class SingleCategory {
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryImage;
  final String subText;

  SingleCategory({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryImage,
    required this.subText,
  });

  factory SingleCategory.fromJson(Map<String, dynamic> json) {
    return SingleCategory(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryIcon: json['category_icon'],
      categoryImage: json['category_image'],
      subText: json['sub_text'],
    );
  }
}

class ArtAdditionalDetail {
  final ArtData artData;
  final String description;

  ArtAdditionalDetail({
    required this.artData,
    required this.description,
  });

  factory ArtAdditionalDetail.fromJson(Map<String, dynamic> json) {
    return ArtAdditionalDetail(
      artData: ArtData.fromJson(json['art_data']),
      description: json['description'],
    );
  }
}

class ArtData {
  final int artDataId;
  final String artDataTitle;

  ArtData({
    required this.artDataId,
    required this.artDataTitle,
  });

  factory ArtData.fromJson(Map<String, dynamic> json) {
    return ArtData(
      artDataId: json['art_data_id'],
      artDataTitle: json['art_data_title'],
    );
  }
}

class ArtImage {
  final int artImageId;
  final String artType;
  final String image;

  ArtImage({
    required this.artImageId,
    required this.artType,
    required this.image,
  });

  factory ArtImage.fromJson(Map<String, dynamic> json) {
    return ArtImage(
      artImageId: json['art_image_id'],
      artType: json['art_type'],
      image: json['image'],
    );
  }
}
