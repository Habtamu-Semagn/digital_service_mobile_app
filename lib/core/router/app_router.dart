import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/help_desk/presentation/pages/help_desk_screen.dart';
import '../../features/queue/presentation/pages/queue_generate_screen.dart';
import '../../features/appointment/presentation/pages/appointment_book_screen.dart';
import '../../features/auth/presentation/pages/profile_edit_screen.dart';
import '../../features/requests/presentation/pages/request_form_screen.dart';
import '../../features/dashboard/domain/entities/service.dart' as entity;
import '../di/injection_container.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(getIt<AuthBloc>().stream),
    redirect: (context, state) async {
      print('DEBUG: Router redirect check. Path: ${state.matchedLocation}');
      
      // Use AuthBloc state if available as source of truth
      // But we can also check repository directly
      final authRepository = getIt<AuthRepository>();
      final isAuthenticated = await authRepository.isAuthenticated();
      print('DEBUG: Router isAuthenticated: $isAuthenticated');

      final isLoginRoute = state.matchedLocation == '/login';

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoginRoute) {
        print('DEBUG: Redirecting to /login (not authenticated)');
        return '/login';
      }

      // If authenticated and on login page, redirect to dashboard
      if (isAuthenticated && isLoginRoute) {
        print('DEBUG: Redirecting to /dashboard (authenticated)');
        return '/dashboard';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/help-desk/:serviceId',
        name: 'help-desk',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          return HelpDeskScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/queue/generate/:serviceId',
        name: 'queue-generate',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          return QueueGenerateScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/appointment/book/:serviceId',
        name: 'appointment-book',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          return AppointmentBookScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/request/form/:serviceId',
        name: 'request-form',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          // We need to get the service entity somehow. 
          // For now, we'll pass it via extra if possible, or fetch it.
          // GoRouter 'extra' is better if we already have it.
          final service = state.extra as entity.Service;
          return RequestFormScreen(service: service);
        },
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/dashboard',
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

// Placeholder widgets - will be replaced with actual implementations
class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(
        child: Text('Dashboard - Coming Soon'),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
