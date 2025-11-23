import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_drug/presentation/cubits/auth_cubit.dart';
import 'package:medical_drug/presentation/cubits/chat_cubit.dart';
import 'package:medical_drug/presentation/cubits/medicine_cubit.dart';
import 'package:medical_drug/presentation/cubits/medicine_detail_cubit.dart';
import 'package:medical_drug/presentation/cubits/medicine_scan_cubit.dart';
import 'package:medical_drug/presentation/cubits/prescription_cubit.dart';
import 'package:medical_drug/presentation/cubits/prescription_detail_cubit.dart';
import 'package:medical_drug/presentation/cubits/schedule_cubit.dart';
import 'package:medical_drug/presentation/pages/home_page.dart';
import 'package:medical_drug/presentation/pages/login_page.dart';
import 'package:medical_drug/services/fcm_service.dart';
import 'package:medical_drug/services/firebase_messaging_background_handler.dart';
import 'package:medical_drug/services/notification_service.dart';

import 'core/service_locator/service_locator.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupServiceLocator();
  // Background / terminated handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Local notifications
  await NotificationService.init();

  // FCM service
  final fcmService = FcmService(FirebaseMessaging.instance);
  await fcmService.init();
  runApp(const MedicineApp());
}

class MedicineApp extends StatelessWidget {
  const MedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<MedicineCubit>(
          create: (context) => getIt<MedicineCubit>(),
        ),
        BlocProvider<MedicineDetailCubit>(
          create: (context) => getIt<MedicineDetailCubit>(),
        ),
        BlocProvider<PrescriptionDetailCubit>(
          create: (context) => getIt<PrescriptionDetailCubit>(),
        ),
        BlocProvider<PrescriptionCubit>(
          create: (context) => getIt<PrescriptionCubit>(),
        ),
        BlocProvider<ScheduleCubit>(
          create: (context) => getIt<ScheduleCubit>(),
        ),
        BlocProvider<ChatCubit>(
          create: (context) => getIt<ChatCubit>(),
        ),
        BlocProvider<MedicineScanCubit>(
          create: (context) => getIt<MedicineScanCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Medicine App',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // // Lần đầu load app hoặc đang check token
        // if (state is AuthLoading) {
        //   return const Scaffold(
        //     body: Center(child: CircularProgressIndicator()),
        //   );
        // }

        // Nếu đã login
        if (state is AuthAuthenticated) {
          return const HomePage();
        }

        // Luôn giữ LoginPage, xử lý lỗi trong LoginPage
        return const LoginPage();
      },
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
