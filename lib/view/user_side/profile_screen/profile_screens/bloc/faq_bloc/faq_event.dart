import 'package:equatable/equatable.dart';

abstract class FAQEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchFAQs extends FAQEvent {
  final String role;

  FetchFAQs(this.role);

  @override
  List<Object> get props => [role];
}
