import 'dart:convert';

class DonationPageContent {
  final int donationPagesId;
  final String heading;
  final String title;
  final String subHeading;
  final String donateNow;
  final String donationHeading;
  final List<DonationImage> donationImages;
  final List<DonationParagraph> donationParagraph;

  DonationPageContent({
    required this.donationPagesId,
    required this.heading,
    required this.title,
    required this.subHeading,
    required this.donateNow,
    required this.donationHeading,
    required this.donationImages,
    required this.donationParagraph,
  });

  factory DonationPageContent.fromJson(Map<String, dynamic> json) {
    return DonationPageContent(
      donationPagesId: json['donation_pages_id'],
      heading: json['heading'],
      title: json['title'],
      subHeading: json['sub_heading'],
      donateNow: json['donate_now'],
      donationHeading: json['donation_heading'],
      donationImages: (json['donationImages'] as List)
          .map((i) => DonationImage.fromJson(i))
          .toList(),
      donationParagraph: (json['donationParagraph'] as List)
          .map((i) => DonationParagraph.fromJson(i))
          .toList(),
    );
  }
}

class DonationImage {
  final int donationPageImagesId;
  final String images;

  DonationImage({
    required this.donationPageImagesId,
    required this.images,
  });

  factory DonationImage.fromJson(Map<String, dynamic> json) {
    return DonationImage(
      donationPageImagesId: json['donation_page_images_id'],
      images: json['images'],
    );
  }
}

class DonationParagraph {
  final int donationPageParagraphId;
  final String paragraph;

  DonationParagraph({
    required this.donationPageParagraphId,
    required this.paragraph,
  });

  factory DonationParagraph.fromJson(Map<String, dynamic> json) {
    return DonationParagraph(
      donationPageParagraphId: json['donation_page_paragraph_id'],
      paragraph: json['paragraph'],
    );
  }
}
