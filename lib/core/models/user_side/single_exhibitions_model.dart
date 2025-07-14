import 'dart:convert';

class SingleExhibitionsModel {
  final bool status;
  final SingleExhibitionsExhibition exhibition;
  final List<SingleExhibitionsExhibition> recentExhibition;
  final List<SingleExhibitionsExhibition> upcomingExhibitions;

  SingleExhibitionsModel({
    required this.status,
    required this.exhibition,
    required this.recentExhibition,
    required this.upcomingExhibitions,
  });

  factory SingleExhibitionsModel.fromJson(Map<String, dynamic> json) {
    return SingleExhibitionsModel(
      status: json['status'],
      exhibition: SingleExhibitionsExhibition.fromJson(json['exhibition']),
      recentExhibition: List<SingleExhibitionsExhibition>.from(json['recentExhibition'].map((x) => SingleExhibitionsExhibition.fromJson(x))),
      upcomingExhibitions: List<SingleExhibitionsExhibition>.from(json['upcomingExhibitions'].map((x) => SingleExhibitionsExhibition.fromJson(x))),
    );
  }
}

class SingleExhibitionsExhibition {
  final int exhibitionId;
  final String exhibitionUniqueId;
  final String name;
  final String tagline;
  final String description;
  final String startDate;
  final String endDate;
  final int amount;
  final String insertedDate;
  final String updatedDate;
  final SingleExhibitionsCountry country;
  final SingleExhibitionsStateSubdivision state;
  final SingleExhibitionsCity city;
  final String address1;
  final String address2;
  final String contactNumber;
  final String contactEmail;
  final String websiteLink;
  final String status;
  final String logo;
  final List<SingleExhibitionsExhibitionGallery> exhibitionGallery;
  final List<SingleExhibitionsExhibitionGuest> exhibitionGuests;
  final List<SingleExhibitionsExhibitionArt> exhibitionArt;
  final List<SingleExhibitionsExhibitionSponsor> exhibitionSponsor;

  SingleExhibitionsExhibition({
    required this.exhibitionId,
    required this.exhibitionUniqueId,
    required this.name,
    required this.tagline,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.insertedDate,
    required this.updatedDate,
    required this.country,
    required this.state,
    required this.city,
    required this.address1,
    required this.address2,
    required this.contactNumber,
    required this.contactEmail,
    required this.websiteLink,
    required this.status,
    required this.logo,
    required this.exhibitionGallery,
    required this.exhibitionGuests,
    required this.exhibitionArt,
    required this.exhibitionSponsor,
  });

  factory SingleExhibitionsExhibition.fromJson(Map<String, dynamic> json) {
    return SingleExhibitionsExhibition(
      exhibitionId: json['exhibition_id'],
      exhibitionUniqueId: json['exhibition_unique_id'],
      name: json['name'],
      tagline: json['tagline'],
      description: json['description'],
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      amount: json['amount'],
      insertedDate: json['inserted_date'] ?? "",
      updatedDate: json['updated_date'] ?? "",
      country: SingleExhibitionsCountry.fromJson(json['country']),
      state: SingleExhibitionsStateSubdivision.fromJson(json['state']),
      city: SingleExhibitionsCity.fromJson(json['city']),
      address1: json['address1'],
      address2: json['address2'],
      contactNumber: json['contact_number'],
      contactEmail: json['contact_email'],
      websiteLink: json['website_link'],
      status: json['status'],
      logo: json['logo'],
      exhibitionGallery: List<SingleExhibitionsExhibitionGallery>.from(json['exhibition_gallery'].map((x) => SingleExhibitionsExhibitionGallery.fromJson(x))),
      exhibitionGuests: List<SingleExhibitionsExhibitionGuest>.from(json['exhibition_guests'].map((x) => SingleExhibitionsExhibitionGuest.fromJson(x))),
      exhibitionArt: List<SingleExhibitionsExhibitionArt>.from(json['exhibition_art'].map((x) => SingleExhibitionsExhibitionArt.fromJson(x))),
      exhibitionSponsor: List<SingleExhibitionsExhibitionSponsor>.from(json['exhibition_sponsor'].map((x) => SingleExhibitionsExhibitionSponsor.fromJson(x))),
    );
  }
}

class SingleExhibitionsCountry {
  final int countryId;
  final String countryName;

  SingleExhibitionsCountry({
    required this.countryId,
    required this.countryName,
  });

  factory SingleExhibitionsCountry.fromJson(Map<String, dynamic> json) {
    return SingleExhibitionsCountry(
      countryId: json['country_id'],
      countryName: json['country_name'],
    );
  }
}

class SingleExhibitionsStateSubdivision {
  final int stateSubdivisionId;
  final String stateSubdivisionName;

  SingleExhibitionsStateSubdivision({
    required this.stateSubdivisionId,
    required this.stateSubdivisionName,
  });

  factory SingleExhibitionsStateSubdivision.fromJson(Map<String, dynamic> json) {
    return SingleExhibitionsStateSubdivision(
      stateSubdivisionId: json['state_subdivision_id'],
      stateSubdivisionName: json['state_subdivision_name'],
    );
  }
}

class SingleExhibitionsCity {
  final int cityId;
  final String nameOfCity;

  SingleExhibitionsCity({
    required this.cityId,
    required this.nameOfCity,
  });

  factory SingleExhibitionsCity.fromJson(Map<String, dynamic> json) {
    return SingleExhibitionsCity(
      cityId: json['cities_id'],
      nameOfCity: json['name_of_city'],
    );
  }
}

class SingleExhibitionsExhibitionGallery {
  final int exhibitionGalleryId;
  final String link;
  final String tagline;
  final int exhibitionId;
  final String insertedDate;
  final String insertedTime;
  final String status;

