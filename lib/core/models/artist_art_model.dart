class ArtistArtModel {
  final String artUniqueId;
  final bool is_boost;
  bool? istroy;
  final String title;
  final String art_submission_type;
  String? artistName;
  final myArtCategory category;
  final String edition;
  final String price;
  final String since;
  final String pickupAddress;
  final String pincode;
  final myArtCountry? country;
  final myArtState? state;
  final myArtCity? city;
  final String frame;
  final String paragraph;
  final String status;
  final String colorCode;
  final List<ArtAdditionalDetail> artAdditionalDetails;
  final List<ArtImage> artImages;

  ArtistArtModel({
    required this.artUniqueId,
    required this.is_boost,
    this.istroy,
    required this.title,
    required this.art_submission_type,
    required this.artistName,
    required this.category,
    required this.edition,
    required this.price,
    required this.since,
    required this.pickupAddress,
    required this.pincode,
    this.country,
    this.state,
    this.city,
    required this.frame,
    required this.paragraph,
    required this.status,
    required this.colorCode,
    required this.artAdditionalDetails,
    required this.artImages,
  });

  factory ArtistArtModel.fromJson(Map<String, dynamic> json) {
    return ArtistArtModel(
      artUniqueId: json['art_unique_id'],
      is_boost: json['is_boost'],
      istroy: json['istroy'],
      title: json['title'],
      art_submission_type: json['art_submission_type'] ?? "",
      artistName: json['artist_name'],
      category: myArtCategory.fromJson(json['category']),
      edition: json['edition'],
      price: json['price'] ?? "",
      since: json['since'],
      pickupAddress: json['pickup_address'],
      pincode: json['pincode'],
      country: json['country'] != null ? myArtCountry.fromJson(json['country']) : null,
      state: json['state'] != null ? myArtState.fromJson(json['state']) : null,
      city: json['city'] != null ? myArtCity.fromJson(json['city']) : null,
      frame: json['frame'],
      paragraph: json['paragraph'],
      status: json['status'],
      colorCode: json['colorCode'],
      artAdditionalDetails: (json['art_additional_details'] as List)
          .map((e) => ArtAdditionalDetail.fromJson(e))
          .toList(),
      artImages: (json['artImages'] as List)
          .map((e) => ArtImage.fromJson(e))
          .toList(),
    );
  }
}

class myArtCategory {
  final String categoryName;
  final String categoryIcon;
  final String categoryImage;
  final String subText;

  myArtCategory({
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryImage,
    required this.subText,
  });

  factory myArtCategory.fromJson(Map<String, dynamic> json) {
    return myArtCategory(
      categoryName: json['category_name'],
      categoryIcon: json['category_icon'],
      categoryImage: json['category_image'],
      subText: json['sub_text'],
    );
  }
}

class myArtCountry {
  final int countryId;
  final String countryName;

  myArtCountry({
    required this.countryId,
    required this.countryName,
  });

  factory myArtCountry.fromJson(Map<String, dynamic> json) {
    return myArtCountry(
      countryId: json['country_id'],
      countryName: json['country_name'],
    );
  }
}

class myArtState {
  final int stateId;
  final String stateName;

  myArtState({
    required this.stateId,
    required this.stateName,
  });

  factory myArtState.fromJson(Map<String, dynamic> json) {
    return myArtState(
      stateId: json['state_id'],
      stateName: json['state_name'],
    );
  }
}

class myArtCity {
  final int cityId;
  final String cityName;

  myArtCity({
    required this.cityId,
    required this.cityName,
  });

  factory myArtCity.fromJson(Map<String, dynamic> json) {
    return myArtCity(
      cityId: json['city_id'],
      cityName: json['city_name'],
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

class ArtistData {
  final String artistUniqueId;
  final String artistProfile;
  final String introduction;

  ArtistData({
    required this.artistUniqueId,
    required this.artistProfile,
    required this.introduction,
  });

  // Factory method to create ArtistData from a JSON map
  factory ArtistData.fromJson(Map<String, dynamic> json) {
    return ArtistData(
      artistUniqueId: json['artist_unique_id'],
      artistProfile: json['artist_profile'],
      introduction: json['introduction'],
    );
  }

  // Method to convert ArtistData into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'artist_unique_id': artistUniqueId,
      'artist_profile': artistProfile,
      'introduction': introduction,
    };
  }
}
