import 'package:equatable/equatable.dart';

abstract class OcrEvent extends Equatable {
  const OcrEvent();
  
  @override
  List<Object?> get props => [];
}

/// Process image for OCR
class ProcessImageOcr extends OcrEvent {
  final String imagePath;
  
  const ProcessImageOcr(this.imagePath);
  
  @override
  List<Object?> get props => [imagePath];
}

/// Reset OCR state
class ResetOcr extends OcrEvent {}
