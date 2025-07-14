class Story {
  // final Customer customer;
  final Art art;
  final List<Paragraph> paragraphs;
  final List<ImageDetails> images;

  Story({
    // required this.customer,
    required this.art,
    required this.paragraphs,
    required this.images,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      // customer: Customer.fromJson(json['customer']),
      art: Art.fromJson(json['art']),
      paragraphs: (json['paragraph'] as List)
          .map((paragraph) => Paragraph.fromJson(paragraph))
          .toList(),
      images: (json['image'] as List)
          .map((image) => ImageDetails.fromJson(image))
          .toList(),
    );
  }
}

class Customer {
  final String customerId;
  final String profileUrl;
  final String name;
  final String role;
  final String introduction;
  final String country;
  final String state;
  final String city;
  final String address;
  final String zipCode;
  final String longitude;
  final String latitude;

  Customer({
    required this.customerId,
    required this.profileUrl,
    required this.name,
    required this.role,
    required this.introduction,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.zipCode,
    required this.longitude,
    required this.latitude,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customer_unique_id'],
      profileUrl: json['customer_profile'],
      name: json['name'],
      role: json['role'],
      introduction: json['introduction'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      address: json['address'],
      zipCode: json['zip_code'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }
}

class Art {
  final String artId;
  final String title;
  final String artistName;
  final String edition;
  // final String categoryId;
  // final String artType;
  // final String price;
  // final String estimatePriceFrom;
  // final String estimatePriceTo;
  // final String since;
  // final String pickupAddress;
  // final String pincode;
  // final String country;
  // final String state;
  // final String city;
  // final String frame;
  // final String paragraph;
  // final String portalPercentages;

  Art({
    required this.artId,
    required this.title,
    required this.artistName,
    required this.edition,
    // required this.categoryId,
    // required this.artType,
    // required this.price,
    // required this.estimatePriceFrom,
    // required this.estimatePriceTo,
    // required this.since,
    // required this.pickupAddress,
    // required this.pincode,
    // required this.country,
    // required this.state,
    // required this.city,
    // required this.frame,
    // required this.paragraph,
    // required this.portalPercentages,
  });

  factory Art.fromJson(Map<String, dynamic> json) {
    return Art(
      artId: json['art_unique_id'],
      title: json['title'],
      artistName: json['artist_name'],
      edition: json['edition'],
      // categoryId: json['category_id'],
      // artType: json['art_type'],
      // price: json['price'],
      // estimatePriceFrom: json['estimate_price_from'],
      // estimatePriceTo: json['estimate_price_to'],
      // since: json['since'],
      // pickupAddress: json['pickup_address'],
      // pincode: json['pincode'],
      // country: json['country'],
      // state: json['state'],
      // city: json['city'],
      // frame: json['frame'],
      // paragraph: json['paragraph'],
      // portalPercentages: json['portal_percentages'],
    );
  }
}

class Paragraph {
  final int storyId;
  final String paragraph;
  final String status;
  final String insertedDate;
  final String insertedTime;

  Paragraph({
    required this.storyId,
    required this.paragraph,
    required this.status,
    required this.insertedDate,
    required this.insertedTime,
  });

  factory Paragraph.fromJson(Map<String, dynamic> json) {
    return Paragraph(
      storyId: json['artist_stories_id'],
      paragraph: json['paragraph'],
      status: json['status'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
    );
  }
}

class ImageDetails {
  final int imageId;
  final String artId;
  final String artType;
  final String imageUrl;
  final String insertedDate;
  final String insertedTime;

  ImageDetails({
    required this.imageId,
    required this.artId,
    required this.artType,
    required this.imageUrl,
    required this.insertedDate,
    required this.insertedTime,
  });

  factory ImageDetails.fromJson(Map<String, dynamic> json) {
    return ImageDetails(
      imageId: json['art_image_id'],
      artId: json['art_id'],
      artType: json['art_type'],
      imageUrl: json['image'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
    );
  }
}