import 'package:flutter/material.dart';
import 'package:warranty_vault/presentation/screens/add_product_screen.dart';
import 'package:warranty_vault/presentation/screens/products_list_screen.dart';
import '../../data/repositories/auth_service.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isShowingAuthScreen = false;
  bool _wasInBackground = false;
  bool _isSettingsActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Don't track lifecycle changes while showing auth screen or settings

    if (_isShowingAuthScreen || _isSettingsActive) return;
    
    // Track when app goes to background (not navigation events)
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
    }
    
    // Re-authenticate when app comes back to foreground
    if (state == AppLifecycleState.resumed && 
        AuthService.isAppLockEnabled() && 
        _wasInBackground) {
      _wasInBackground = false;
      _showAuthScreen();
    }
  }

  Future<void> _showAuthScreen() async {
    if (_isShowingAuthScreen) return;
    
    setState(() {
      _isShowingAuthScreen = true;
    });
    
    final authResult = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
        fullscreenDialog: true,
      ),
    );
    
    setState(() {
      _isShowingAuthScreen = false;
    });
    
    // If authentication failed, user can try again by reopening the app
    if (authResult != true) {
      // Reset the background flag so it won't re-trigger until next background event
      _wasInBackground = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProductsListScreen(
        onSettingsNavigationStart: () {
          setState(() {
            _isSettingsActive = true;
          });
        },
        onSettingsNavigationEnd: () {
          setState(() {
            _isSettingsActive = false;
            _wasInBackground = false; // Reset to prevent auth trigger
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
