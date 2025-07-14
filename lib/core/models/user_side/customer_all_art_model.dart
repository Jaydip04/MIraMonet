import '../upload_art_model/category_select_model.dart';

class CustomerAllArtModel {
  final String artUniqueId;
  final String title;
  final String artistName;
  final customerCategory category;
  final String edition;
  final String price;
  final String since;
  final String pickupAddress;
  final String pincode;
  // final CustomerArtCountry country;
  // final CustomerArtState state;
  // final CustomerArtCity city;
  final CustomerArtCountry? country;
  final CustomerArtState? state;
  final CustomerArtCity? city;
  final String frame;
  final String paragraph;
  final String status;
  final List<ArtAdditionalDetails> artAdditionalDetails;
  final List<ArtImage> artImages;

  CustomerAllArtModel({
    required this.artUniqueId,
    required this.title,
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
    required this.artAdditionalDetails,
    required this.artImages,
  });

  factory CustomerAllArtModel.fromJson(Map<String, dynamic> json) {
    return CustomerAllArtModel(
      artUniqueId: json['art_unique_id'],
      title: json['title'],
      artistName: json['artist_name'],
      category: customerCategory.fromJson(json['category']),
      edition: json['edition'],
      price: json['price'] ?? "",
      since: json['since'],
      pickupAddress: json['pickup_address'],
      pincode: json['pincode'],
      country: json['country'] != null ? CustomerArtCountry.fromJson(json['country']) : null,
      state: json['state'] != null ? CustomerArtState.fromJson(json['state']) : null,
      city: json['city'] != null ? CustomerArtCity.fromJson(json['city']) : null,
      // country: CustomerArtCountry.fromJson(json['country']),
      // state: CustomerArtState.fromJson(json['state']),
      // city: CustomerArtCity.fromJson(json['city']),
      frame: json['frame'],
      paragraph: json['paragraph'],
      status: json['status'],
      artAdditionalDetails: (json['art_additional_details'] as List)
          .map((e) => ArtAdditionalDetails.fromJson(e))
          .toList(),
      artImages: (json['artImages'] as List)
          .map((e) => ArtImage.fromJson(e))
          .toList(),
    );
  }
}

class customerCategory {
  final String categoryName;
  final String categoryIcon;
  final String categoryImage;
  final String subText;
  final SubCategory? subCategory;

  customerCategory({
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryImage,
    required this.subText,
    this.subCategory,
  });

  factory customerCategory.fromJson(Map<String, dynamic> json) {
    return customerCategory(
      categoryName: json['category_name'],
      categoryIcon: json['category_icon'],
      categoryImage: json['category_image'],
      subText: json['sub_text'],
      subCategory: json['sub_category'] != null ? SubCategory.fromJson(json['sub_category']) : null,
    );
  }
}
// class SubCategory {
//   final int subCategoryId;
//   final String subCategoryName;
//
//   SubCategory({
//     required this.subCategoryId,
//     required this.subCategoryName,
//   });
//
//   factory SubCategory.fromJson(Map<String, dynamic> json) {
//     return SubCategory(
//       subCategoryId: json['sub_category_id'],
//       subCategoryName: json['sub_category_name'],
//     );
//   }
// }
class ArtAdditionalDetails {
  final ArtData? artData;
  final String? description;

  ArtAdditionalDetails({
    this.artData,
    this.description,
  });

  factory ArtAdditionalDetails.fromJson(Map<String, dynamic> json) {
    return ArtAdditionalDetails(
      artData: json['art_data'] != null ? ArtData.fromJson(json['art_data']) : null,
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
      artDataId: json['art_data_id'] ?? 0,
      artDataTitle: json['art_data_title'] ?? "",
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
      artImageId: json['art_image_id'] ?? 0,
      artType: json['art_type'] ?? "",
      image: json['image'] ?? "",
    );
  }
}

class CustomerArtCountry {
  final int countryId;
  final String countryName;

  CustomerArtCountry({
    required this.countryId,
    required this.countryName,
  });

  factory CustomerArtCountry.fromJson(Map<String, dynamic> json) {
    return CustomerArtCountry(
      countryId: json['country_id'] ?? 0,
      countryName: json['country_name'] ?? "",
    );
  }
}

class CustomerArtState{
  final int stateId;
  final String stateName;

  CustomerArtState({
    required this.stateId,
    required this.stateName,
  });

  factory CustomerArtState.fromJson(Map<String, dynamic> json) {
    return CustomerArtState(
      stateId: json['state_id'] ?? 0,
      stateName: json['state_name'] ?? "",
    );
  }
}

class CustomerArtCity {
  final int cityId;
  final String cityName;

  CustomerArtCity({
    required this.cityId,
    required this.cityName,
  });

  factory CustomerArtCity.fromJson(Map<String, dynamic> json) {
    return CustomerArtCity(
      cityId: json['city_id'] ?? 0,
      cityName: json['city_name'] ?? "",
    );
  }
}
