import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  
  @override
  List<Object?> get props => [];
}

/// Initialize notification service
class InitializeNotifications extends NotificationEvent {}

/// Schedule warranty expiry notification
class ScheduleWarrantyNotification extends NotificationEvent {
  final int productId;
  final String productName;
  final DateTime expiryDate;
  
  const ScheduleWarrantyNotification({
    required this.productId,
    required this.productName,
    required this.expiryDate,
  });
  
  @override
  List<Object?> get props => [productId, productName, expiryDate];
}

/// Cancel notification
class CancelNotification extends NotificationEvent {
  final int notificationId;
  
  const CancelNotification(this.notificationId);
  
  @override
  List<Object?> get props => [notificationId];
}

/// Request notification permissions
class RequestNotificationPermissions extends NotificationEvent {}
