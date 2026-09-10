import 'package:equatable/equatable.dart';
import '../../../data/models/item_field.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  
  @override
  List<Object?> get props => [];
}

/// Initialize notification service
class InitializeNotifications extends NotificationEvent {}

/// Schedule a reminder for a specific date field
class ScheduleFieldReminder extends NotificationEvent {
  final String itemName;
  final ItemField field;
  final int daysBefore;
  
  const ScheduleFieldReminder({
    required this.itemName,
    required this.field,
    required this.daysBefore,
  });
  
  @override
  List<Object?> get props => [itemName, field, daysBefore];
}

/// Cancel reminder for a specific field
class CancelFieldReminder extends NotificationEvent {
  final int fieldId;
  
  const CancelFieldReminder(this.fieldId);
  
  @override
  List<Object?> get props => [fieldId];
}

/// Request notification permissions
class RequestNotificationPermissions extends NotificationEvent {}
