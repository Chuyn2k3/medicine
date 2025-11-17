import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:medical_drug/data/datasources/auth_api_client.dart';
import 'package:medical_drug/data/repositories/auth_repository.dart';
import 'package:medical_drug/presentation/cubits/auth_cubit.dart';
import 'package:medical_drug/services/token_manager.dart';

import '../../data/datasources/api_client.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/medicine_repository.dart';
import '../../data/repositories/prescription_repository.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../presentation/cubits/chat_cubit.dart';
import '../../presentation/cubits/medicine_cubit.dart';
import '../../presentation/cubits/prescription_cubit.dart';
import '../../presentation/cubits/schedule_cubit.dart';

final getIt = GetIt.instance;

/// Setup dependency injection with GetIt
void setupServiceLocator() {
  // Core Services
  getIt.registerSingleton<TokenManager>(
    TokenManager(secureStorage: const FlutterSecureStorage()),
  );

  // DataSources
  getIt.registerSingleton<ApiClient>(
    ApiClient(tokenManager: getIt<TokenManager>()),
  );
  getIt.registerSingleton<AuthApiClient>(AuthApiClient());

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(getIt<AuthApiClient>()),
  );
  getIt.registerSingleton<MedicineRepository>(
    MedicineRepository(getIt<ApiClient>()),
  );
  getIt.registerSingleton<PrescriptionRepository>(
    PrescriptionRepository(getIt<ApiClient>()),
  );
  getIt.registerSingleton<ScheduleRepository>(
    ScheduleRepository(getIt<ApiClient>()),
  );
  getIt.registerSingleton<ChatRepository>(
    ChatRepository(getIt<ApiClient>()),
  );

  // Cubits
  getIt.registerSingleton<AuthCubit>(
    AuthCubit(getIt<AuthRepository>(), getIt<TokenManager>()),
  );
  getIt.registerSingleton<MedicineCubit>(
    MedicineCubit(getIt<MedicineRepository>()),
  );
  getIt.registerSingleton<PrescriptionCubit>(
    PrescriptionCubit(getIt<PrescriptionRepository>()),
  );
  getIt.registerSingleton<ScheduleCubit>(
    ScheduleCubit(getIt<ScheduleRepository>()),
  );
  getIt.registerSingleton<ChatCubit>(
    ChatCubit(getIt<ChatRepository>()),
  );
}
