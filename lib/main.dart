import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:bank_scan/Gold/core/constants/app_colors.dart';
import 'package:bank_scan/Gold/core/constants/app_text_styles.dart';
import 'package:bank_scan/Gold/core/network/gold_dio_client.dart';
import 'package:bank_scan/Gold/core/network/gold_session.dart';
import 'package:bank_scan/Gold/core/routing/app_router.dart';
import 'package:bank_scan/Gold/core/utils/screen_utility.dart';
import 'package:bank_scan/Gold/features/auth/gold_welcome_screen.dart';
import 'package:bank_scan/Gold/features/gold/screens/gold_screen.dart';
import 'package:bank_scan/Gold/features/main/main_navigation_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait-only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 1. Load environment variables (.env → BASE_URL, etc.)
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ .env loaded');
  } catch (e) {
    debugPrint('⚠️  .env not found – using defaults: $e');
  }

  // 2. Restore session from SharedPreferences into GoldSession memory.
  //    This loads token + userId + userName + all user fields in one call.
  await GoldSession.instance.load();

  // 3. Warm up the Gold Dio singleton (uses GoldSession token in interceptor).
  GoldDioClient.instance.dio;

  runApp(const GoldApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// Root widget
// ─────────────────────────────────────────────────────────────────────────────

class GoldApp extends StatelessWidget {
  const GoldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiloraPay',
      debugShowCheckedModeBanner: false,
      navigatorKey: goldNavigatorKey, // ← enables global 401 redirect

      // ── Gold design-token theme ───────────────────────────────────────────
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: AppTextStyles.fontFamily,
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.secondaryOrange,
          surface: AppColors.white,
          error: AppColors.error,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            textStyle: AppTextStyles.buttonText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          hintStyle: const TextStyle(color: AppColors.textHint),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),

        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primaryBlue
                : null,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),

        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentTextStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
          ),
        ),
      ),

      // ── Global builder: dismiss keyboard on tap + initialise ScreenUtility ──
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside of inputs
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: Builder(
            builder: (context) {
              ScreenUtility().init(context);
              return child!;
            },
          ),
        );
      },

      // ── Named route handler ───────────────────────────────────────────────
      onGenerateRoute: AppRouter.generateRoute,

      // ── Route observer ─────────────────────────────────────────────────
      // Enables GoldScreen.didPopNext() → auto-refresh on return.
      navigatorObservers: [goldRouteObserver],

      // ── Entry point: AuthGate decides first screen ────────────────────────
      home: const _AuthGate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Gate
// Reads the token stored by GoldDioClient (SharedPreferences key: auth_token).
// Decides whether to show the Welcome/Login flow or the main dashboard.
// ─────────────────────────────────────────────────────────────────────────────

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    // GoldSession.load() already called in main() —
    // use the in-memory result directly (no async needed here).
    if (GoldSession.instance.isLoggedIn) {
      return const MainNavigationScreen();
    }
    return const GoldWelcomeScreen();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Splash / loading screen
// ─────────────────────────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