  SingleExhibitionsExhibitionGallery({
    required this.exhibitionGalleryId,
    required this.link,
    required this.tagline,
    required this.exhibitionId,
    required this.insertedDate,
    required this.insertedTime,
    required this.status,
  });

  factory SingleExhibitionsExhibitionGallery.fromJson(Map<String, dynamic> json) {
    return SingleExhibitionsExhibitionGallery(
      exhibitionGalleryId: json['exhibition_gallery_id'],
      link: json['link'],
      tagline: json['tagline'],
      exhibitionId: json['exhibition_id'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
      status: json['status'],
    );
  }
}

class SingleExhibitionsExhibitionGuest {
  final int exhibitionGuestId;
  final String photo;
  final String name;
  final String message;
  final int exhibitionId;
  final String status;
  final String insertedDate;
  final String insertedTime;

  SingleExhibitionsExhibitionGuest({
    required this.exhibitionGuestId,
    required this.photo,
    required this.name,
    required this.message,
    required this.exhibitionId,
    required this.status,
    required this.insertedDate,
    required this.insertedTime,
  });

  factory SingleExhibitionsExhibitionGuest.fromJson(Map<String, dynamic> json) {
    return SingleExhibitionsExhibitionGuest(
      exhibitionGuestId: json['exhibition_guest_id'],
      photo: json['photo'],
      name: json['name'],
      message: json['message'],
      exhibitionId: json['exhibition_id'],
      status: json['status'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
    );
  }
}

class SingleExhibitionsExhibitionArt {
  final int exhibitionArtId;
  final int exhibitionId;
  final int artId;
  final String status;
  final String insertedDate;
  final String insertedTime;
  final SingleExhibitionsArt art;

  SingleExhibitionsExhibitionArt({
    required this.exhibitionArtId,
    required this.exhibitionId,
    required this.artId,
    required this.status,
    required this.insertedDate,
    required this.insertedTime,
    required this.art,
  });

  factory SingleExhibitionsExhibitionArt.fromJson(Map<String, dynamic> json) {
    return SingleExhibitionsExhibitionArt(
      exhibitionArtId: json['exhibition_art_id'],
      exhibitionId: json['exhibition_id'],
      artId: json['art_id'],
      status: json['status'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
      art: SingleExhibitionsArt.fromJson(json['art']),
    );
  }
}

class SingleExhibitionsArt {
  final String artUniqueId;
  final String title;
  final String artistName;
  final String edition;
  final String categoryId;
  final String artType;
  final String? price;
  final String estimatePriceFrom;
  final String estimatePriceTo;
  final String since;
  final String pickupAddress;
  final String pincode;
  final String country;
  final String state;
  final String city;
  final String frame;
  final String paragraph;
  final String portalPercentages;
  final String status;
  final String? buyDate;
  final String insertedDate;
  final String insertedTime;
  final List<ArtImage> artImages;

  SingleExhibitionsArt({
    required this.artUniqueId,
    required this.title,
    required this.artistName,
    required this.edition,
    required this.categoryId,
    required this.artType,
    required this.price,
    required this.estimatePriceFrom,
    required this.estimatePriceTo,
    required this.since,
    required this.pickupAddress,
    required this.pincode,
    required this.country,
    required this.state,
    required this.city,
    required this.frame,
    required this.paragraph,
    required this.portalPercentages,
    required this.status,
    required this.buyDate,
    required this.insertedDate,
    required this.insertedTime,
    required this.artImages,
  });

  factory SingleExhibitionsArt.fromJson(Map<String, dynamic> json) {
    return SingleExhibitionsArt(
      artUniqueId: json['art_unique_id'],
      title: json['title'],
      artistName: json['artist_name'],
      edition: json['edition'],
      categoryId: json['category_id'],
      artType: json['art_type'],
      price: json['price'],
      estimatePriceFrom: json['estimate_price_from'],
      estimatePriceTo: json['estimate_price_to'],
      since: json['since'],
      pickupAddress: json['pickup_address'],
      pincode: json['pincode'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      frame: json['frame'],
      paragraph: json['paragraph'],
      portalPercentages: json['portal_percentages'],
      status: json['status'],
      buyDate: json['buy_date'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
      artImages: List<ArtImage>.from(json['art_images'].map((x) => ArtImage.fromJson(x))),
    );
  }
}

class ArtImage {
  final String image;
  final String status;

  ArtImage({
    required this.image,
    required this.status,
  });

  factory ArtImage.fromJson(Map<String, dynamic> json) {
    return ArtImage(
      image: json['image'],
      status: json['status'] ?? "",
    );
  }
}

class SingleExhibitionsExhibitionSponsor {
  final int exhibitionSponsorId;
  final String name;
  final String logo;
  final String websiteLink;
  final String tagline;
  final int exhibitionId;
  final String status;
  final String insertedDate;
  final String insertedTime;

  SingleExhibitionsExhibitionSponsor({
    required this.exhibitionSponsorId,
    required this.name,
    required this.logo,
    required this.websiteLink,
    required this.tagline,
    required this.exhibitionId,
    required this.status,
    required this.insertedDate,
    required this.insertedTime,
  });

  factory SingleExhibitionsExhibitionSponsor.fromJson(Map<String, dynamic> json) {
    return SingleExhibitionsExhibitionSponsor(
      exhibitionSponsorId: json['exhibition_sponsor_id'],
      name: json['name'],
      logo: json['logo'],
      websiteLink: json['website_link'],
      tagline: json['tagline'],
      exhibitionId: json['exhibition_id'],
      status: json['status'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
    );
  }
}
