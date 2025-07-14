import 'package:equatable/equatable.dart';

import '../../../../../../core/models/faq_model.dart';

abstract class FAQState extends Equatable {
  @override
  List<Object> get props => [];
}

class FAQInitial extends FAQState {}

class FAQLoading extends FAQState {}

class FAQLoaded extends FAQState {
  final List<FAQItem> faqItems;

  FAQLoaded(this.faqItems);

  @override
  List<Object> get props => [faqItems];
}

class FAQError extends FAQState {
  final String message;

  FAQError(this.message);

  @override
  List<Object> get props => [message];
}
