import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/api_service/api_service.dart';
import 'faq_event.dart';
import 'faq_state.dart';

class FAQBloc extends Bloc<FAQEvent, FAQState> {
  final ApiService apiService;

  FAQBloc(this.apiService) : super(FAQInitial()) {
    on<FetchFAQs>((event, emit) async {
      emit(FAQLoading());
      try {
        final faqItems = await apiService.fetchFAQs(event.role);
        emit(FAQLoaded(faqItems));
      } catch (error) {
        emit(FAQError(error.toString()));
      }
    });
  }
}
