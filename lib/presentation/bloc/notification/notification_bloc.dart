import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/notification_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService notificationService;
  
  NotificationBloc({required this.notificationService}) : super(NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<ScheduleWarrantyNotification>(_onScheduleWarrantyNotification);
    on<CancelNotification>(_onCancelNotification);
    on<RequestNotificationPermissions>(_onRequestNotificationPermissions);
  }
  
  Future<void> _onInitializeNotifications(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationService.initialize();
      emit(NotificationInitialized());
    } catch (e) {
      emit(NotificationError('Failed to initialize notifications: ${e.toString()}'));
    }
  }
  
  Future<void> _onScheduleWarrantyNotification(
    ScheduleWarrantyNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final notificationId = await notificationService.scheduleWarrantyExpiry(
        productId: event.productId,
        productName: event.productName,
        expiryDate: event.expiryDate,
      );
      
      emit(NotificationScheduled(notificationId));
    } catch (e) {
      emit(NotificationError('Failed to schedule notification: ${e.toString()}'));
    }
  }
  
  Future<void> _onCancelNotification(
    CancelNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationService.cancelNotification(event.notificationId);
      emit(NotificationCancelled());
    } catch (e) {
      emit(NotificationError('Failed to cancel notification: ${e.toString()}'));
    }
  }
  
  Future<void> _onRequestNotificationPermissions(
    RequestNotificationPermissions event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final granted = await notificationService.requestPermissions();
      
      if (granted) {
        emit(NotificationPermissionGranted());
      } else {
        emit(NotificationPermissionDenied());
      }
    } catch (e) {
      emit(NotificationError('Failed to request permissions: ${e.toString()}'));
    }
  }
}
