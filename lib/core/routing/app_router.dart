import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/faithful_dashboard_screen.dart';
import '../../features/auth/presentation/screens/faithful_registration_screen.dart';
import '../../features/auth/presentation/screens/mosques_screen.dart';
import '../../features/auth/presentation/screens/households_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final email = extra?['email'] as String? ?? '';
        return OtpScreen(email: email);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/faithfuls',
      builder: (context, state) => const FaithfulDashboardScreen(),
    ),
    GoRoute(
      path: '/register-faithful',
      builder: (context, state) => const FaithfulRegistrationScreen(),
    ),
    GoRoute(
      path: '/mosques',
      builder: (context, state) => const MosquesScreen(),
    ),
    GoRoute(
      path: '/households',
      builder: (context, state) => const HouseholdsScreen(),
    ),
  ],
);