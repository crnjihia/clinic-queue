// path: apps/mobile/lib/core/di/injection.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/firestore_queue_datasource.dart';
import '../../data/datasources/firestore_seed_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/clinic_repository_impl.dart';
import '../../data/repositories/queue_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../domain/usecases/advance_queue_usecase.dart';
import '../../domain/usecases/book_slot_usecase.dart';
import '../../domain/usecases/cancel_ticket_usecase.dart';
import '../../domain/usecases/get_clinics_usecase.dart';
import '../../domain/usecases/get_slots_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/watch_live_queue_usecase.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/booking/booking_bloc.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies(String environment) async {
  // 1. Firebase Singletons
  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  }
  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  // 2. Data Sources
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        firebaseAuth: getIt<FirebaseAuth>(),
        firestore: getIt<FirebaseFirestore>(),
      ),
    );
  }
  if (!getIt.isRegistered<FirestoreQueueDataSource>()) {
    getIt.registerLazySingleton<FirestoreQueueDataSource>(
      () => FirestoreQueueDataSource(firestore: getIt<FirebaseFirestore>()),
    );
  }
  if (!getIt.isRegistered<FirestoreSeedDataSource>()) {
    getIt.registerLazySingleton<FirestoreSeedDataSource>(
      () => FirestoreSeedDataSource(firestore: getIt<FirebaseFirestore>()),
    );
  }

  // 3. Repositories
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );
  }
  if (!getIt.isRegistered<ClinicRepository>()) {
    getIt.registerLazySingleton<ClinicRepository>(
      () => ClinicRepositoryImpl(
        firestore: getIt<FirebaseFirestore>(),
        seedDataSource: getIt<FirestoreSeedDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<QueueRepository>()) {
    getIt.registerLazySingleton<QueueRepository>(
      () => QueueRepositoryImpl(getIt<FirestoreQueueDataSource>()),
    );
  }

  // 4. Use Cases
  if (!getIt.isRegistered<SignInUseCase>()) {
    getIt.registerLazySingleton<SignInUseCase>(() => SignInUseCase(getIt<AuthRepository>()));
  }
  if (!getIt.isRegistered<GetClinicsUseCase>()) {
    getIt.registerLazySingleton<GetClinicsUseCase>(() => GetClinicsUseCase(getIt<ClinicRepository>()));
  }
  if (!getIt.isRegistered<GetSlotsUseCase>()) {
    getIt.registerLazySingleton<GetSlotsUseCase>(() => GetSlotsUseCase(getIt<ClinicRepository>()));
  }
  if (!getIt.isRegistered<BookSlotUseCase>()) {
    getIt.registerLazySingleton<BookSlotUseCase>(() => BookSlotUseCase(getIt<QueueRepository>()));
  }
  if (!getIt.isRegistered<WatchLiveQueueUseCase>()) {
    getIt.registerLazySingleton<WatchLiveQueueUseCase>(() => WatchLiveQueueUseCase(getIt<QueueRepository>()));
  }
  if (!getIt.isRegistered<AdvanceQueueUseCase>()) {
    getIt.registerLazySingleton<AdvanceQueueUseCase>(() => AdvanceQueueUseCase(getIt<QueueRepository>()));
  }
  if (!getIt.isRegistered<CancelTicketUseCase>()) {
    getIt.registerLazySingleton<CancelTicketUseCase>(() => CancelTicketUseCase(getIt<QueueRepository>()));
  }

  // 5. BLoCs
  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        authRepository: getIt<AuthRepository>(),
        signInUseCase: getIt<SignInUseCase>(),
      ),
    );
  }
  if (!getIt.isRegistered<BookingBloc>()) {
    getIt.registerFactory<BookingBloc>(
      () => BookingBloc(
        getClinicsUseCase: getIt<GetClinicsUseCase>(),
        getSlotsUseCase: getIt<GetSlotsUseCase>(),
        bookSlotUseCase: getIt<BookSlotUseCase>(),
      ),
    );
  }
}
