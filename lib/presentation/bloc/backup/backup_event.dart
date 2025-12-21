import 'package:equatable/equatable.dart';

abstract class BackupEvent extends Equatable {
  const BackupEvent();
  
  @override
  List<Object?> get props => [];
}

/// Export data to backup file
class ExportBackup extends BackupEvent {}

/// Import data from backup file
class ImportBackup extends BackupEvent {
  final String zipFilePath;
  
  const ImportBackup(this.zipFilePath);
  
  @override
  List<Object?> get props => [zipFilePath];
}
