class PortalPercentage {
  final int portalPercentagesId;
  final String percentage;

  PortalPercentage({required this.portalPercentagesId, required this.percentage});

  // Factory method to create an instance from JSON
  factory PortalPercentage.fromJson(Map<String, dynamic> json) {
    return PortalPercentage(
      portalPercentagesId: json['portal_percentages_id'],
      percentage: json['percentage'],
    );
  }

  // Method to convert the model to JSON (optional, depending on your use case)
  Map<String, dynamic> toJson() {
    return {
      'portal_percentages_id': portalPercentagesId,
      'percentage': percentage,
    };
  }
}
