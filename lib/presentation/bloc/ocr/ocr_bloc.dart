import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../core/utils/date_utils.dart';
import 'ocr_event.dart';
import 'ocr_state.dart';

class OcrBloc extends Bloc<OcrEvent, OcrState> {
  final TextRecognizer textRecognizer;
  
  OcrBloc({TextRecognizer? textRecognizer})
      : textRecognizer = textRecognizer ?? TextRecognizer(),
        super(OcrInitial()) {
    on<ProcessImageOcr>(_onProcessImageOcr);
    on<ResetOcr>(_onResetOcr);
  }
  
  Future<void> _onProcessImageOcr(
    ProcessImageOcr event,
    Emitter<OcrState> emit,
  ) async {
    try {
      emit(OcrProcessing());
      
      // Create InputImage from file path
      final inputImage = InputImage.fromFilePath(event.imagePath);
      
      // Process image with ML Kit Text Recognition
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      // Extract all text
      final String extractedText = recognizedText.text;
      
      // Extract dates from text
      final List<DateTime> dates = DateTimeUtils.extractDatesFromText(extractedText);
      
      // Extract amounts from text
      final List<double> amounts = DateTimeUtils.extractAmountsFromText(extractedText);
      
      emit(OcrSuccess(
        extractedText: extractedText,
        extractedDates: dates,
        extractedAmounts: amounts,
      ));
    } catch (e) {
      emit(OcrError('Failed to process image: ${e.toString()}'));
    }
  }
  
  Future<void> _onResetOcr(
    ResetOcr event,
    Emitter<OcrState> emit,
  ) async {
    emit(OcrInitial());
  }
  
  @override
  Future<void> close() {
    textRecognizer.close();
    return super.close();
  }
}
