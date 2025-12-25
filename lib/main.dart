import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/preferences_helper.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/image_storage_service.dart';
import 'data/repositories/notification_service.dart';
import 'data/repositories/backup_service.dart';
import 'data/repositories/auth_service.dart';
import 'presentation/bloc/product/product_bloc.dart';
import 'presentation/bloc/notification/notification_bloc.dart';
import 'presentation/bloc/notification/notification_event.dart';
import 'presentation/bloc/backup/backup_bloc.dart';
import 'presentation/bloc/theme/theme_cubit.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone data for notifications
  tz.initializeTimeZones();
  
  // Initialize shared preferences
  await PreferencesHelper.init();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const WarrantyVaultApp());
}

class WarrantyVaultApp extends StatefulWidget {
  const WarrantyVaultApp({super.key});

  @override
  State<WarrantyVaultApp> createState() => _WarrantyVaultAppState();
}

class _WarrantyVaultAppState extends State<WarrantyVaultApp> with WidgetsBindingObserver {
  bool _isAuthenticated = false;
  bool _needsAuth = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _needsAuth = AuthService.isAppLockEnabled();
    _isAuthenticated = !_needsAuth;
    
    // Show auth screen if needed
    if (_needsAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAuthScreen();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-authenticate when app comes to foreground
    if (state == AppLifecycleState.resumed && AuthService.isAppLockEnabled()) {
      setState(() {
        _isAuthenticated = false;
      });
      _showAuthScreen();
    }
  }

  Future<void> _showAuthScreen() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
        fullscreenDialog: true,
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize repositories
    final databaseHelper = DatabaseHelper();
    final productRepository = ProductRepository(databaseHelper: databaseHelper);
    final imageStorageService = ImageStorageService();
    final notificationService = NotificationService();
    final backupService = BackupService(
      productRepository: productRepository,
      imageStorageService: imageStorageService,
    );
    
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: productRepository),
        RepositoryProvider.value(value: imageStorageService),
        RepositoryProvider.value(value: notificationService),
        RepositoryProvider.value(value: backupService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ProductBloc(
              productRepository: productRepository,
              imageStorageService: imageStorageService,
            ),
          ),
          BlocProvider(
            create: (context) => NotificationBloc(
              notificationService: notificationService,
            )..add(InitializeNotifications()),
          ),
          BlocProvider(
            create: (context) => BackupBloc(
              backupService: backupService,
            ),
          ),
          BlocProvider(
            create: (context) => ThemeCubit(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: _isAuthenticated
                  ? (PreferencesHelper.isOnboardingComplete()
                      ? const HomeScreen()
                      : const WelcomeScreen())
                  : const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
