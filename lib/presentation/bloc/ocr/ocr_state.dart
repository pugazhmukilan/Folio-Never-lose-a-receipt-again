import 'package:equatable/equatable.dart';

abstract class OcrState extends Equatable {
  const OcrState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class OcrInitial extends OcrState {}

/// Processing image
class OcrProcessing extends OcrState {}

/// OCR completed successfully
class OcrSuccess extends OcrState {
  final String extractedText;
  final List<DateTime> extractedDates;
  final List<double> extractedAmounts;
  
  const OcrSuccess({
    required this.extractedText,
    required this.extractedDates,
    required this.extractedAmounts,
  });
  
  @override
  List<Object?> get props => [extractedText, extractedDates, extractedAmounts];
}

/// OCR failed
class OcrError extends OcrState {
  final String message;
  
  const OcrError(this.message);
  
  @override
  List<Object?> get props => [message];
}
