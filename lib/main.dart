import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_localizations.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/queue/presentation/bloc/queue_bloc.dart';
import 'features/appointment/presentation/bloc/appointment_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/requests/presentation/bloc/request_bloc.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupDependencyInjection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => getIt<DashboardBloc>(),
        ),
        BlocProvider<QueueBloc>(
          create: (context) => getIt<QueueBloc>(),
        ),
        BlocProvider<AppointmentBloc>(
          create: (context) => getIt<AppointmentBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => getIt<NotificationBloc>(),
        ),
        BlocProvider<RequestBloc>(
          create: (context) => getIt<RequestBloc>(),
        ),
        BlocProvider<AdminBloc>(
          create: (context) => getIt<AdminBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Digital Queue',
        debugShowCheckedModeBanner: false,
        
        // Theme
        theme: AppTheme.lightTheme,
        
        // Localization
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('am', ''),
        ],
        locale: const Locale('en', ''),
        
        // Routing
        routerConfig: AppRouter.router,
      ),
    );
  }
}
