import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_drug/presentation/cubits/auth_cubit.dart';
import 'package:medical_drug/presentation/cubits/chat_cubit.dart';
import 'package:medical_drug/presentation/cubits/medicine_cubit.dart';
import 'package:medical_drug/presentation/cubits/prescription_cubit.dart';
import 'package:medical_drug/presentation/cubits/schedule_cubit.dart';
import 'package:medical_drug/presentation/pages/home_page.dart';
import 'package:medical_drug/presentation/pages/login_page.dart';

import 'core/service_locator/service_locator.dart';
import 'core/theme/app_theme.dart';

void main() {
  setupServiceLocator();
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
        BlocProvider<PrescriptionCubit>(
          create: (context) => getIt<PrescriptionCubit>(),
        ),
        BlocProvider<ScheduleCubit>(
          create: (context) => getIt<ScheduleCubit>(),
        ),
        BlocProvider<ChatCubit>(
          create: (context) => getIt<ChatCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Medicine App',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
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
