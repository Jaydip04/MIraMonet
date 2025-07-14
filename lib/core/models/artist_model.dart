class ArtistModel {
  final String customerUniqueId;
  final String? customerProfile;
  final String name;
  final String email;
  final String mobile;
  final String? country;
  final String? state;
  final String? city;
  final String? address;

  ArtistModel({
    required this.customerUniqueId,
    this.customerProfile,
    required this.name,
    required this.email,
    required this.mobile,
    this.country,
    this.state,
    this.city,
    this.address,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      customerUniqueId: json['customer_unique_id'],
      customerProfile: json['customer_profile'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      address: json['address'],
    );
  }
}
