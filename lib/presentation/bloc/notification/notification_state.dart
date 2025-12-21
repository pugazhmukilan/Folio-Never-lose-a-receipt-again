import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {}

/// Notifications initialized
class NotificationInitialized extends NotificationState {}

/// Notification scheduled
class NotificationScheduled extends NotificationState {
  final int notificationId;
  
  const NotificationScheduled(this.notificationId);
  
  @override
  List<Object?> get props => [notificationId];
}

/// Notification cancelled
class NotificationCancelled extends NotificationState {}

/// Notification permission granted
class NotificationPermissionGranted extends NotificationState {}

/// Notification permission denied
class NotificationPermissionDenied extends NotificationState {}

/// Notification error
class NotificationError extends NotificationState {
  final String message;
  
  const NotificationError(this.message);
  
  @override
  List<Object?> get props => [message];
}
