import 'package:equatable/equatable.dart';

abstract class BackupState extends Equatable {
  const BackupState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class BackupInitial extends BackupState {}

/// Exporting data
class BackupExporting extends BackupState {}

/// Export completed
class BackupExportSuccess extends BackupState {
  final String zipFilePath;
  
  const BackupExportSuccess(this.zipFilePath);
  
  @override
  List<Object?> get props => [zipFilePath];
}

/// Importing data
class BackupImporting extends BackupState {}

/// Import completed
class BackupImportSuccess extends BackupState {
  final String message;
  
  const BackupImportSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Backup error
class BackupError extends BackupState {
  final String message;
  
  const BackupError(this.message);
  
  @override
  List<Object?> get props => [message];
}
