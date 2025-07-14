class FAQItem {
  final String title;
  final String para;
  final int faqId;

  FAQItem({required this.title, required this.para, required this.faqId});

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      title: json['title'],
      para: json['para'],
      faqId: json['faq_id'],
    );
  }
}

class FAQResponse {
  final bool status;
  final List<FAQItem> faqItems;  // Changed this to match the list of FAQItem

  FAQResponse({required this.status, required this.faqItems});

  factory FAQResponse.fromJson(Map<String, dynamic> json) {
    return FAQResponse(
      status: json['status'],
      faqItems: (json['faq'] as List)
          .map((i) => FAQItem.fromJson(i))
          .toList(),  // Changed `faq` to `faqItems`
    );
  }
}
