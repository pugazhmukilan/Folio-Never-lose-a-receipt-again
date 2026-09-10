import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/notification_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService notificationService;
  
  NotificationBloc({required this.notificationService}) : super(NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<ScheduleFieldReminder>(_onScheduleFieldReminder);
    on<CancelFieldReminder>(_onCancelFieldReminder);
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
  
  Future<void> _onScheduleFieldReminder(
    ScheduleFieldReminder event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationService.scheduleFieldReminder(
        event.field,
        event.itemName,
        defaultLeadDays: event.daysBefore,
      );

      // We don't get an explicit ID back, as field ID is used implicitly
      emit(const NotificationScheduled(0));
    } catch (e) {
      emit(NotificationError('Failed to schedule notification: ${e.toString()}'));
    }
  }
  
  Future<void> _onCancelFieldReminder(
    CancelFieldReminder event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationService.cancelFieldReminder(event.fieldId);
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
